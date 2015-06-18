//
//  UIScrollView+NGRefreshView.m
//  NGRefreshViewDemo
//
//  Created by laifeng on 6/17/15.
//  Copyright (c) 2015 nangua. All rights reserved.
//

#import "UIScrollView+NGRefreshView.h"
#import "NGRefreshView.h"
#import <objc/runtime.h>

static char UIScrollViewRefreshControl;
@implementation UIScrollView (NGRefreshView)
@dynamic refreshControl;

-(void)addPullToRefreshAction:(void (^)(void))action
{
    if (!self.refreshControl) {
        NGRefreshView* refreshControl = [[NGRefreshView alloc] initScrollView:self];
        refreshControl.action = action;
    }
}

-(void)setRefreshControl:(NGRefreshView *)refreshControl
{
    [self willChangeValueForKey:@"NGRefreshControlKey"];
    objc_setAssociatedObject(self,
                             &UIScrollViewRefreshControl,
                             refreshControl,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"NGRefreshControlKey"];
}

-(NGRefreshView *)refreshControl
{
    return objc_getAssociatedObject(self, &UIScrollViewRefreshControl);
}
@end
