//
//  Favorite.h
//  HFRplus
//
//  Created by FLK on 04/07/10.
//

#import <Foundation/Foundation.h>
#import "HTMLParser.h"


@interface LinkItem : NSObject {
	NSString *name;
	NSString *url;
	
	NSString *flagUrl;
	NSString *typeFlag;
	
	NSString *lastPostUrl;
	NSString *lastPageUrl;
	
	NSString *postID;

	BOOL viewed;
	BOOL isDel;
    
	BOOL isBL;
    
	int rep;

	NSString *urlQuote;
	NSString *urlEdit;
    NSString *urlProfil;
	NSString *urlAlert;
    
	NSString *dicoHTML;    
	HTMLNode *messageNode;

	NSString *imageUI;
	NSString *messageDate;
	NSString *messageAuteur;

	UIView *textViewMsg;
	
	
	NSString *addFlagUrl;
	NSString *quoteJS;
	NSString *MPUrl;

    NSString *quotedNB;
    NSString *quotedLINK;
    NSString *editedTime;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSString *flagUrl;
@property (nonatomic, strong) NSString *typeFlag;

@property (nonatomic, strong) NSString *urlQuote;
@property (nonatomic, strong) NSString *urlEdit;
@property (nonatomic, strong) NSString *urlProfil;
@property (nonatomic, strong) NSString *urlAlert;

@property (nonatomic, strong) NSString *lastPostUrl;
@property (nonatomic, strong) NSString *lastPageUrl;

@property (nonatomic, strong) NSString *dicoHTML;
@property (nonatomic, strong) HTMLNode *messageNode;

@property (nonatomic, strong) NSString *imageUI;

@property (nonatomic, strong) NSString *messageDate;
@property (nonatomic, strong) NSString *messageAuteur;

@property (nonatomic, strong) UIView *textViewMsg;

@property (nonatomic, strong) NSString *postID;

@property (nonatomic, strong) NSString *addFlagUrl;
@property (nonatomic, strong) NSString *quoteJS;
@property (nonatomic, strong) NSString *MPUrl;

@property (nonatomic, strong) NSString *quotedNB;
@property (nonatomic, strong) NSString *quotedLINK;
@property (nonatomic, strong) NSString *editedTime;

@property int rep;
@property BOOL viewed;
@property BOOL isDel;
@property BOOL isBL;

-(NSString *)toHTML:(int)index;

@end
