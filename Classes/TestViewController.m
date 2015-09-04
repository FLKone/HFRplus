//
//  TestViewController.m
//  HFRplus
//
//  Created by FLK on 04/09/2015.
//
//

#import "TestViewController.h"
#import "HFRplusAppDelegate.h"

@implementation TestViewController
@synthesize textView, delegate, url;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        self.url = [[NSString alloc] init];
        
        self.title = @"Alerte !";
        NSLog(@"sd %@", nibNameOrNil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    //Bouton Annuler
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    //self.navigationItem.leftBarButtonItem = cancelBarItem;
    [cancelBarItem release];
    
    //Bouton Envoyer
    UIBarButtonItem *sendBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Envoyer" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = sendBarItem;
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [sendBarItem release];
    
    //    NSLog(@"VLD %@", self.url);
    //[self.textView setText:self.url];
}

#pragma mark -
#pragma mark Action

- (IBAction)cancel {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention !" message:@"Vous allez perdre le contenu de votre alerte."
                                                   delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Confirmer", nil];
    [alert setTag:666];
    [alert show];
    [alert release];
}

- (IBAction)done {
    
    UIAlertView *alertOK = [[UIAlertView alloc] initWithTitle:@"Hooray-Debug !" message:@"Done!"
                                                     delegate:self.delegate cancelButtonTitle:nil otherButtonTitles: nil];
    [alertOK setTag:666];
    [alertOK show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(alertOK.bounds.size.width / 2, alertOK.bounds.size.height - 50);
    [indicator startAnimating];
    [alertOK addSubview:indicator];
    [indicator release];
    
    
    [alertOK release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
    [self.delegate alertModoViewControllerDidFinishOK:self];
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 666) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
        [self.delegate alertModoViewControllerDidFinish:self];
    }
}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    //self.loadingView = nil;
    
    self.textView.delegate = nil;
    self.textView = nil;
    
    //self.accessoryView = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [super viewDidUnload];
}

- (void)dealloc {
    //NSLog(@"dealloc ADD");
    
    [self.textView resignFirstResponder];
    [self viewDidUnload];
    
    //[request cancel];
    //[request setDelegate:nil];
    //self.request = nil;
    
    //self.delegate = nil;
    
    self.url = nil;
    
    [super dealloc];
    
    
}

@end
