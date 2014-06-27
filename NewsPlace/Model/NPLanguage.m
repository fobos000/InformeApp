//
//  NPLanguage.m
//  NewsPlace
//
//  Created by Ostap Horbach on 6/26/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPLanguage.h"

@implementation NPLanguage

- (id)initWithName:(NSString *)name shortName:(NSString *)shortName
{
    self = [super init];
    if (self) {
        _name = name;
        _shortName = shortName;
    }
    return self;
}

@end
