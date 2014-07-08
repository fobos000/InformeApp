//
//  NPSocialShareDelegate.m
//  NewsPlace
//
//  Created by Ostap Horbach on 7/4/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPSocialShareDelegate.h"
#import <Social/Social.h>

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
    if (!_buttonTitles) {
        _buttonTitles = @[@"Facebook", @"Twitter"];
    }
    return _buttonTitles;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case FacebookShareOption:
            [self postToFacebook];
            break;
            
        case TwitterShareOption:
            [self postToTwitter];
            break;
            
        default:
            break;
    }
}

#pragma mark -

- (void)presentSocialViewController:(SLComposeViewController *)socialViewController
{
    NSAssert(self.presentingController, @"presentingController should not be nil");
    [self.presentingController presentViewController:socialViewController
                                            animated:YES
                                          completion:nil];
}

- (void)postToTwitter
{
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:[self.dataSource textForTwitterForSocialDelegate:self]];
    [self presentSocialViewController:tweetSheet];
}

- (void)postToFacebook
{
    SLComposeViewController *facebookSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
    [facebookSheet setInitialText:[self.dataSource textForTwitterForSocialDelegate:self]];
    [self presentSocialViewController:facebookSheet];
}

@end
