//
//  NPSourceTableViewCell.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/19/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPSourceTableViewCell.h"

@implementation NPSourceTableViewCell

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    if (_switchBlock) {
        _switchBlock(sender.on);
    }
}

@end
