//
//  NPSideMenuViewController.h
//  NewsPlace
//
//  Created by Ostap Horbach on 4/6/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ArticleCategory;
@class ArticleSource;

@protocol NPSideMenuViewControllerDelegate <NSObject>

@optional
- (void)sideMenuDidSelectCategory:(ArticleCategory *)articleCategory;
- (void)sideMenuDidSelectSources:(NSArray *)articleSources;

@end

@interface NPSideMenuViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, weak) id <NPSideMenuViewControllerDelegate> delegate;

@end
