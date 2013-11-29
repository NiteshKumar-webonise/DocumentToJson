//
//  ViewController.m
//  DocumentToJson
//
//  Created by Webonise on 27/11/13.
//  Copyright (c) 2013 Webonise. All rights reserved.
//

#import "ViewController.h"

#define kRWSearchCaseSensitiveKey    @"RWSearchCaseSensitiveKey"
#define kRWSearchWholeWordsKey       @"RWSearchWholeWordsKey"


@interface ViewController ()

@end

@implementation ViewController
@synthesize searchStringBar,allJson,allFiles;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.text=@"";
    allFiles=[self getAllfileNamesFromBundle];
     
    allJson=[[NSMutableArray alloc]init];
    
     
     for(int i=0;i<[allFiles count];i++){
         NSString* fileName=[[[allFiles objectAtIndex:i] lastPathComponent] stringByDeletingPathExtension];
       NSString *path=[[NSBundle mainBundle] pathForResource:fileName ofType:@"html"];
     if (!path){
        NSLog(@"Unable to find file in bundle", nil);
        continue;
     }
     NSString *contents =[NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
     NSString *htmlStripped=[self stringByStrippingHTMLWithString:contents];
     NSString *data=[htmlStripped stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     NSDictionary *dict=[[NSDictionary alloc]init];
     dict =@{@"shareurl":@"",@"html":[allFiles objectAtIndex:i],@"description":data,@"fav":@false,@"rule":[allFiles objectAtIndex:i]};
     [allJson addObject:dict];
     }
    
}



- (NSRegularExpression *)regularExpressionWithString:(NSString *)string options:(NSDictionary *)options
{
    // Create a regular expression
    BOOL isCaseSensitive = [[options objectForKey:kRWSearchCaseSensitiveKey] boolValue];
    BOOL isWholeWords = [[options objectForKey:kRWSearchWholeWordsKey] boolValue];
    
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = isCaseSensitive ? 0 : NSRegularExpressionCaseInsensitive;
    
    NSString *placeholder = isWholeWords ? @"\\b%@\\b" : @"%@";
    NSString *pattern = [NSString stringWithFormat:placeholder, string];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    return regex;
}

- (NSArray*)getAllfileNamesFromBundle{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:path error:&error];
    NSLog(@"%@",directoryAndFileNames);
     return directoryAndFileNames;
}

- (void)makePlistIntoHomeDirectoryWithContent:(NSString*)content{
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/myfile.plist"];
    [content writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) stringByStrippingHTMLWithString:(NSString*)string {
    NSRange r;
    NSString *s = string;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

-(NSString *)getJsonFromDictionaryOrArray:(NSObject*)dictOrArr{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictOrArr
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString;
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",jsonString);
    }
    
    return jsonString;
}


-(void)searchInContentWithSearchString:(NSString*)searchString{
    NSMutableArray* searchedFiles=[[NSMutableArray alloc]init];
    
    NSDate *start = [NSDate date];
    for(int i=0;i<[allJson count];i++){
        NSString *content= [[allJson objectAtIndex:i] valueForKey:@"description"];
        NSRange visibleTextRange=NSMakeRange(0, content.length);
        NSDictionary *options=@{@"RWReplacementKey": @0,@"RWSearchCaseSensitiveKey":@1,@"RWSearchWholeWordsKey":@0};
        
        NSRegularExpression *regex = [self regularExpressionWithString:searchString options:options];
        NSArray *matches = [regex matchesInString:content options:NSMatchingProgress range:visibleTextRange];
        if([matches count]>0){
            [searchedFiles addObject:[[allJson objectAtIndex:i] valueForKey:@"html"]];
        }
    }
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    NSLog(@"Execution Time: %f", executionTime);
    NSString *executionTimeString=[NSString stringWithFormat:@"%f",executionTime];
    NSLog(@"Searched file names %@",searchedFiles);
    self.textView.text=[[NSString stringWithFormat:@"%@",searchedFiles] stringByAppendingString:executionTimeString];
    
}

#pragma mark -  UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchInContentWithSearchString:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [searchBar resignFirstResponder];
}
@end
