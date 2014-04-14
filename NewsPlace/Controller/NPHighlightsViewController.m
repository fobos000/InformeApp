//
//  NPHighlightsViewController.m
//  NewsPlace
//
//  Created by Ostap Horbach on 3/28/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "NPHighlightsViewController.h"
#import "SNArticleViewController.h"

#import "MFSideMenu.h"
#import "NPSideMenuViewController.h"

#import "NPDataLoader.h"
#import "SNHeadlineTableViewCell.h"
#import "Article.h"
#import "ArticleCategory.h"

static int categoryContext;
static int sourcesContext;

@interface NPHighlightsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) SNHeadlineTableViewCell *prototypeCell;

@property (nonatomic, strong) ArticleCategory *category;
@property (nonatomic, strong) NSArray *sources;

@end

@implementation NPHighlightsViewController

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
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(category))
              options:0 context:&categoryContext];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(sources))
              options:0 context:&sourcesContext];
    
    self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"SNHeadlineCell"];
    
    [self prepareFetchResultsController];
    [self refresh];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self
                action:@selector(refresh)
      forControlEvents:UIControlEventValueChanged];
    
    
    self.refreshControl = refresh;
}

- (void)prepareFetchResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"Article"];
    
    NSPredicate *pr;
    
    NSPredicate *sourcesPred = nil;
    if (self.sources) {
        sourcesPred = [NSPredicate predicateWithFormat:@"sourceId in %@", [self.sources valueForKey:@"serverId"]];
    }
    
    NSPredicate *categoryPred = nil;
    if (self.category) {
        categoryPred = [NSPredicate predicateWithFormat:@"categoryId = %@", self.category.serverId];
    }
    
    NSMutableArray *predicates = [NSMutableArray array];
    if (sourcesPred) {
        [predicates addObject:sourcesPred];
    }
    if (categoryPred) {
        [predicates addObject:categoryPred];
    }
    
    if (predicates.count) {
        pr = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    }
    
    fetchRequest.predicate = pr;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                   ascending:NO]];
    
    if (!self.frc) {
        self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                       managedObjectContext:self.context
                                                         sectionNameKeyPath:nil
                                                                  cacheName:nil];
        self.frc.delegate = self;
    }
    
    self.frc.fetchRequest.predicate = pr;
    [self.frc performFetch:nil];
}

- (void)refresh
{
    [NPDataLoader loadDataWithBlock:^(BOOL success) {
        [self endRefreshing];
    }];
}

- (void)endRefreshing
{
    [self.refreshControl endRefreshing];
}

#pragma mark - Side menu

- (IBAction)showSideMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}


#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int n = self.frc.sections.count;
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    int n = [self.frc.sections[section] numberOfObjects];
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SNHeadlineCell"
                                                            forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(SNHeadlineTableViewCell *)cell withItem:(Article *)artcle
{
    cell.headlineLabel.text = [artcle.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.dateLabel.text = artcle.formattedDate;
    cell.sourceLabel.text = artcle.sourceName;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:(SNHeadlineTableViewCell *)cell
               withItem:[self.frc objectAtIndexPath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNHeadlineTableViewCell *cell = self.prototypeCell;
    
    [self configureCell:cell withItem:[self.frc objectAtIndexPath:indexPath]];
    [cell layoutSubviews];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height + 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowArticle" sender:self];
//    [self expandArticleAtIndexPath:indexPath];
}

- (void)expandArticleAtIndexPath:(NSIndexPath *)indexPath
{
//    Article *selectedArticle = [self.frc objectAtIndexPath:indexPath];
    SNHeadlineTableViewCell *cell = (SNHeadlineTableViewCell *)[self.tableView
                                                                cellForRowAtIndexPath:indexPath];
    [cell setContent];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    Article *selectedArticle = [self.frc objectAtIndexPath:indexPath];
    
    SNArticleViewController *articleVC = segue.destinationViewController;
    articleVC.article = selectedArticle;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] forRowAtIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark -

- (void)setCategory:(ArticleCategory *)category
{
    _category = category;
}

- (void)setSources:(NSArray *)sources
{
    _sources = sources;
}

- (void)sideMenuDidSelectCategory:(ArticleCategory *)articleCategory
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        self.category = articleCategory;
    }];
}

- (void)sideMenuDidSelectSource:(ArticleSource *)articleSource
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        self.sources = @[articleSource];
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &categoryContext ||
        context == &sourcesContext) {
        self.title = self.category ? self.category.name : NSLocalizedString(@"ALL NEWS", nil);
        [self prepareFetchResultsController];
        [self.tableView reloadData];
        
        NSIndexPath *top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.tableView scrollToRowAtIndexPath:top
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
