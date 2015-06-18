//
//  FirstViewController.m
//  NGRefreshViewDemo
//
//  Created by laifeng on 6/17/15.
//  Copyright (c) 2015 nangua. All rights reserved.
//

#import "FirstViewController.h"
#import "UIScrollView+NGRefreshView.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds),
                                             CGRectGetHeight(self.view.bounds)*2);
    [self.scrollView addPullToRefreshAction:^{
        NSLog(@"成长的痕迹!");
    }];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
