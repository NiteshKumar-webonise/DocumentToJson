//
//  ViewController.h
//  DocumentToJson
//
//  Created by Webonise on 27/11/13.
//  Copyright (c) 2013 Webonise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UISearchBarDelegate>
@property (nonatomic,retain) IBOutlet UISearchBar *searchStringBar;
@property (nonatomic,retain) IBOutlet UITextView *textView;
@property (nonatomic,retain)  NSArray *allFiles;
@property (nonatomic,retain)   NSMutableArray *allJson;

@end
