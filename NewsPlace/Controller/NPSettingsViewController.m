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
#import "NPLanguageManager.h"

typedef enum : NSUInteger {
    SourcesSettingsSection,
    LanguageSettingsSection,
    SettingsSectionCount
} SettingsSection;

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SourcesSettingsSection:
            return self.sources.count;
        
        case LanguageSettingsSection:
            return [NPLanguageManager languages].count;
        
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SourcesSettingsSection:
            return [self sourceCellForIndexPath:indexPath];
        
        case LanguageSettingsSection:
            return [self languageCellForIndexPath:indexPath];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)sourceCellForIndexPath:(NSIndexPath *)indexPath
{
    NPSourceTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SourceCell"
                                                                       forIndexPath:indexPath];
    ArticleSource *source = self.sources[indexPath.row];
    
    cell.sourceLabel.text = source.name;
    cell.activeSwitch.on = source.active;
    cell.switchBlock = ^(BOOL active) {
        source.active = active;
    };
    
    return cell;
}

- (UITableViewCell *)languageCellForIndexPath:(NSIndexPath *)indexPath
{
    NPSourceTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LanguageCell"
                                                                       forIndexPath:indexPath];
    NPLanguage *language = [NPLanguageManager languages][indexPath.row];
    
    cell.textLabel.text = language.name;
    if (language == [NPLanguageManager currentLanguage]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SourcesSettingsSection:
            return NSLocalizedString(@"Source", nil);
        case LanguageSettingsSection:
            return NSLocalizedString(@"Language", nil);
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == LanguageSettingsSection) {
        NPLanguage *selectedLanguage = [NPLanguageManager languages][indexPath.row];
        [NPLanguageManager setCurrentLanguage:selectedLanguage];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                 withRowAnimation:UITableViewRowAnimationNone];
    }
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
        }
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kSettingsUpdatedNotification object:nil];
    }
}


@end
