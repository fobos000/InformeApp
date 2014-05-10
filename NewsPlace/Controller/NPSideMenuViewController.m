//
//  NPSideMenuViewController.m
//  NewsPlace
//
//  Created by Ostap Horbach on 4/6/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPSideMenuViewController.h"
#import "NSManagedObject+Fetching.h"
#import "ArticleSource.h"
#import "ArticleCategory.h"
#import "NPSettingsViewController.h"

typedef enum {
    SideMenuSectionCategory,
    SideMenuSectionMax
} SideMenuSection;

@interface NPSideMenuViewController ()

@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSArray *sources;

@end

@implementation NPSideMenuViewController

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
    NSMutableArray *categories = [NSMutableArray arrayWithObject:NSLocalizedString(@"ALL NEWS", nil)];
    self.categories = [[categories arrayByAddingObjectsFromArray:
                       [ArticleCategory allObjectsInContext:self.context]] mutableCopy];
    self.sources = [ArticleSource allObjectsInContext:self.context];
}

- (void)updatedContext
{
    [self updateDataSource];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SideMenuSectionMax;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SideMenuSectionCategory:
            return self.categories.count;
            break;
        default:
            break;
    }

    return 0;
}

- (void)configureCategoryCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        cell.textLabel.text = self.categories.firstObject;
        return;
    }
    
    ArticleCategory *category = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = category.name;
}

- (void)configureSourceCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ArticleSource *source = [self.sources objectAtIndex:indexPath.row];
    cell.textLabel.text = source.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case SideMenuSectionCategory:
            cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"
                                                   forIndexPath:indexPath];
            [self configureCategoryCell:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SideMenuSectionCategory:
            [self selectCategoryAtIndexPath:indexPath];
            break;
        default:
            break;
    }
}

- (void)selectCategoryAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.delegate sideMenuDidSelectCategory:nil];
        return;
    }
    
    [self.delegate sideMenuDidSelectCategory:self.categories[indexPath.row]];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SettingsSegue"]) {
        UINavigationController *nc = segue.destinationViewController;
        NPSettingsViewController *settingsVC = (NPSettingsViewController *)nc.topViewController;
        settingsVC.context = self.context;
    }
}

- (IBAction)unwindFromSettings:(UIStoryboardSegue *)unwindSegue
{
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
