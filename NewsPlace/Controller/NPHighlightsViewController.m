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
#import "ArticleSource.h"
#import "NPNotifications.h"
#import "NSManagedObject+Fetching.h"
#import "NPEmptyTableDataSource.h"
#import "NPLanguageManager.h"

static int categoryContext;
static int sourcesContext;

@interface NPHighlightsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) SNHeadlineTableViewCell *prototypeCell;

@property (nonatomic, strong) ArticleCategory *category;
@property (nonatomic, strong) NSArray *sources;

@property (nonatomic, strong) NPEmptyTableDataSource *emptyTableDataSource;

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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kSettingsUpdatedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self prepareFetchResultsController];
                                                      [self.tableView reloadData];
                                                  }];
    
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(category))
              options:NSKeyValueObservingOptionInitial context:&categoryContext];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(sources))
              options:0 context:&sourcesContext];
    
    self.emptyTableDataSource = [[NPEmptyTableDataSource alloc] init];
    
    self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"SNHeadlineCell"];
    
    [self prepareFetchResultsController];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self
                action:@selector(refresh)
      forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([NPDataLoader sharedInstance].needsUpdate) {
        [self showRefreshControl];
        [self refresh];
    }
}

- (void)prepareFetchResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"Article"];
    
    NSPredicate *pr;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active = 1"];
    NSArray *articleSources = [ArticleSource objectsWithPredicate:predicate
                                                  sortDescriptors:nil
                                                        inContext:self.context];
    NSPredicate *sourcesPred = [NSPredicate predicateWithFormat:@"sourceId in %@", [articleSources valueForKey:@"serverId"]];
    
    
    NSPredicate *categoryPred = nil;
    if (self.category) {
        categoryPred = [NSPredicate predicateWithFormat:@"categoryId = %@", self.category.serverId];
    }
    
    NSPredicate *localePredicate = [NSPredicate predicateWithFormat:@"locale ==[c] %@",
                                    [NPLanguageManager currentLanguage].shortName.lowercaseString];
    
    NSMutableArray *predicates = [NSMutableArray array];
    if (sourcesPred) {
        [predicates addObject:sourcesPred];
    }
    if (categoryPred) {
        [predicates addObject:categoryPred];
    }
    [predicates addObject:localePredicate];
    
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
    
    [self.context performBlockAndWait:^{
        [self.frc performFetch:nil];
    }];
    
    self.tableView.dataSource = [self currentDataSource];
    self.tableView.delegate = [self currentDataSource];
    [self.tableView reloadData];
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

- (void)showRefreshControl
{
    [self.tableView setContentOffset:CGPointMake(0.0f, -60.f)];
    [self.refreshControl beginRefreshing];
}

#pragma mark - Side menu

- (IBAction)showSideMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

#pragma mark - Current data source

- (id<UITableViewDataSource, UITableViewDelegate>)currentDataSource
{
    return [self.frc.sections[0] numberOfObjects] > 0 ?
    self :
    self.emptyTableDataSource;
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
}

- (void)expandArticleAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.tableView.dataSource = [self currentDataSource];
    self.tableView.delegate = [self currentDataSource];
    [self.tableView reloadData];
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

- (void)sideMenuDidSelectSources:(NSArray *)articleSources
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        self.sources = articleSources;
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

@end
