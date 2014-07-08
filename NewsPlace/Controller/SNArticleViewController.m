//
//  SNArticleViewController.m
//  SuperNews
//
//  Created by Ostap Horbach on 3/15/14.
//  Copyright (c) 2014 Ostap Horbach. All rights reserved.
//

#import "SNArticleViewController.h"
#import "NSString+JSONString.h"
#import "NPSocialShareDelegate.h"

@interface SNArticleViewController () <UIWebViewDelegate, UIActionSheetDelegate,
NPSocialShareDelegateDataSource>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) BOOL loadedArticle;
@property (nonatomic, strong) NPSocialShareDelegate *socialShareDelegate;

@end

@implementation SNArticleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    NSString *pageString = [NSString stringWithFormat:[self pageTemplate], self.article.content];
    [self.webView loadHTMLString:pageString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self injectJS];
}

#pragma mark -

- (void)injectJS
{
    [self.webView stringByEvaluatingJavaScriptFromString:[self contentInjectionScript]];
}

- (NSString *)contentInjectionScript
{
    static NSString *__contentInjectionScript = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"javascript" ofType:@"js"];
        __contentInjectionScript = [NSString stringWithContentsOfFile:path
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
    });
    return __contentInjectionScript;
}

- (NSString *)pageTemplate
{
    static NSString *__pageTemplate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HTMLBase" ofType:@"html"];
        __pageTemplate = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    });
    return __pageTemplate;
}

- (void)setArticle:(Article *)article
{
    _article = article;
}

#pragma mark - UIActionSheetDelegate

- (NPSocialShareDelegate *)socialShareDelegate
{
    if (!_socialShareDelegate) {
        _socialShareDelegate = [[NPSocialShareDelegate alloc] init];
        _socialShareDelegate.presentingController = self;
        _socialShareDelegate.dataSource = self;
    }
    return _socialShareDelegate;
}

#pragma NPSocialShareDelegateDataSource

- (NSString *)textForFacebookForSocialDelegate:(NPSocialShareDelegate *)delegate
{
    Article *currentArticle = self.article;
    return [NSString stringWithFormat:@"%@ %@", currentArticle.title,
            currentArticle.sourceLink];
}

- (NSString *)textForTwitterForSocialDelegate:(NPSocialShareDelegate *)delegate
{
    Article *currentArticle = self.article;
    return [NSString stringWithFormat:@"%@ %@", currentArticle.title,
            currentArticle.sourceLink];
}

#pragma mark - IB Actions

- (IBAction)share:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self.socialShareDelegate
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *buttonTitle in self.socialShareDelegate.buttonTitles) {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = self.socialShareDelegate.buttonTitles.count;
    
    [actionSheet showInView:self.view];
}


@end
