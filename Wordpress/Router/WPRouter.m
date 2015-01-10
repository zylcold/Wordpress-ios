//
//  WPRouter.m
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 31/12/14.
//  Copyright (c) 2014 Evgeniy Yurtaev. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "WPRouter.h"
#import "WPNavigationController.h"

#import "WPViewModel+Friend.h"
#import "UIViewController+RACExtension.h"

static WPRouter *_sharedInstance;

@interface WPRouter ()

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WPNavigationController *rootNavigationController;

@end

@implementation WPRouter

+ (instancetype)sharedInstance
{
    return _sharedInstance;
}

+ (void)setSharedInstance:(WPRouter *)instance
{
    _sharedInstance = instance;
}

- (instancetype)initWithWindow:(UIWindow *)window
{
    NSParameterAssert(window);
    
    self = [super init];
    if (self) {
        self.window = window;
        self.rootNavigationController = [WPNavigationController new];
        self.window.rootViewController = self.rootNavigationController;
    }
    
    return self;
}

#pragma mark - Private methods

- (RACSignal *)setRootViewController:(UIViewController *)viewController viewModel:(WPViewModel *)viewModel navigationController:(WPNavigationController *)navigationController
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        @weakify(navigationController);
        viewModel.closeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(navigationController);
            NSCAssert([navigationController.viewControllers firstObject] == viewController, @"the root view controller should be `viewController`");
            
            [navigationController setViewControllers:@[] animated:NO];
            [subscriber sendCompleted];
            
            return nil;
        }];
        
        [navigationController setViewControllers:@[ viewController ] animated:NO];
        [subscriber sendCompleted];
        
        return nil;
    }];
}

- (RACSignal *)pushViewController:(UIViewController *)viewController viewModel:(WPViewModel *)viewModel navigationController:(WPNavigationController *)navigationController animated:(BOOL)animated
{
    return [RACSignal defer:^RACSignal *{
        
        if ([navigationController.viewControllers count] == 0) {
            return [self setRootViewController:viewController viewModel:viewModel navigationController:navigationController];
        }
        
        @weakify(navigationController);
        viewModel.closeSignal = [RACSignal defer:^RACSignal *{
            @strongify(navigationController);
            NSCAssert([navigationController.viewControllers lastObject] == viewController, @"last object of `viewControllers` should be `viewController`");
            
            return [navigationController rac_popViewControllerAnimated:YES];
        }];
        
        return [navigationController rac_pushViewController:viewController animated:animated];
    }];
}

@end

#pragma mark - Protected methods

@implementation WPRouter (Protected)

- (RACSignal *)setRootViewController:(UIViewController *)viewController viewModel:(WPViewModel *)viewModel
{
    return [RACSignal
        defer:^RACSignal *{
            return [self setRootViewController:viewController viewModel:viewModel navigationController:self.rootNavigationController];
        }];
}

- (RACSignal *)pushViewController:(UIViewController *)viewController viewModel:(WPViewModel *)viewModel animated:(BOOL)animated
{
    return [RACSignal
        defer:^RACSignal *{
            return [self pushViewController:viewController viewModel:viewModel navigationController:self.rootNavigationController animated:animated];
        }];
}

- (RACSignal *)presentViewController:(UIViewController *)viewController viewModel:(WPViewModel *)viewModel animated:(BOOL)animated
{
    return [RACSignal defer:^RACSignal *{
        viewModel.closeSignal = [viewController rac_dismissViewControllerAnimated:YES];
        return [self.rootNavigationController rac_presentViewController:viewController animated:YES];
    }];
}

@end
