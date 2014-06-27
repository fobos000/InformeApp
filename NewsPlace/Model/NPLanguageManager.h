//
//  NPLanguageManager.h
//  NewsPlace
//
//  Created by Ostap Horbach on 6/26/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPLanguage.h"

@interface NPLanguageManager : NSObject

+ (NPLanguage *)currentLanguage;
+ (void)setCurrentLanguage:(NPLanguage *)currentLanguage;
+ (NSArray *)languages;

@end
