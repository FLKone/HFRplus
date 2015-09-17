//
//  ProfilViewController.m
//  HFRplus
//
//  Created by Shasta on 19/05/2014.
//
//

#import "HFRplusAppDelegate.h"
#import "ProfilViewController.h"

#import "ASIHTTPRequest.h"

#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "RangeOfCharacters.h"
#import "FeedbackTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "AvatarTableViewCell.h"

@interface ProfilViewController ()

@end

@implementation ProfilViewController
@synthesize profilTableView, loadingView, maintenanceView, status, statusMessage;
@synthesize currentUrl, request;
@synthesize arrayData;

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
    
    [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, self.currentUrl]]]];
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
    
    [self.arrayData removeAllObjects];
	[self.profilTableView reloadData];
    
	[self.maintenanceView setHidden:YES];
	[self.loadingView setHidden:NO];
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentComplete");
    
    
	//Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:YES];
    
    [self loadDataInTableView:[theRequest responseData]];
    
	[self.profilTableView reloadData];
    [self.profilTableView setHidden:NO];
    
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentFailed");
    
    //Bouton Reload
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	
    [self.maintenanceView setText:@"oops :o"];
    
    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:NO];
    [self.profilTableView setHidden:YES];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[self fetchContent];
	}
}

#pragma mark -
#pragma mark Parsing

-(void)loadDataInTableView:(NSData *)contentData
{
    NSLog(@"loadDataInTableView");
    
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];
	
    
	if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
		self.status = kMaintenance;
		self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        [self.maintenanceView setText:self.statusMessage];
        [self.maintenanceView setHidden:NO];
        
		return;
	}
    
    HTMLNode *tableNode = [bodyNode findChildTag:@"table"];
    
    NSArray *temporaryProfilArray = [tableNode findChildTags:@"tr"];
    
    int curSection = -1;
    int i = 0;
    NSMutableArray *parsedDataArray = [NSMutableArray array];
    
	for (HTMLNode * profilNode in temporaryProfilArray) {
        
		if (![[profilNode tagName] isEqualToString:@"tr"]) {
			continue;
		}
		
		if ([[profilNode className] isEqualToString:@"cBackHeader"]) {
            // Titre
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    [[profilNode allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"section",
                                                                                [NSMutableArray array], @"rows", nil];

            [parsedDataArray addObject:dict];
            
            curSection++;
		}

        
		if ([[profilNode className] isEqualToString:@"profil"]) {
            // info
            switch (curSection) {
                case 2:
                {
                    NSString *rowData = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] allContents];
                    rowData = [[rowData stringByDecodingXMLEntities] stringByReplacingOccurrencesOfString:@"\u00a0: " withString:@""];
                    
                    NSString *rowUrl = [[[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] findChildTag:@"a"] getAttributeNamed:@"href"];
                    
                    NSString *rowType = @"feedback";
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    @"", @"title",
                                          rowData, @"data",
                                          rowType, @"type",
                                          rowUrl, @"url", nil];
                    
                    //NSLog(@"dict %@", dict);
                    
                    [[[parsedDataArray objectAtIndex:curSection] objectForKey:@"rows"] addObject:dict];
                    i++;
                    break;
                }
                case 3:
                {
                    NSString *rowData = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] allContents];
                    rowData = [[rowData stringByDecodingXMLEntities] stringByReplacingOccurrencesOfString:@"\u00a0: " withString:@""];
                    
                    //NSString *rowType = @"link";
                    
                    //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    @"", @"title",
                    //                      rowData, @"data",
                    //                      rowType, @"type", nil];
                    
                    //NSLog(@"dict %@", dict);
                    
                    //[[[parsedDataArray objectAtIndex:curSection] objectForKey:@"rows"] addObject:dict];
                    
                    break;
                }
                default:
                {
                    NSString *rowTitle = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase2" allowPartial:NO] allContents];
                    rowTitle = [[rowTitle stringByDecodingXMLEntities] stringByReplacingOccurrencesOfString:@"\u00a0: " withString:@""];
                    
                    NSString *rowData = [[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] allContents];
                    rowData = [rowData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSString *rowUrl = @"";
                    rowUrl = [[[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] findChildTag:@"a"] getAttributeNamed:@"href"];
                    
                    NSString *rowType = @"";
                    
                    if (i == 0) {
                        
                        
                        rowUrl = [[[tableNode findChildWithAttribute:@"class" matchingName:@"avatar_center" allowPartial:NO] findChildTag:@"img"] getAttributeNamed:@"src"];
                        /*
                        // Input
                        NSString *originalString = self.currentUrl;
                        
                        // Intermediate
                        NSString *numberString;
                        
                        NSScanner *scanner = [NSScanner scannerWithString:originalString];
                        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                        
                        // Throw away characters before the first number.
                        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
                        
                        // Collect numbers.
                        [scanner scanCharactersFromSet:numbers intoString:&numberString];
                        
                        // Result.
                        int number = [numberString integerValue];

                        rowUrl = [NSString stringWithFormat:@"http://forum-images.hardware.fr/images/mesdiscussions-%d.jpg", number];
                        
                        */
                        rowType = @"avatar";
                        

                    }
                    else {
                        if (rowUrl.length > 0) {
                            NSURL *url = [NSURL URLWithString:rowUrl];
                            
                            NSLog(@"[url path] %@", [url path]);
                            
                            if ([[url path] isEqualToString:@"/configuration.php"]) {
                                rowType = @"config";
                            }
                            else if ([[[[profilNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO] findChildTag:@"a"] getAttributeNamed:@"target"] isEqualToString:@"_blank"]) {
                                rowType = @"perso";
                            }
                            else {
                                rowType = @"string";
                            }
                            
                        }
                        else
                        {
                            rowType = @"string";
                        }
                    }
                


                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:    rowTitle, @"title",
                                          rowData, @"data",
                                          rowType, @"type",
                                          rowUrl, @"url", nil];

                    [[[parsedDataArray objectAtIndex:curSection] objectForKey:@"rows"] addObject:dict];
                    i++;
                    break;
                }
            }
            
            

            //NSLog(@"profil %@", [profilNode allContents]);
		}
        
	}
	
    self.arrayData = [NSMutableArray array];
    [self.arrayData addObjectsFromArray:parsedDataArray];
    //NSLog(@"arrayData %@", self.arrayData);
    //NSLog(@"parsedDataArray %@", parsedDataArray);
}

#pragma mark -
#pragma mark View management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization
		self.currentUrl = [theURL copy];

	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Profil";
    
    // close
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
	// reload
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.profilTableView setTableFooterView:v];
    
    [self fetchContent];
}


- (void)doneButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Reload

-(void)reload
{
    [self fetchContent];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //NSLog(@"nbSec %d", self.arrayData.count);
    return self.arrayData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //NSLog(@"Title %d = %@", section, [[self.arrayData objectAtIndex:section] objectForKey:@"section"]);
    if ([[[self.arrayData objectAtIndex:section] objectForKey:@"rows"] count]) {
        return [[self.arrayData objectAtIndex:section] objectForKey:@"section"];
    }
    else
        return nil;

}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //
    if ([[[self.arrayData objectAtIndex:section] objectForKey:@"rows"] count]) {
        return HEIGHT_FOR_HEADER_IN_SECTION;
    }
    else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //On récupère la section (forum)
    NSString *title = [[self.arrayData objectAtIndex:section] objectForKey:@"section"];
    CGFloat curWidth = self.view.frame.size.width;
    
    //UIView globale
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,HEIGHT_FOR_HEADER_IN_SECTION)];
    customView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
	customView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
	//UIImageView de fond
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIImage *myImage = [UIImage imageNamed:@"bar2.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
        imageView.alpha = 0.9;
        imageView.frame = CGRectMake(0,0,curWidth,HEIGHT_FOR_HEADER_IN_SECTION);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [customView addSubview:imageView];
    }
    else {
        //bordures/iOS7
        UIView* borderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,1/[[UIScreen mainScreen] scale])];
        borderView.backgroundColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:114/162.0f alpha:0.7];
        
        //[customView addSubview:borderView];
        
        UIView* borderView2 = [[UIView alloc] initWithFrame:CGRectMake(0,HEIGHT_FOR_HEADER_IN_SECTION-1/[[UIScreen mainScreen] scale],curWidth,1/[[UIScreen mainScreen] scale])];
        borderView2.backgroundColor = [UIColor colorWithRed:158/255.0f green:158/255.0f blue:114/162.0f alpha:0.7];
        
        //[customView addSubview:borderView2];
        
    }
    
    //UIButton clickable pour accéder à la catégorie
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, curWidth, HEIGHT_FOR_HEADER_IN_SECTION)];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [button setTitleColor:[UIColor colorWithRed:109/255.0f green:109/255.0f blue:114/255.0f alpha:1] forState:UIControlStateNormal];
        [button setTitle:[title uppercaseString] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(10, 16, 0, 0)];
    }
    else
    {
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        [button setTitle:title forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [button.titleLabel setShadowColor:[UIColor darkGrayColor]];
        [button.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
    }
    
    [customView addSubview:button];
	
	return customView;
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	//NSLog(@"Count Forums Table View: %d", arrayData.count);
    //NSLog(@"nbRow In Sec %d = %d", section, [[[self.arrayData objectAtIndex:section] objectForKey:@"rows"] count]);

    return [[[self.arrayData objectAtIndex:section] objectForKey:@"rows"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *theRow = [[[self.arrayData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];

    if ([[theRow objectForKey:@"data"] isEqualToString:@""]) {
        return 0;
    }
    
    if ([[theRow objectForKey:@"data"] isEqualToString:@"NA"]) {
        return 0;
    }
    
    return 50.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *theRow = [[[self.arrayData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];

    NSString *type = [theRow objectForKey:@"type"];

    if ([type isEqualToString:@"feedback"]) {
        
        static NSString *CellIdentifier = @"CellFB";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        cell.textLabel.text = [theRow objectForKey:@"data"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        
        cell.clipsToBounds = YES;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if ([type isEqualToString:@"config"]) {
        
        static NSString *CellIdentifier = @"CellConfig";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        cell.textLabel.text = [theRow objectForKey:@"title"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        
        cell.clipsToBounds = YES;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if ([type isEqualToString:@"link"]) {
        
        static NSString *CellIdentifier = @"CellLINK";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        cell.textLabel.text = [theRow objectForKey:@"data"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        
        cell.clipsToBounds = YES;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else if ([type isEqualToString:@"avatar"]) {
        static NSString *CellIdentifier = @"avat";
        
        AvatarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[AvatarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = [theRow objectForKey:@"data"];
        //NSLog(@"theRow %@", theRow);

        __weak AvatarTableViewCell *cell_ = cell;
        [cell.imageView setImageWithURL:[theRow objectForKey:@"url"] placeholderImage:[UIImage imageNamed:@"avatar_male_gray_on_light_48x48"] success:^(UIImage *image) {

            //NSLog(@"frame base %@", NSStringFromCGRect(cell.imageView.frame));
            //NSLog(@"image base %@", NSStringFromCGSize(image.size));
            
            float newW = image.size.width / ( image.size.height / cell.imageView.frame.size.height );
             CGRect oldFrame = cell_.imageView.frame;
//__weak
            oldFrame.size.width = newW;
            cell_.imageView.frame = oldFrame;

            [cell_ layoutSubviews];
            
            //NSLog(@"frame base %@", NSStringFromCGRect(cell.imageView.frame));


        } failure:^(NSError *error) {
            //NSLog(@"err");
        }];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    
        return cell;
    }
    else {
        
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        cell.textLabel.text = [theRow objectForKey:@"data"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.minimumFontSize = 8.0f;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        
        cell.textLabel.numberOfLines = 2;
        
        cell.detailTextLabel.text = [theRow objectForKey:@"title"];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        
        cell.clipsToBounds = YES;
        
        if ([type isEqualToString:@"perso"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        return cell;

    }
}

#pragma mark -
#pragma mark Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *theRow = [[[self.arrayData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
    if ([[theRow objectForKey:@"type"] isEqualToString:@"string"]) {
        return YES;
    }
    else
        return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {

    if (action == @selector(copy:))
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.textLabel.text];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *theRow = [[[self.arrayData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
    
    NSString *type = [theRow objectForKey:@"type"];
    
    if ([type isEqualToString:@"perso"]) {
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                         style: UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.navigationItem.backBarButtonItem.title = @" ";
        }
        
        PersonnalLinkViewController *cVC = [[PersonnalLinkViewController alloc]
                                                        initWithNibName:@"PersonnalLinkViewController" bundle:nil andUrl:[theRow objectForKey:@"url"]];
        
        
        [self.navigationController pushViewController:cVC animated:YES];
        
    }
    else if ([type isEqualToString:@"config"]) {
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                         style: UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.navigationItem.backBarButtonItem.title = @" ";
        }
        
        ConfigurationViewController *cVC = [[ConfigurationViewController alloc]
                                            initWithNibName:@"ConfigurationViewController" bundle:nil andUrl:[theRow objectForKey:@"url"]];
        
        
        [self.navigationController pushViewController:cVC animated:YES];
        
    }
    else if ([type isEqualToString:@"feedback"]) {
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                         style: UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
            self.navigationItem.backBarButtonItem.title = @" ";
        }
        
        FeedbackViewController *cVC = [[FeedbackViewController alloc]
                                            initWithNibName:@"FeedbackViewController" bundle:nil andUrl:[[theRow objectForKey:@"url"] stringByAppendingString:@"&page=1"]];
        
        
        [self.navigationController pushViewController:cVC animated:YES];
        
    }

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.loadingView = nil;
	self.profilTableView = nil;
	self.maintenanceView = nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
    
	[self viewDidUnload];
    
	[request cancel];
	[request setDelegate:nil];
    
    
}



@end

@implementation FeedbackViewController
@synthesize feedTableView, loadingView, maintenanceView, statusMessage, request, status, arrayData;

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	//NSLog(@"fetchContent %@", [NSString stringWithFormat:@"%@%@", kForumURL, [self currentUrl]]);
	self.status = kIdle;
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [self currentUrl]]]]];
	[request setShouldRedirect:NO];
    
	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	[request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	[self.maintenanceView setHidden:YES];
	[self.feedTableView setHidden:YES];
	[self.loadingView setHidden:NO];
	
	//--
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	NSLog(@"fetchContentComplete");
    
    
	[self.arrayData removeAllObjects];
	[self.feedTableView reloadData];
	
	[self loadDataInTableView:[request responseData]];
    
	[self.loadingView setHidden:YES];
    
	switch (self.status) {
		case kMaintenance:
		case kNoResults:
		case kNoAuth:
			[self.maintenanceView setText:self.statusMessage];
            
            [self.loadingView setHidden:YES];
			[self.maintenanceView setHidden:NO];
			[self.feedTableView setHidden:YES];
			break;
		default:
			[self.feedTableView reloadData];
            
            [self.loadingView setHidden:YES];
            [self.maintenanceView setHidden:YES];
			[self.feedTableView setHidden:NO];
			break;
	}
    
    //PARSING
	//[self.arrayData removeAllObjects];
	
    
	[self.loadingView setHidden:YES];
    
	switch (self.status) {
		case kMaintenance:
		case kNoResults:
		case kNoAuth:
			[self.maintenanceView setText:self.statusMessage];
            [self.loadingView setHidden:YES];
			[self.maintenanceView setHidden:NO];
			[self.feedTableView setHidden:YES];
			break;
		default:
            [self.loadingView setHidden:YES];
            [self.maintenanceView setHidden:YES];
			[self.feedTableView setHidden:NO];
			break;
	}
    
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    
    [self.maintenanceView setText:@"oops :o"];
    
    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:NO];
    [self.feedTableView setHidden:YES];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert setTag:667];
	[alert show];
}

-(void)loadDataInTableView:(NSData *)contentData
{
	
	
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
	HTMLNode * bodyNode = [myParser body];
    
	//NSLog(@"rawContentsOfNode %@", rawContentsOfNode([bodyNode _node], [myParser _doc]));
	
	if (![bodyNode findChildrenWithAttribute:@"id" matchingName:@"mesdiscussions" allowPartial:NO]) {
		if ([[[bodyNode firstChild] tagName] isEqualToString:@"p"]) {
			NSLog(@"p");
            
			self.status = kMaintenance;
			self.statusMessage = [[[bodyNode firstChild] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            return;
		}
        
		NSLog(@"id");
		self.status = kNoAuth;
		self.statusMessage = [[[bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO] contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		return;		
	}
	   
	//On remplace le numéro de page dans le titre
	NSString *regexString  = @".*page=([^&]+).*";
	NSRange   matchedRange = NSMakeRange(NSNotFound, 0UL);
	NSRange   searchRange = NSMakeRange(0, self.currentUrl.length);
	NSError  *error2        = NULL;
	//int numPage;
	
	matchedRange = [self.currentUrl rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
	
	if (matchedRange.location == NSNotFound) {
		NSRange rangeNumPage =  [[self currentUrl] rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
		self.pageNumber = [[self.currentUrl substringWithRange:rangeNumPage] intValue];
	}
	else {
		self.pageNumber = [[self.currentUrl substringWithRange:matchedRange] intValue];
		
	}

    NSLog(@"pageNumber %d", self.pageNumber);
    
	HTMLNode * pagesTrNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"fondForum1PagesHaut" allowPartial:YES];
    
	if(pagesTrNode)
	{
		HTMLNode * pagesLinkNode = [pagesTrNode findChildWithAttribute:@"class" matchingName:@"left" allowPartial:NO];
		
		//NSLog(@"pagesLinkNode %@", rawContentsOfNode([pagesLinkNode _node], [myParser _doc]));
        
		if (pagesLinkNode) {
			//NSLog(@"pagesLinkNode %@", rawContentsOfNode([pagesLinkNode _node], [myParser _doc]));
			
			NSArray *temporaryNumPagesArrayNM = [pagesLinkNode children];
            NSMutableArray *temporaryNumPagesArray = [NSMutableArray arrayWithArray:temporaryNumPagesArrayNM];
            
            [temporaryNumPagesArray removeLastObject];
            
            //NSLog(@"setFirstPageNumber %d", [[[temporaryNumPagesArray objectAtIndex:2] contents] intValue]);

			[self setFirstPageNumber:[[[temporaryNumPagesArray objectAtIndex:2] contents] intValue]];
			
			if ([self pageNumber] == [self firstPageNumber]) {
				NSString *newFirstPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setFirstPageUrl:newFirstPageUrl];
			}
			else {
				NSString *newFirstPageUrl;
				
				if ([[[temporaryNumPagesArray objectAtIndex:2] tagName] isEqualToString:@"span"]) {
					newFirstPageUrl = [[NSString alloc] initWithString:[[[temporaryNumPagesArray objectAtIndex:2] className] decodeSpanUrlFromString2]];
				}
				else {
					newFirstPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray objectAtIndex:2] getAttributeNamed:@"href"]];
				}
				
				[self setFirstPageUrl:newFirstPageUrl];
			}
			
            //NSLog(@"setFirstPageNumber %d", [[[temporaryNumPagesArray lastObject] contents] intValue]);

			[self setLastPageNumber:[[[temporaryNumPagesArray lastObject] contents] intValue]];
			
			if ([self pageNumber] == [self lastPageNumber]) {
				NSString *newLastPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setLastPageUrl:newLastPageUrl];
			}
			else {
				NSString *newLastPageUrl;
				
				if ([[[temporaryNumPagesArray lastObject] tagName] isEqualToString:@"span"]) {
					newLastPageUrl = [[NSString alloc] initWithString:[[[temporaryNumPagesArray lastObject] className] decodeSpanUrlFromString2]];
				}
				else {
					newLastPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray lastObject] getAttributeNamed:@"href"]];
				}
				
				[self setLastPageUrl:newLastPageUrl];
			}
			
			/*
			 NSLog(@"premiere %d", [self firstPageNumber]);
			 NSLog(@"premiere url %@", [self firstPageUrl]);
			 
			 NSLog(@"premiere %d", [self lastPageNumber]);
			 NSLog(@"premiere url %@", [self lastPageUrl]);
			*/
			
			//TableFooter
			UIToolbar *tmptoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                tmptoolbar.barStyle = -1;
                
                tmptoolbar.opaque = NO;
                tmptoolbar.translucent = YES;
                
                [[tmptoolbar.subviews objectAtIndex:1] setHidden:YES];
                
            }
            
			[tmptoolbar sizeToFit];
            
			UIBarButtonItem *systemItemNext = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowforward"]
																			   style:UIBarButtonItemStyleBordered
																			  target:self
																			  action:@selector(nextPage:)];
            
			
			//systemItemNext.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);
			
			UIBarButtonItem *systemItemPrevious = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowback"]
                                                                                   style:UIBarButtonItemStyleBordered
                                                                                  target:self
                                                                                  action:@selector(previousPage:)];
            
			//systemItemPrevious.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);
            
            
			
			
			UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowbegin"]
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(firstPage:)];
			
			//systemItem1.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);
            
			if ([self pageNumber] == [self firstPageNumber]) {
				[systemItem1 setEnabled:NO];
				[systemItemPrevious setEnabled:NO];
			}
			
			UIBarButtonItem *systemItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowend"]
																			style:UIBarButtonItemStyleBordered
																		   target:self
																		   action:@selector(lastPage:)];
			
			//systemItem2.imageInsets = UIEdgeInsetsMake(2.0, 0, -2.0, 0);
            
			if ([self pageNumber] == [self lastPageNumber]) {
				[systemItem2 setEnabled:NO];
				[systemItemNext setEnabled:NO];
			}
            
			UIButton *labelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			labelBtn.frame = CGRectMake(0, 0, 130, 44);
			[labelBtn addTarget:self action:@selector(choosePage) forControlEvents:UIControlEventTouchUpInside];
			[labelBtn setTitle:[NSString stringWithFormat:@"%d/%d", [self pageNumber], [self lastPageNumber]] forState:UIControlStateNormal];
			
            [[labelBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
            
            if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                    [labelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [labelBtn setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [labelBtn titleLabel].shadowOffset = CGSizeMake(0.0, -1.0);
                }
                else {
                    [labelBtn setTitleColor:[UIColor colorWithRed:113/255.0 green:120/255.0 blue:128/255.0 alpha:1.0] forState:UIControlStateNormal];
                    [labelBtn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [labelBtn titleLabel].shadowColor = [UIColor whiteColor];
                    [labelBtn titleLabel].shadowOffset = CGSizeMake(0.0, 1.0);
                }
            }
            else
            {
                [labelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
			UIBarButtonItem *systemItem3 = [[UIBarButtonItem alloc] initWithCustomView:labelBtn];
			
			//Use this to put space in between your toolbox buttons
			UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];
			UIBarButtonItem *fixItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
            
            fixItem.width = SPACE_FOR_BARBUTTON;

			
			//Add buttons to the array
			NSArray *items = [NSArray arrayWithObjects: systemItem1, fixItem, systemItemPrevious, flexItem, systemItem3, flexItem, systemItemNext, fixItem, systemItem2, nil];
			
			//release buttons
			
			
			
			//add array of buttons to toolbar
			[tmptoolbar setItems:items animated:NO];
			
			if ([self firstPageNumber] != [self lastPageNumber]) {
				self.feedTableView.tableFooterView = tmptoolbar;
			}
			else {
				self.feedTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
			}
            
			//self.aToolbar = tmptoolbar;
			
		}
		else {
			//self.aToolbar = nil;
			//NSLog(@"pas de pages");
			
		}
        
        //Gestion des pages
        if (self.pageNumber > 1) self.previousPageUrl = [self.currentUrl stringByReplacingOccurrencesOfString:
                                                         [NSString stringWithFormat:@"page=%d", self.pageNumber]
                                                                                                   withString:
                                                         [NSString stringWithFormat:@"page=%d", (self.pageNumber-1)]];
        
        if (self.pageNumber < self.lastPageNumber) self.nextPageUrl = [self.currentUrl stringByReplacingOccurrencesOfString:
                                                         [NSString stringWithFormat:@"page=%d", self.pageNumber]
                                                                                                   withString:
                                                         [NSString stringWithFormat:@"page=%d", (self.pageNumber+1)]];
        //self.nextPageUrl
        //self.previousPageUrl
        //-- Gestion des pages
		
	}
    
	
	NSArray *temporaryTopicsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cBackCouleurTab" allowPartial:YES]; //Get links for cat
    
	if (temporaryTopicsArray.count == 0) {
		//NSLog(@"Aucun nouveau message %d", self.arrayDataID.count);
		self.status = kNoResults;
		self.statusMessage = @"Aucun feedback";
		//[myParser release];
		//return;
	}
	
	
	for (HTMLNode * topicNode in temporaryTopicsArray) { //Loop through all the tags
        
        if ([[[topicNode firstChild] className] isEqualToString:@"col7"]) {
            continue;
        }
        
		@autoreleasepool {
        
		
        NSArray *nodes = [topicNode children];
        
		//Pseudo
        HTMLNode * pseudoNode = [nodes objectAtIndex:0];
        
        //Status
        HTMLNode * statusNode = [nodes objectAtIndex:1];
        
        //Avis
        HTMLNode * avisNode = [nodes objectAtIndex:2];
        //NSLog(@"avis %@", [[avisNode className] stringByReplacingOccurrencesOfString:@"col3 " withString:@""]);
        
        //Date
        HTMLNode * dateNode = [nodes objectAtIndex:3];
        
        //Commentaire
        HTMLNode * commsNode = [nodes objectAtIndex:4];

        
        NSDictionary *feedDic = [NSDictionary dictionaryWithObjectsAndKeys: [pseudoNode allContents], @"pseudo",
                                                                            [statusNode allContents], @"status",
                                                                            [[avisNode className] stringByReplacingOccurrencesOfString:@"col3 " withString:@""], @"avis",
                                                                            [dateNode allContents], @"date",
                                                                            [commsNode allContents], @"comm", nil];
        
		[self.arrayData addObject:feedDic];
        
		}
		
	}
	
	
    //NSLog(@"self.arrayData %@", self.arrayData);
    

	
	//NSDate *now = [NSDate date]; // Create a current date
	
	//NSLog(@"TOPICS Time elapsed initWithContentsOfURL : %f", [then0 timeIntervalSinceDate:then]);
	//NSLog(@"TOPICS Time elapsed initWithData          : %f", [then1 timeIntervalSinceDate:then0]);
	//NSLog(@"TOPICS Time elapsed myParser              : %f", [then2 timeIntervalSinceDate:then1]);
	//NSLog(@"TOPICS Time elapsed arraydata             : %f", [now timeIntervalSinceDate:then2]);
	//NSLog(@"TOPICS Time elapsed Total                 : %f", [now timeIntervalSinceDate:then]);
    if (self.status != kNoResults) {
        self.status = kComplete;
    }
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //NSLog(@"theURL %@", theURL);
        self.currentUrl = theURL;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Feedbacks";
    
    self.arrayData = [NSMutableArray array];
    
    [self fetchContent];
    
    
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return arrayData.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"FeedBackCell";
    
    FeedbackTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"FeedbackTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
	NSDictionary *dic = [arrayData objectAtIndex:indexPath.row];
    
    if (((NSString *)[dic objectForKey:@"pseudo"]).length) {
        [cell.pseudoLabel setText:[dic valueForKey:@"pseudo"]];
    }
    else {
        [cell.pseudoLabel setText:@"pseudo supprimé"];
    }

    
    if ([[dic valueForKey:@"avis"] isEqualToString:@"positive"]) {
        [cell.avisLabel setTextColor:[UIColor colorWithRed:0.27f green:0.85f blue:0.46f alpha:1.0f]];
        [cell.avisLabel setText:@"positif"];
        [cell.avisLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];

    }
    else if ([[dic valueForKey:@"avis"] isEqualToString:@"negative"]) {
        [cell.avisLabel setTextColor:[UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f]];
        [cell.avisLabel setText:@"negatif"];
        [cell.avisLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        
    }
    else {
        [cell.avisLabel setTextColor:[UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f]];
        [cell.avisLabel setText:@"neutre"];
        [cell.avisLabel setFont:[UIFont systemFontOfSize:13.0f]];
    }

	[cell.commLabel setText:[dic valueForKey:@"comm"]];
	[cell.dateLabel setText:[dic valueForKey:@"date"]];
    
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end

@implementation PersonnalLinkViewController
@synthesize webView, url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString *myURLString = theURL;
        NSURL *myURL;
        if ([myURLString hasPrefix:@"http://"]) {
            myURL = [NSURL URLWithString:myURLString];
        }
        else
        {
            NSString *rer = [NSString stringWithFormat:@"http://%@", myURLString];
            myURL = [NSURL URLWithString:rer];
        }
        
        self.url = myURL;

    }
    return self;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidStartLoad");
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidFinishLoad");

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Lien perso.";
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	[self.webView stopLoading];
    
	self.webView.delegate = nil;
	self.webView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	[self viewDidUnload];
}

@end

@implementation ConfigurationViewController
@synthesize textView, loadingView, maintenanceView, statusMessage, request, status,  url;

#pragma mark -
#pragma mark Data lifecycle

- (void)cancelFetchContent
{
	[request cancel];
}

- (void)fetchContent
{
	//NSLog(@"fetchContent %@", [NSString stringWithFormat:@"%@%@", kForumURL, [self currentUrl]]);
	self.status = kIdle;
	[ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    
	[self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kForumURL, [self url]]]]];
	[request setShouldRedirect:NO];
    
	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentComplete:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	[request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	[self.maintenanceView setHidden:YES];
	[self.textView setHidden:YES];
	[self.loadingView setHidden:NO];
	
	//--
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
	NSLog(@"fetchContentComplete");
    
    
    HTMLParser * myParser = [[HTMLParser alloc] initWithString:[request responseString] error:NULL];
	HTMLNode * bodyNode = [myParser body]; //Find the body tag

    //PARSING
    
    HTMLNode *tableNode = [bodyNode findChildTag:@"table"];
    
    NSArray *temporaryProfilArray = [tableNode findChildTags:@"tr"];
    
	for (HTMLNode * profilNode in temporaryProfilArray) {
        
        if ([[profilNode className] isEqualToString:@"profil"]) {
            
            if(![[profilNode firstChild] getAttributeNamed:@"class"]) {
                NSString *str = rawContentsOfNode([[profilNode firstChild] _node], [myParser _doc]);
                
                //NSLog(@"OK %@", str);
                NSString *txtTW = [str stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
                txtTW = [txtTW stringByReplacingOccurrencesOfString:@"<td>" withString:@""];
                txtTW = [txtTW stringByReplacingOccurrencesOfString:@"</td>" withString:@""];
                [self.textView setText:txtTW];
                
                break;
            }
        }
    }
    
    //PARSING
	//[self.arrayData removeAllObjects];
	
    
	[self.loadingView setHidden:YES];
    
	switch (self.status) {
		case kMaintenance:
		case kNoResults:
		case kNoAuth:
			[self.maintenanceView setText:self.statusMessage];
            [self.loadingView setHidden:YES];
			[self.maintenanceView setHidden:NO];
			[self.textView setHidden:YES];
			break;
		default:
            [self.loadingView setHidden:YES];
            [self.maintenanceView setHidden:YES];
			[self.textView setHidden:NO];
			break;
	}
    
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    
    [self.maintenanceView setText:@"oops :o"];
    
    [self.loadingView setHidden:YES];
    [self.maintenanceView setHidden:NO];
    [self.textView setHidden:YES];
		
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
												   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Réessayer", nil];
	[alert setTag:667];
	[alert show];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theURL
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        self.url = theURL;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Config";
    
    [self fetchContent];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.textView = nil;
	
}

@end
