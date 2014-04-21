//
//  NPSettingsViewController.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/19/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPSettingsViewController.h"
#import "ArticleSource.h"
#import "NPSourceTableViewCell.h"
#import "NSManagedObject+Fetching.h"
#import "NPNotifications.h"

@interface NPSettingsViewController ()

@property (nonatomic, strong) NSArray *sources;

@end

@implementation NPSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedContext)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.context];
    [self updateDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)updateDataSource
{
    self.sources = [ArticleSource allObjectsInContext:self.context];
}

- (void)updatedContext
{
    [self updateDataSource];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NPSourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SourceCell" forIndexPath:indexPath];
    
    ArticleSource *source = self.sources[indexPath.row];
    
    cell.sourceLabel.text = source.name;
    cell.activeSwitch.on = source.active;
    cell.switchBlock = ^(BOOL active) {
        source.active = active;
    };
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UnwindSettingsSegue"]) {
        if (self.context.hasChanges) {
            [self.context save:nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kSettingsUpdatedNotification object:nil];
        }
    }
}


@end
