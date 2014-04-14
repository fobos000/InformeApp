//
//  NPDateParser.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/4/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPDateParser.h"

@implementation NPDateParser

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat
{
    static NSDateFormatter *sDateFormatter = nil;
    if (sDateFormatter == nil) {
        sDateFormatter = [[NSDateFormatter alloc] init];
    }
    
    sDateFormatter.dateFormat = dateFormat;
    
    NSDate *dateFromString = [sDateFormatter dateFromString:dateString];
    return dateFromString;
}

@end
