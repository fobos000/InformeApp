//
//  NPHighlightsViewController.h
//  NewsPlace
//
//  Created by Ostap Horbach on 3/28/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPSideMenuViewController.h"

@interface NPHighlightsViewController : UITableViewController <NPSideMenuViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
