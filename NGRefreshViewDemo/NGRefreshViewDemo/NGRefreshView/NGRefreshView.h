//
//  NGRefreshView.h
//  NGRefreshViewDemo
//
//  Created by laifeng on 6/17/15.
//  Copyright (c) 2015 nangua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NGRefreshAction)(void);

@interface NGRefreshView : UIView

-(instancetype)initScrollView:(UIScrollView*)scrollView NS_DESIGNATED_INITIALIZER;

/*
 * 下拉刷新时触发Block
 */
@property(nonatomic,copy) NGRefreshAction   action;

@end
