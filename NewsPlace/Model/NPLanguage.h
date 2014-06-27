//
//  NPLanguage.h
//  NewsPlace
//
//  Created by Ostap Horbach on 6/26/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPLanguage : NSObject

@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, readonly) NSString *name;

- (id)initWithName:(NSString *)name shortName:(NSString *)shortName;

@end
