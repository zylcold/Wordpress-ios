//
//  WPRouter+Post.m
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 10/01/15.
//  Copyright (c) 2015 Evgeniy Yurtaev. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>

#import "WPRouter+Post.h"
#import "WPPostViewModelImp.h"
#import "WPPostViewController.h"
#import "WPPost.h"

@implementation WPRouter (Post)

- (RACSignal *)presentPostScreenWithPost:(WPPost *)post
{
    return [RACSignal defer:^RACSignal *{
        
        WPPostViewModel *viewModel = [[WPPostViewModel alloc] initWithPost:post];
        WPPostViewController *viewController = [[WPPostViewController alloc] initWithViewModel:viewModel];
        
        return [self pushViewController:viewController viewModel:viewModel animated:YES];
    }];
}

@end
