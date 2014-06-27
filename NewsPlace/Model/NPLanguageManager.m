//
//  NPLanguageManager.m
//  NewsPlace
//
//  Created by Ostap Horbach on 6/26/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPLanguageManager.h"

static NSString * const kLanguagePreference = @"language";

@implementation NPLanguageManager

static NSArray *sLanguages = nil;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NPLanguage *ukrainian = [[NPLanguage alloc] initWithName:@"Ukrainian"
                                                       shortName:@"UK"];
        NPLanguage *russian = [[NPLanguage alloc] initWithName:@"Russian"
                                                     shortName:@"RU"];
        
        sLanguages = @[ukrainian, russian];
        [self setCurrentLanguage:ukrainian];
    });
}

+ (NSArray *)languages
{
    return sLanguages;
}

NSUserDefaults * userDefaults()
{
    return [NSUserDefaults standardUserDefaults];
}

NPLanguage * languageByShortName(NSString *shortName)
{
    NPLanguage *languageByShortName = nil;
    
    for (NPLanguage *language in sLanguages) {
        if ([language.shortName isEqualToString:shortName]) {
            languageByShortName = language;
        }
    }
    
    return languageByShortName;
}

+ (void)setCurrentLanguage:(NPLanguage *)currentLanguage
{
    [userDefaults() setObject:currentLanguage.shortName
                       forKey:kLanguagePreference];
    [userDefaults() synchronize];
}

+ (NPLanguage *)currentLanguage
{
    NSString *languageShortName = [userDefaults() stringForKey:kLanguagePreference];
    NPLanguage *language = languageByShortName(languageShortName);
    NSAssert(language != nil, @"Language error");
    return language;
}

@end
