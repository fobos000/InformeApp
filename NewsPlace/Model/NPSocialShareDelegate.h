//
//  NPSocialShareDelegate.h
//  NewsPlace
//
//  Created by Ostap Horbach on 7/4/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NPSocialShareDelegate;

@protocol NPSocialShareDelegateDataSource <NSObject>

- (NSString *)textForTwitterForSocialDelegate:(NPSocialShareDelegate *)delegate;
- (NSString *)textForFacebookForSocialDelegate:(NPSocialShareDelegate *)delegate;

@end

@interface NPSocialShareDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, assign) id<NPSocialShareDelegateDataSource> dataSource;

@property (nonatomic, readonly) NSArray *buttonTitles;
@property (nonatomic, assign) UIViewController *presentingController;

@end
