//
//  NPAAPIClient.h
//  NewsPlace
//
//  Created by Ostap Horbach on 3/28/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface NPAAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
