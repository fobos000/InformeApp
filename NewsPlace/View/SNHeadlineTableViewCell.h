//
//  SNHeadlineTableViewCell.h
//  SuperNews
//
//  Created by Ostap Horbach on 3/7/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNHeadlineTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;

- (void)setContent;

@end
