//
//  ViewController.m
//  DocumentToJson
//
//  Created by Webonise on 27/11/13.
//  Copyright (c) 2013 Webonise. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
 NSArray *allFiles;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *rulesArr=[NSArray arrayWithObjects:@"Timing",@"Officials and their Duties",@"Field and Equipment",@"Basic Definitions",@"Kicks",@"Snapping and Handing the Ball",@"Passing",@"Series of Downs",@"Contact",@"Scoring and Touchbacks",@"Penalty Enforcement",@"Non-Contact Fouls", nil];
    
      NSArray *allFiles=[NSArray arrayWithObjects:@"game",@"terminology",@"eligibility",@"equipment",@"field",@"rosters",@"timingandovertime",@"scoring",@"coaches",@"liveballdeadball",@"running",@"passing",@"receiving",@"rushingthepasser",@"flagpulling",@"formations",@"unsportsmanlikeconduct",@"penalties", nil];
    
    NSMutableArray *allJson=[[NSMutableArray alloc]init];
    NSMutableArray *youthTrack=[[NSMutableArray alloc]init];
    
    for(int i=0;i<[rulesArr count]; i++){
        

    for(int i=0;i<[allFiles count];i++){
        NSString *path=[[NSBundle mainBundle]pathForResource:[allFiles objectAtIndex:i] ofType:@"html"];
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
    NSString *jsonContent= [self getJsonFromDictionaryOrArray:allJson];
    //NSLog(@"%@",jsonContent);
    //[self writeIntoFileWithString:jsonContent];
        NSDictionary *outerDictionary=[[NSDictionary alloc]init];
        outerDictionary=@{@"rule":[rulesArr objectAtIndex:i],@"value":jsonContent};
        [youthTrack addObject:outerDictionary];
    }
    
    [self makePlistIntoHomeDirectoryWithContent:youthTrack];
}

- (void)makePlistIntoHomeDirectoryWithContent:(NSArray*)content{
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/myfile.plist"];
    [content writeToFile:filePath atomically:YES];
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

- (void)writeIntoFileWithString:(NSString*)data{
    // Path for original file in bundle..
    NSString *originalPath = [[NSBundle mainBundle] pathForResource:@"JsonFormat" ofType:@"txt"];
    NSURL *originalURL = [NSURL URLWithString:originalPath];
    
    // Destination for file that is writeable
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *documentsURL = [NSURL URLWithString:documentsDirectory];
    
    
    NSString *fileNameComponent = [[originalPath pathComponents] lastObject];
    NSURL *destinationURL = [documentsURL URLByAppendingPathComponent:fileNameComponent];
    NSString *destinationUrlString=[NSString stringWithContentsOfURL:destinationURL encoding:NSUTF8StringEncoding error:nil];
    // Copy file to new location
    NSError *anError;
    [[NSFileManager defaultManager] copyItemAtURL:originalURL
                                            toURL:destinationURL
                                            error:&anError];
    
    // Now you can write to the file....
    NSString *string = data;
    NSError *writeError = nil;
    [string writeToFile:destinationUrlString  atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    NSLog(@"%@", writeError.localizedFailureReason);
}

@end
