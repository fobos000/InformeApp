//
//  NPAAPIClient.m
//  NewsPlace
//
//  Created by Ostap Horbach on 3/28/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPAAPIClient.h"

static NSString * const NPAPIBaseURLString = @"http://supernews.herokuapp.com/outside/";

@implementation NPAAPIClient

+ (instancetype)sharedClient
{
    static NPAAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[NPAAPIClient alloc] initWithBaseURL:[NSURL URLWithString:NPAPIBaseURLString]];
    });
    
    return _sharedClient;
}

@end
