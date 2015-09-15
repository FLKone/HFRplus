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

#import "UIScrollView+SVPullToRefresh.h"
#import "PullToRefreshErrorViewController.h"

#import "ProfilViewController.h" //test
#import "ForumCellView.h"

@implementation ForumsTableViewController
@synthesize request;
@synthesize forumsTableView, loadingView, arrayData, arrayNewData, topicsTableViewController;
@synthesize status, statusMessage, maintenanceView, metaDataList, pressedIndexPath, forumActionSheet;
@synthesize tmpCell;

#pragma mark -
#pragma mark Test BTN

- (void)testBtn {
    /*
     /hfr/profil-918540.htm //testreview
     /hfr/profil-89386.htm //flk
     
    
    ProfilViewController *profilVC = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil andUrl:@"/hfr/profil-89386.htm"];

    
    // Set options
    profilVC.wantsFullScreenLayout = YES;
    
    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:profilVC];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:nc animated:YES];
    [nc release];
    
    
    [profilVC release];
    
    QuoteMessageViewController *quoteMessageViewController = [[QuoteMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];

    [quoteMessageViewController setUrlQuote:@"http://forum.hardware.fr/message.php?config=hfr.inc&cat=25&post=1711&numrep=537060&ref=0&page=308&p=1&subcat=0&sondage=0&owntopic=1&new=0#formulaire"];
    
    // Create the navigation controller and present it modally.
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:quoteMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
    
    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
    [navigationController release];
    [quoteMessageViewController release];
    */
}

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{    
    NSLog(@"cancelFetchContent");

    [self.request cancel];
}

- (void)fetchContent
{
	self.status = kIdle;	

    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];    
    
    [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:kForumURL]]];
    [request setDelegate:self];
    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentComplete:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];
    
    [request startAsynchronous];

}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentStarted");
    
	//Bouton Stop
	self.navigationItem.rightBarButtonItem = nil;	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelFetchContent)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];	
/*
    [self.arrayData removeAllObjects];
	[self.forumsTableView reloadData];
    
	[self.maintenanceView setHidden:YES];
	[self.loadingView setHidden:NO];
    */
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{    
    //NSLog(@"fetchContentComplete");

    
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
    
    //[self.loadingView setHidden:YES];
    //[self.maintenanceView setHidden:YES];
	
    [self loadDataInTableView:[theRequest responseData]];
    
    [self.arrayData removeAllObjects];
    
    //NSLog(@"self.arrayNewData %@", self.arrayNewData);
    
    self.arrayData = [NSMutableArray arrayWithArray:self.arrayNewData];
    
    [self.arrayNewData removeAllObjects];
    
	[self.forumsTableView reloadData];
    //[self.forumsTableView setHidden:NO];
    
    [self.forumsTableView.pullToRefreshView stopAnimating];
    [self.forumsTableView.pullToRefreshView setLastUpdatedDate:[NSDate date]];

}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{        
    //NSLog(@"fetchContentFailed");
    
    //Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
	
    [self.maintenanceView setText:@"oops :o"];
    
    //[self.loadingView setHidden:YES];
    //[self.maintenanceView setHidden:NO];
    //[self.forumsTableView setHidden:YES];
    
    [self.forumsTableView.pullToRefreshView stopAnimating];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert show];
	[alert release];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self.forumsTableView triggerPullToRefresh];
	}
}

#pragma mark -
#pragma mark View lifecycle

-(void)loadDataInTableView:(NSData *)contentData
{    
    //NSLog(@"loadDataInTableView");
    
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];
	
	NSArray *temporaryForumsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cat" allowPartial:YES];

	if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
        
        
        NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:   [NSNumber numberWithInt:kMaintenance], @"status",
                               [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"message", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusChangedNotification object:self userInfo:notif];

		[myParser release];

    
		return;
	}

    //check if user is logged in
    
    BOOL isLogged = false;
    HTMLNode * hashCheckNode = [bodyNode findChildWithAttribute:@"name" matchingName:@"hash_check" allowPartial:NO];
    if (hashCheckNode && ![[hashCheckNode getAttributeNamed:@"value"] isEqualToString:@""]) {
        //hash = logginé :o
        isLogged = true;
    }
    //-- check if user is logged in
    
    //NSLog(@"login = %d", isLogged);
    
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
        
        
        //censure Apple :o
        if (!isLogged && [aForumTitle isEqualToString:@"Apple"]) {
            // bah on fait rien ! :o
        }
        else
        {
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
        }
        
		[aForumURL release];

		[aForum release];		

	}
	
	[myParser release];
}

-(void)StatusChanged:(NSNotification *)notification {
    
    if ([[notification object] class] != [self class]) {
        //NSLog(@"KO");
        return;
    }
    
    NSDictionary *notif = [notification userInfo];
    
    self.status = [[notif valueForKey:@"status"] intValue];
    
    //NSLog(@"StatusChanged %d = %u", self.childViewControllers.count, self.status);
    
    //on vire l'eventuel header actuel
    if (self.childViewControllers.count > 0) {
        [[self.childViewControllers objectAtIndex:0] removeFromParentViewController];
        self.forumsTableView.tableHeaderView = nil;
    }
    
    if (self.status == kComplete || self.status == kIdle) {
        //NSLog(@"COMPLETE %d", self.childViewControllers.count);
        
    }
    else
    {
        PullToRefreshErrorViewController *ErrorVC = [[PullToRefreshErrorViewController alloc] initWithNibName:nil bundle:nil andDico:notif];
        [self addChildViewController:ErrorVC];
        
        self.forumsTableView.tableHeaderView = ErrorVC.view;
        [ErrorVC sizeToFit];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
	self.title = @"Catégories";
    self.navigationController.navigationBar.translucent = NO;

    self.metaDataList = [[NSMutableDictionary alloc] init];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *metaList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:FORUMSMETA_FILE]];
    
    if ([fileManager fileExistsAtPath:metaList]) {
        self.metaDataList = [NSMutableDictionary dictionaryWithContentsOfFile:metaList];
    }
    else {
        [self.metaDataList removeAllObjects];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(StatusChanged:)
                                                 name:kStatusChangedNotification
                                               object:nil];
    
	//Bouton Reload
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];	

    /*
    // test BTN
	UIBarButtonItem *segmentBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(testBtn)];
	self.navigationItem.leftBarButtonItem = segmentBarItem2;
    [segmentBarItem2 release];
    */
    
	[(ShakeView*)self.view setShakeDelegate:self];

	self.arrayData = [[NSMutableArray alloc] init];
	self.arrayNewData = [[NSMutableArray alloc] init];
	self.statusMessage = [[NSString alloc] init];


    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.forumsTableView setTableFooterView:v];
    [v release];
    
    [self.forumsTableView addPullToRefreshWithActionHandler:^{
        //NSLog(@"=== BEGIN");
        [self fetchContent];
        //NSLog(@"=== END");
    }];
    
    [self.forumsTableView triggerPullToRefresh];
    
	//[self fetchContent];
}

- (void)viewWillAppear:(BOOL)animated {
	//NSLog(@"viewWillAppear Forums Table View");

	
    [super viewWillAppear:animated];
	[self.view becomeFirstResponder];

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
    
    static NSString *CellIdentifier = @"ForumCellID";
    
    ForumCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"ForumCellView" owner:self options:nil];
        cell = tmpCell;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                             initWithTarget:self action:@selector(handleLongPress:)];
        [cell addGestureRecognizer:longPressRecognizer];
        [longPressRecognizer release];
        
        self.tmpCell = nil;
    }

    
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", [[arrayData objectAtIndex:indexPath.row] aTitle]];
    [cell.catImage setImage:[UIImage imageNamed:[[arrayData objectAtIndex:indexPath.row] getImage]]];
    
    if ([self.metaDataList objectForKey:[[arrayData objectAtIndex:indexPath.row] aURL]]) {
        
        NSDictionary *tmpDic = [self.metaDataList objectForKey:[[arrayData objectAtIndex:indexPath.row] aURL]];
        
        switch ([[tmpDic objectForKey:@"flag"] intValue]) {
            case kFav:
                cell.flagLabel.text = @"Favoris";
                break;
            case kFlag:
                cell.flagLabel.text = @"Suivis";
                break;
            case kRed:
                cell.flagLabel.text = @"Lus";
                break;
            case kALL:
            default:
                cell.flagLabel.text = @"";
                break;
        }
    }
    else {
        cell.flagLabel.text = @"";
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//NSLog(@"did Select row forum table views");
    
    self.topicsTableViewController = nil;
    
	if (self.topicsTableViewController == nil) {
        TopicsTableViewController *aView;
        
        if ([self.metaDataList objectForKey:[[arrayData objectAtIndex:indexPath.row] aURL]]) {
            
            NSDictionary *tmpDic = [self.metaDataList objectForKey:[[arrayData objectAtIndex:indexPath.row] aURL]];
            
            switch ([[tmpDic objectForKey:@"flag"] intValue]) {
                case kFav:
                    aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:1];
                    break;
                case kFlag:
                    aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:2];
                    break;
                case kRed:
                    aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil flag:3];
                    break;
                case kALL:
                default:
                    aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil];
                    break;
            }
        }
        else {
            aView = [[TopicsTableViewController alloc] initWithNibName:@"TopicsTableViewController" bundle:nil];
        }
        
        
		self.topicsTableViewController = aView;
		[aView release];
	}
    
	//setup the URL
	

    
	self.navigationItem.backBarButtonItem =
	[[UIBarButtonItem alloc] initWithTitle:@"Retour"
									 style: UIBarButtonItemStyleBordered
									target:nil
									action:nil];
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.navigationItem.backBarButtonItem.title = @" ";
    }
    
    if ([self.metaDataList objectForKey:[[arrayData objectAtIndex:indexPath.row] aURL]]) {
        
        NSDictionary *tmpDic = [self.metaDataList objectForKey:[[arrayData objectAtIndex:indexPath.row] aURL]];
        
        switch ([[tmpDic objectForKey:@"flag"] intValue]) {
            case kFav:
                self.topicsTableViewController.forumFavorisURL = [[arrayData objectAtIndex:indexPath.row] URLforType:kFav];
                break;
            case kFlag:
                self.topicsTableViewController.forumFlag1URL = [[arrayData objectAtIndex:indexPath.row] URLforType:kFlag];
                break;
            case kRed:
                self.topicsTableViewController.forumFlag0URL = [[arrayData objectAtIndex:indexPath.row] URLforType:kRed];
                break;
            case kALL:
            default:
                self.topicsTableViewController.forumBaseURL = [[arrayData objectAtIndex:indexPath.row] aURL];
                break;
        }
    }
    else {
        self.topicsTableViewController.forumBaseURL = [[arrayData objectAtIndex:indexPath.row] aURL];
    }
    
    self.topicsTableViewController.forumName = [[arrayData objectAtIndex:indexPath.row] aTitle];
	self.topicsTableViewController.pickerViewArray = [[arrayData objectAtIndex:indexPath.row] subCats];

	[self.navigationController pushViewController:topicsTableViewController animated:YES];

}



#pragma mark -
#pragma mark Long Press

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint longPressLocation = [longPressRecognizer locationInView:self.forumsTableView];
        self.pressedIndexPath = [[self.forumsTableView indexPathForRowAtPoint:longPressLocation] copy];
        
        if (self.forumActionSheet != nil) {
            [self.forumActionSheet release], self.forumActionSheet = nil;
        }
        
        self.forumActionSheet = [[UIActionSheet alloc] initWithTitle:@"Ouvrir directement les sujets..."
                                                            delegate:self cancelButtonTitle:@"Annuler"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:	@"Favoris", @"Suivis", @"Lus", @"Tous (défaut)",
                                 nil,
                                 nil];
        
        // use the same style as the nav bar
        self.forumActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        
        CGPoint longPressLocation2 = [longPressRecognizer locationInView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view]];
        CGRect origFrame = CGRectMake( longPressLocation2.x, longPressLocation2.y, 1, 1);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self.forumActionSheet showFromRect:origFrame inView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view] animated:YES];
        }
        else
            [self.forumActionSheet showInView:[[[HFRplusAppDelegate sharedAppDelegate] rootController] view]];
        
    }
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"selc %@", [[arrayData objectAtIndex:pressedIndexPath.row] aURL]);
    NSMutableDictionary *actuMeta = [self.metaDataList objectForKey:[[arrayData objectAtIndex:pressedIndexPath.row] aURL]];
    if (!actuMeta) {
        actuMeta = [NSMutableDictionary dictionary];
    }
    NSLog(@"actuMeta %@", actuMeta);
    
    switch (buttonIndex)
    {
        case 0:
        {
            [actuMeta setValue:@(kFav) forKey:@"flag"];
            break;
        }
        case 1:
        {
            [actuMeta setValue:@(kFlag) forKey:@"flag"];
            
            break;
            
        }
        case 2:
        {
            [actuMeta setValue:@(kRed) forKey:@"flag"];
            break;
            
        }
        case 3:
        {
            [actuMeta setValue:@(kALL) forKey:@"flag"];
            break;
            
        }
        default:
        {
            break;
        }
            
    }
    
    NSLog(@"actuMeta %@", actuMeta);
    
    if ([actuMeta objectForKey:@"flag"]) {
        [self.metaDataList setObject:actuMeta forKey:[[arrayData objectAtIndex:pressedIndexPath.row] aURL]];
        
        NSLog(@"mdl %@", self.metaDataList);
        
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *metaList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:FORUMSMETA_FILE]];
        
        [self.metaDataList writeToFile:metaList atomically:YES];
    }
    
    [self.forumsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.pressedIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    self.pressedIndexPath = nil;
    
}


#pragma mark -
#pragma mark Reload

-(void)reload
{
	[self reload:NO];
}

-(void)reload:(BOOL)shake
{
	if (!shake) {

	}

    [self.forumsTableView triggerPullToRefresh];
    
	//[self fetchContent];
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

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusChangedNotification object:nil];

	self.arrayData = nil;
    self.arrayNewData = nil;
    
    self.metaDataList = nil;
    self.pressedIndexPath = nil;
    self.forumActionSheet = nil;
    
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