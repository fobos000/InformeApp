//
//  NPSourceTableViewCell.h
//  NewsPlace
//
//  Created by Ostap Horbach on 4/19/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActiveSwitchBlock)(BOOL active);

@interface NPSourceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *activeSwitch;

@property (nonatomic, strong) ActiveSwitchBlock switchBlock;

@end
