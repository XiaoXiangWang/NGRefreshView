//
//  UIScrollView+NGRefreshView.h
//  NGRefreshViewDemo
//
//  Created by laifeng on 6/17/15.
//  Copyright (c) 2015 nangua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGRefreshView;

@interface UIScrollView (NGRefreshView)
/*
 * 下拉刷新视图
 */
@property(nonatomic,weak,readonly) NGRefreshView* refreshControl;

-(void)addPullToRefreshAction:(void(^)(void))action;

@end
