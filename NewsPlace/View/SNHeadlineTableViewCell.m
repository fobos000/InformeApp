//
//  SNHeadlineTableViewCell.m
//  SuperNews
//
//  Created by Ostap Horbach on 3/7/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "SNHeadlineTableViewCell.h"

@implementation SNHeadlineTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContent
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor grayColor];
    view.frame = self.frame;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_dateLabel, view);
    NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[1]-10-[view]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDictionary];
    
    [self.contentView addSubview:view];
    [self.contentView addConstraints:c1];
}

@end
