//
//  NGRefreshView.m
//  NGRefreshViewDemo
//
//  Created by laifeng on 6/17/15.
//  Copyright (c) 2015 nangua. All rights reserved.
//

#import "NGRefreshView.h"

#define NGRefreshViewDefaultHeight 50

/*
 * NGObserverKeyPathContentOffset
 */
static NSString* const NGObserverKeyPathContentOffset = @"contentOffset";

/*
 *
 */
static NSString* const NGObserverKeyPathContentSize = @"contentSize";

/*
 *
 */
static NSString* const NGObserverKeyPathContentInset = @"contentInset";

typedef NS_ENUM(NSUInteger, NGRefreshState) {
    NGRefreshStateStopped,
    NGRefreshStateTriggered,
    NGRefreshStateLoading,
};


#pragma mark - NGRefreshContentView

@interface NGRefreshContentView : UIView

@property(nonatomic,assign) CGFloat progress;

@property(nonatomic,strong) CADisplayLink* displayLink;

@end


@implementation NGRefreshContentView
{
    CFTimeInterval _animationStartTime;
    CGFloat _animationFromValue;
    CGFloat _animationToValue;
}

#pragma mark - life cycle
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        CAShapeLayer* shapeLayer    =   [self _layer];
        shapeLayer.path             =   [self _pathWithFrame:self.bounds].CGPath;
        shapeLayer.strokeColor      =   [UIColor whiteColor].CGColor;
        shapeLayer.fillColor        =   [UIColor clearColor].CGColor;
        shapeLayer.lineWidth        =   2;
        shapeLayer.lineCap          =   kCALineCapRound;
        shapeLayer.contentsScale    =   [UIScreen mainScreen].scale;
        self.progress = 0;
        [self _updateProgress];
    }
    return self;
}

+(Class)layerClass
{
    return [CAShapeLayer class];
}

-(void)layoutSubviews
{
    [self _layer].path = [self _pathWithFrame:self.bounds].CGPath;
}


#pragma mark - Action
-(void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}


- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (self.progress == progress) {
        return;
    }
    if (animated) {
        _animationStartTime = CACurrentMediaTime();
        _animationFromValue = self.progress;
        _animationToValue   = progress;
        if (!self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                           selector:@selector(_animateProgress:)];
            [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
        }
    }else{
        if (self.displayLink) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        }
        _progress = progress;
        //更新视图上的进度
        [self _updateProgress];
    }
}

-(void)_animateProgress:(CADisplayLink*)displayLink
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat dt = (displayLink.timestamp - _animationStartTime) / 0.3f;
        if (dt >= 1.0) {
            /*Order is important! Otherwise concurrency will cause errors, because setProgress:
             will detect an animation in progress and try to stop it by itself. Once over one, 
             set to actual progress amount. Animation is over.*/
            [self.displayLink invalidate];
            self.displayLink = nil;
            [self setProgress:_animationToValue animated:NO];
            return;
        }
        
        //Set progress
        _progress =  _animationFromValue + dt * (_animationToValue - _animationFromValue);

        //更新进度
        [self _updateProgress];
    });
}

-(void)_updateProgress
{
    
    [self _layer].strokeEnd = self.progress;
}
#pragma mark - help
-(CAShapeLayer*)_layer
{
    return (CAShapeLayer*)self.layer;
}

-(UIBezierPath*)_pathWithFrame:(CGRect)frame
{
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle+M_PI*2;
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(frame),
                                                                           CGRectGetMidY(frame))
                                                        radius:CGRectGetWidth(frame)/2-2
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:YES];
    return path;
}

@end

#pragma mark - NGRefreshView
@interface NGRefreshView ()

@property(nonatomic,assign) UIScrollView* scrollView;

/*
 * 当前状态
 */
@property(nonatomic,assign) NGRefreshState refreshStates;

@end

@implementation NGRefreshView

#pragma mark - life cycle
-(instancetype)initScrollView:(UIScrollView *)scrollView
{
    NSParameterAssert(scrollView);
    if (self = [super initWithFrame:CGRectMake(0,
                                               0,//-NGRefreshViewDefaultHeight,
                                               CGRectGetWidth(scrollView.bounds),
                                               NGRefreshViewDefaultHeight)]) {
        
        self.scrollView = scrollView;
        [self _setup];
        [scrollView addSubview:self];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    return [self initScrollView:nil];
}

-(instancetype)init
{
    return [self initScrollView:nil];
}

-(void)_setup
{
    static NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
    
    //监听ScrollView的contentOffset属性
    [self.scrollView addObserver:self
                      forKeyPath:NGObserverKeyPathContentOffset
                         options:options
                         context:nil];
    
    //监听ScrollView的contentInset属性
    [self.scrollView addObserver:self
                      forKeyPath:NGObserverKeyPathContentInset
                         options:options
                         context:nil];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGRect contentViewFrame = CGRectMake((CGRectGetWidth(self.bounds)-25)/2,
                                         (CGRectGetHeight(self.bounds)-25)/2,
                                         25, 25);
    NGRefreshContentView* contentView = [[NGRefreshContentView alloc] initWithFrame:contentViewFrame];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:contentView];
    
#if 1
    self.backgroundColor = [UIColor greenColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [contentView setProgress:0.5 animated:YES];
    });
#endif
    
}

-(void)dealloc
{
    self.scrollView = nil;
}

#pragma mark - observer methods
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqualToString:NGObserverKeyPathContentOffset]) {
        [self _scrollViewDidScroll:[change[NSKeyValueChangeNewKey] CGPointValue]];
    }else if([keyPath isEqualToString:NGObserverKeyPathContentInset]){
    
    }

}

-(void)_scrollViewDidScroll:(CGPoint)newOffset
{
    
}

#pragma others
-(void)setRefreshStates:(NGRefreshState)refreshStates
{
    _refreshStates = refreshStates;
    switch (refreshStates) {
        case NGRefreshStateStopped:
            break;
        case NGRefreshStateTriggered:
            break;
        case NGRefreshStateLoading:
            break;
    }
}


@end
