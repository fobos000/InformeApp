//
//  NPSocialShareDelegate.m
//  NewsPlace
//
//  Created by Ostap Horbach on 7/4/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPSocialShareDelegate.h"

typedef enum : NSUInteger {
    FacebookShareOption,
    TwitterShareOption,
} ShareOption;

@interface NPSocialShareDelegate ()

@end

@implementation NPSocialShareDelegate

@synthesize buttonTitles = _buttonTitles;

- (NSArray *)buttonTitles
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _buttonTitles = @[@"Facebook", @"Twitter"];
    });
    return _buttonTitles;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}


@end
