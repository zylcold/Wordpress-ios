//
//  WPPostsResponse.m
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 04/01/15.
//  Copyright (c) 2015 Evgeniy Yurtaev. All rights reserved.
//

#import "WPPostsResponse.h"
#import "WPPost.h"

@implementation WPPostsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
        @keypath([WPPostsResponse new], found) : @"found",
        @keypath([WPPostsResponse new], posts) : @"posts",
    };
}

+ (NSValueTransformer *)postsJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *value, BOOL *success, NSError **errorInfo) {
        if (![value isKindOfClass:[NSArray class]]) {
            return nil;
        }
        
        NSError *error;
        NSArray *result = [MTLJSONAdapter modelsOfClass:[WPPost class] fromJSONArray:value error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        
        return result;
        
    } reverseBlock:^id(NSArray *value, BOOL *success, NSError **error) {
        if (!value) {
            return nil;
        }
        return [MTLJSONAdapter JSONArrayFromModels:value error:nil];
    }];
}

@end

@implementation WPPostsResponse (Paginating)

- (NSArray *)objects
{
    return self.posts;
}

- (NSNumber *)totalObjects
{
    return self.found;
}

@end
