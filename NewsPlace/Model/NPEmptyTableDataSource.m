//
//  NPEmptyTableDataSource.m
//  NewsPlace
//
//  Created by Ostap Horbach on 5/10/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPEmptyTableDataSource.h"

@implementation NPEmptyTableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"NoNewsCell"
                                           forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CGRectGetHeight(tableView.frame);
}

@end
