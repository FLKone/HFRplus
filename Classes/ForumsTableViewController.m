//
//  ForumsTableViewController.m
//  HFRplus
//
//  Created by FLK on 06/07/10.
//

#import "HFRplusAppDelegate.h"

#import "ForumsTableViewController.h"
#import "TopicsTableViewController.h"

#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "ShakeView.h"

#import "Forum.h"

#import "ASIHTTPRequest.h"

@implementation ForumsTableViewController
@synthesize request;
@synthesize forumsTableView, loadingView, arrayData, arrayNewData, topicsTableViewController;
@synthesize status, statusMessage, maintenanceView;
#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{    
    NSLog(@"cancelFetchContent");

    self.forumsTableView.pullTableIsRefreshing = NO;

    
    //[self.request cancel];
}

- (void)fetchContent
{
    NSLog(@"fetchContent");

    
    if(!self.forumsTableView.pullTableIsRefreshing) {
        self.forumsTableView.pullTableIsRefreshing = YES;
    }
    
	//Bouton Stop
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"stop" title:@"" target:self action:@selector(cancelFetchContent)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;
    
	self.status = kIdle;	

    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];    
    
    [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:kForumURL]]];
    [request setDelegate:self];
    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentComplete:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];
    [request setShowAccurateProgress:YES];
    [request setDownloadProgressDelegate:self];
    
    [request startAsynchronous];

    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:YES];
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    //NSLog(@"bytes %lld", bytes);
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentStarted");

    //[self.arrayData removeAllObjects];
	//[self.forumsTableView reloadData];
    
	//[self.maintenanceView setHidden:YES];
	//[self.loadingView setHidden:NO];
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{    
    NSLog(@"fetchContentComplete %lld", [theRequest contentLength]);
     //[theRequest siz]
    
	//Bouton Reload
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"reload" title:@"" target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;
    
    //[self.loadingView setHidden:YES];
	
    [self loadDataInTableView:[theRequest responseData]];
    
    [self.arrayData removeAllObjects];
    
    self.arrayData = [NSMutableArray arrayWithArray:self.arrayNewData];
    
    [self.arrayNewData removeAllObjects];
    
	[self.forumsTableView reloadData];
    
    self.forumsTableView.pullLastRefreshDate = [NSDate date];
    self.forumsTableView.pullTableIsRefreshing = NO;
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{        
    NSLog(@"fetchContentFailed");
    
    //Bouton Reload
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"reload" title:@"" target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;
	
	[self.loadingView setHidden:YES];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert show];
	[alert release];
    
    self.forumsTableView.pullTableIsRefreshing = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self fetchContent];
	}
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    NSLog(@"pullTableViewDidTriggerRefresh");
    
    [self performSelector:@selector(fetchContent)];
}

#pragma mark -
#pragma mark View lifecycle

-(void)loadDataInTableView:(NSData *)contentData
{    
    NSLog(@"loadDataInTableView");
    
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];
	
	NSArray *temporaryForumsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cat" allowPartial:YES];

	if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
		self.status = kMaintenance;
		self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[myParser release];
        

          [self.maintenanceView setText:self.statusMessage];
          [self.maintenanceView setHidden:NO];
    
		return;
	}

	for (HTMLNode * forumNode in temporaryForumsArray) {

		if (![[forumNode tagName] isEqualToString:@"tr"]) {
			continue;
		}
		
		NSArray *temporaryForumArray = [forumNode findChildTags:@"td"];


		Forum *aForum = [[Forum alloc] init];
		
		
		//Title
		HTMLNode * topicNode = [temporaryForumArray objectAtIndex:1];		
		NSString *aForumTitle = [[NSString alloc] initWithString:[[[topicNode findChildTag:@"b"] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		[aForum setATitle:aForumTitle];
		[aForumTitle release];

		//URL
		NSString *aForumURL = [[NSString alloc] initWithString:[[topicNode findChildWithAttribute:@"class" matchingName:@"cCatTopic" allowPartial:YES] getAttributeNamed:@"href"]];
		
		if ([aForumURL isEqualToString:@"/hfr/AchatsVentes/Hardware/liste_sujet-1.htm"]) {
			[aForum setAURL:@"/hfr/AchatsVentes/liste_sujet-1.htm"];
		}
		else {
			[aForum setAURL:aForumURL];
		}
	
		// Sous categories
		NSArray *temporaryCatsArray = [topicNode findChildrenWithAttribute:@"class" matchingName:@"Tableau" allowPartial:NO];
		if ([temporaryCatsArray count] > 0) {
			NSMutableArray *tmpSubCatArray = [[NSMutableArray alloc] init];
			
			Forum *aSubForum = [[Forum alloc] init];
			
			//Title
			[aSubForum setATitle:[aForum aTitle]];
			
			//URL
			[aSubForum setAURL:[aForum aURL]];
			
			[tmpSubCatArray addObject:aSubForum];
			
			[aSubForum release];	

			
			for (HTMLNode * subForumNode in temporaryCatsArray) {
				Forum *aSubForum = [[Forum alloc] init];

				//Title
				NSString *aSubForumTitle = [[NSString alloc] initWithString:[[subForumNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
				[aSubForum setATitle:aSubForumTitle];
				[aSubForumTitle release];

				//URL
				NSString *aSubForumURL = [[NSString alloc] initWithString:[subForumNode getAttributeNamed:@"href"]];
				[aSubForum setAURL:aSubForumURL];
				[aSubForumURL release];
				
                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/API-Win32/liste_sujet-1.htm"]) {
                    Forum *aSubForum2;
                    NSString *aSubForum2Title;
                    NSString *aSubForum2URL;
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Divers"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Divers-6/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"ADA"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/ADA/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];	
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Algo"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Algo/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];                    
                    
                }                    
                
				[tmpSubCatArray addObject:aSubForum];                

                if ([aSubForum.aURL isEqualToString:@"/hfr/Hardware/minipc/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Bench"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Hardware/Benchs/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		

                }                
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/OverclockingCoolingModding/Mod-elec/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Divers"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/OverclockingCoolingModding/Divers-8/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }                 
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/Photonumerique/Galerie-Perso/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Divers"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Photonumerique/Divers-7/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }                
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/WindowsSoftware/Windows-nt-2k-xp/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Win 9x/Me"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/WindowsSoftware/Win-9x-me/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }             

                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/API-Win32/liste_sujet-1.htm"]) {
                    Forum *aSubForum2;
                    NSString *aSubForum2Title;
                    NSString *aSubForum2URL;
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"ASM"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/ASM/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"ASP"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/ASP/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];	
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Biblio Links"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/BiblioLinks/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];    
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"C"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/C/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];                     
                    
                } 
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/C-2/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"C#/.NET managed"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/CNET-managed/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }

                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/Delphi-Pascal/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Flash/ActionScript"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Flash-ActionScript/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }                

                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/Java/liste_sujet-1.htm"]) {
                    Forum *aSubForum2;
                    NSString *aSubForum2Title;
                    NSString *aSubForum2URL;
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Langages fonctionnels"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Langages-fonctionnels/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"PDA"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/PDA/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];	
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Perl"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Perl/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];                        
                    
                }

                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/PHP/liste_sujet-1.htm"]) {
                    Forum *aSubForum2;
                    NSString *aSubForum2Title;
                    NSString *aSubForum2URL;
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Python"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Python/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Ruby/Rails"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Ruby/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];	                       
                    
                }

                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/SGBD-SQL/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Shell/Batch"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/Shell-Batch/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }   
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/Programmation/VB-VBA-VBS/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"XML/XSL"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Programmation/XML-XSL/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }   
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/Graphisme/Arts-traditionnels/liste_sujet-1.htm"]) {
                    Forum *aSubForum2;
                    NSString *aSubForum2Title;
                    NSString *aSubForum2URL;
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Concours"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Graphisme/Concours-2/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Ressources"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Graphisme/Ressources/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];	
                    
                    aSubForum2 = [[Forum alloc] init];
                    
                    //Title
                    aSubForum2Title = [[NSString alloc] initWithString:@"Divers"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/Graphisme/Divers-5/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];                    
                    
                    [aSubForum2 release];                        
                    
                }                
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/AchatsVentes/Softs-livres/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Divers"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/AchatsVentes/Divers-4/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }      
                
                if ([aSubForum.aURL isEqualToString:@"/hfr/AchatsVentes/Feedback/liste_sujet-1.htm"]) {
                    Forum *aSubForum2= [[Forum alloc] init];
                    
                    //Title
                    NSString *aSubForum2Title = [[NSString alloc] initWithString:@"Règles et coutumes"];
                    [aSubForum2 setATitle:aSubForum2Title];
                    [aSubForum2Title release];
                    
                    //URL
                    NSString *aSubForum2URL = [[NSString alloc] initWithString:@"/hfr/AchatsVentes/Regles-coutumes/liste_sujet-1.htm"];
                    [aSubForum2 setAURL:aSubForum2URL];
                    [aSubForum2URL release];
                    
                    [tmpSubCatArray addObject:aSubForum2];     
                    
                    [aSubForum2 release];		
                    
                }                
                
                
				[aSubForum release];		

                

			}
			
			[aForum setSubCats:tmpSubCatArray];

			[tmpSubCatArray release];
		}
		//--- Sous categories

		if ([aForumURL rangeOfString:@"cat=prive"].location == NSNotFound) {
			[arrayNewData addObject:aForum];
		}
		else {
			NSString *regExMP = @"[^.0-9]+([0-9]{1,})[^.0-9]+";			
			NSString *myMPNumber = [[[topicNode findChildWithAttribute:@"class" matchingName:@"cCatTopic" allowPartial:YES] contents] stringByReplacingOccurrencesOfRegex:regExMP
																  withString:@"$1"];
			
			[[HFRplusAppDelegate sharedAppDelegate] updateMPBadgeWithString:myMPNumber];
		}
		[aForumURL release];

		[aForum release];		

	}
	
	[myParser release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.title = @" ";
    //UIImage *image = [[UIImage imageNamed:@"categories"] offColor];
    //self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:image] autorelease];
    
    [self.forumsTableView setRowHeight:kTableViewCellRowHeight];
    //[self.forumsTableView setSeparatorColor:[UIColor redColor]];
    [self.forumsTableView setSeparatorColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_dot_a"]]];
    
    //Bouton Reload
    UIBarButtonItem *reloadBarItem = [UIBarButtonItem barItemWithImageNamed:@"reload" title:@"" target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = reloadBarItem;
    
    //Bouton Settings/More
    UIBarButtonItem *settingsBarItem = [UIBarButtonItem barItemWithImageNamed:@"more" title:@"" target:self action:@selector(settings)];
	self.navigationItem.leftBarButtonItem = settingsBarItem;
    
	[(ShakeView*)self.view setShakeDelegate:self];

	self.arrayData = [[NSMutableArray alloc] init];
	self.arrayNewData = [[NSMutableArray alloc] init];
	self.statusMessage = [[NSString alloc] init];

    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.forumsTableView setTableFooterView:v];
    [v release];
    
	[self fetchContent];
    
}

- (void)viewWillAppear:(BOOL)animated {
	//NSLog(@"viewWillAppear Forums Table View");

	
    [super viewWillAppear:animated];
	//[self.view becomeFirstResponder];

	if (self.topicsTableViewController) {
		//NSLog(@"viewWillAppear Forums Table View RELEASE %@", topicsTableViewController);

		//self.topicsTableViewController = nil;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	[self.view resignFirstResponder];

	[forumsTableView deselectRowAtIndexPath:forumsTableView.indexPathForSelectedRow animated:NO];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	//NSLog(@"Count Forums Table View: %d", arrayData.count);
	
    return arrayData.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_dot_a"]]];
        [cell setSelectedBackgroundView:bgColorView];
        [bgColorView release];
        
		//cell.accessoryView = [[ UIImageView alloc ]
        //                        initWithImage:[UIImage imageNamed:@"accessoryDefault"]];
        
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [[arrayData objectAtIndex:indexPath.row] aTitle]];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//NSLog(@"did Select row forum table views");
    
    self.topicsTableViewController = nil;
    
	if (self.topicsTableViewController == nil) {
		TopicsTableViewController *aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil];
		self.topicsTableViewController = aView;
		[aView release];
	}
	
	self.topicsTableViewController.forumBaseURL = [[arrayData objectAtIndex:indexPath.row] aURL];	
	self.topicsTableViewController.forumName = [[arrayData objectAtIndex:indexPath.row] aTitle];	
	self.topicsTableViewController.pickerViewArray = [[arrayData objectAtIndex:indexPath.row] subCats];	

	[self.navigationController pushViewController:topicsTableViewController animated:YES];

}

#pragma mark -
#pragma mark NavigationBar Action

-(void)settings {
    
    InfosViewController *infosViewController = [[InfosViewController alloc] init];
    
	[self.navigationController pushViewController:infosViewController animated:YES];

    
    [infosViewController release];
    
}

-(void)reload
{
	[self reload:NO];
}

-(void)reload:(BOOL)shake
{
	if (!shake) {

	}

	[self fetchContent];
}


-(void) shakeHappened:(ShakeView*)view
{
	if (![request isExecuting]) {

		[self reload:YES];		
	}
}

#pragma mark -
#pragma mark Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	//NSLog(@"viewDidUnload forums");
	
	self.forumsTableView = nil;
	self.loadingView = nil;	
	self.maintenanceView = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
	//NSLog(@"dealloc Forums Table View");
	[self viewDidUnload];

	self.arrayData = nil;
	self.arrayNewData = nil;

	[request cancel];
	//[request setDelegate:nil];
	self.request = nil;

	self.statusMessage = nil;
	
	if (self.topicsTableViewController) {
		self.topicsTableViewController = nil;
	}
	
    [super dealloc];

}

@end