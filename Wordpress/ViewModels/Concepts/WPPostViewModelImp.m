//
//  WPPostViewModelImp.m
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 20/04/15.
//  Copyright (c) 2015 Evgeniy Yurtaev. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>

#import "WPPostViewModelImp.h"
#import "WPPostStateImp.h"
#import "WPPost.h"
#import "WPStateMachineImp.h"
#import "WPClient.h"
#import "WPGetPostRequest.h"

@interface WPPostViewModel ()

@property (strong, nonatomic) WPPost *post;

@property (strong, nonatomic) WPStateMachine *stateMachine;

@end

@implementation WPPostViewModel

- (instancetype)init
{
    return [self initWithPost:nil];
}

- (instancetype)initWithPost:(WPPost *)post
{
    NSParameterAssert(post);

    self = [super init];
    if (self) {
        self.post = post;
        self.stateMachine = [[WPStateMachine alloc] initWithStartState:[WPPostState emptyState]];
    }

    return self;
}

- (RACSignal *)state
{
    return self.stateMachine.stateChanged;
}

- (RACSignal *)prepareForUse
{
    return [[RACSignal
        defer:^RACSignal *{
            WPGetPostRequest *request = [[WPGetPostRequest alloc] init];
            request.fields = @[ @"ID", @"site_ID", @"author", @"comment_count", @"content", @"URL", @"title" ];
            request.routeObject = self.post;

            return [[WPClient sharedInstance] performRequest:request];
        }]
        flattenMap:^__kindof RACSignal * _Nullable(WPPost *value) {
            return [self.stateMachine pushTransition:^WPPostState*(WPPostState *state) {
                return [state stateBySettingPost:value];
            }];
        }];
}

@end
