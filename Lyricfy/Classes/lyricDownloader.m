//
//  lyricDownloader.m
//  Lyricfy
//
//  Created by Lucas on 11/13/12.
//  Copyright (c) 2012 Lucas. All rights reserved.
//  Licensed under the New BSD License
//

#import "lyricDownloader.h"
#import "NSOperation+Extensions.h"
#import "AFNetworking.h"
#import "ITrack.h"

@interface lyricDownloader (){
    BOOL lyricWiki, metroLyrics, lyricsFreak;
    NSInteger responseCode;
}

- (NSURL *)urlFromSource:(ITSource)source;
- (NSString *)parseMetroLyric:(NSData *)rawData;
@end

@implementation lyricDownloader
@synthesize delegate;
@synthesize track;

#pragma mark - Lifecycle

- (id)init{
    self = [super init];
    if (self){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        lyricWiki = [defaults boolForKey:@"lyricWiki"];
        lyricsFreak = [defaults boolForKey:@"metroLyrics"];
        metroLyrics = true; //[defaults boolForKey:@"lyricsFreak"];//implemented
    }
    return self;
}

- (id)initWithTrack:(ITrack *)aTrack{
    self = [self init];
    if (self){
        [self setTrack:aTrack];
    }
    return self;
}

- (void)setCompletionBlock:(void (^)(ITrack *_track, NSInteger _responseCode))block{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    [super setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(),^{
            block(track,responseCode);
        });
    }];
#pragma clang diagnostic pop
}

#pragma mark - Main

- (void)main{
    if (self.track == NULL || self.track.name == NULL || self.track.artist == NULL){
        [self cancel];
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(),^{
        if ([self.delegate respondsToSelector:@selector(lyricDownloader:WillBeginProcessingTrack:)])
            [self.delegate lyricDownloader:self WillBeginProcessingTrack:self.track];
    });
    
    NSInteger _responseCode[3] = {0,0,0};
    
    if (lyricWiki){
        
    }
    
    if (lyricsFreak){
        
    }
    
    if (metroLyrics){
        NSURLRequest *request = [NSURLRequest requestWithURL:[self urlFromSource:ITmetroLyrics]];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [op startAndWaitUntilFinished];
        
        //NSLog(@"lyricDownloader: %ld - %@",[[op response] statusCode], [[op response] localizedStatusCode]);
        _responseCode[2] = [[op response] statusCode];
        
        if (_responseCode[2] == 200){
            NSString *lyric = [self parseMetroLyric:op.responseData];
            //NSLog(@"%@",lyric);
            if (lyric)
                [self.track setMetroLyrics:lyric];
            else
                _responseCode[2] = 404;
        }
    }
    
    if (_responseCode[0] == 200 || _responseCode[1] == 200 || _responseCode[2] == 200)
        responseCode = 200;
    else
        responseCode = 404;
    
    [self.track setPassedTheQueue:YES];
    
    dispatch_async(dispatch_get_main_queue(),^{//TODO: test if asyn isnt bugging the lifecycle
        if ([self.delegate respondsToSelector:@selector(lyricDownloader:didFinishedDownloadingLyricForTrack:withResponseCode:)])
            [self.delegate lyricDownloader:self didFinishedDownloadingLyricForTrack:self.track withResponseCode:responseCode];
    });
}

#pragma mark - Helper

- (NSURL *)urlFromSource:(ITSource)source{
    switch (source) {
        case ITlyricsFreak:{
            //do something
            return nil;
        }
        case ITLyricWiki:{
            //do something
            return nil;
        }
        case ITmetroLyrics:{
            //URL Format: metrolyrics.com/<#Song-Name#>-lyrics-<#Artist#>.html
            NSString *url = [NSString stringWithFormat:@"%@-lyrics-%@",self.track.name,self.track.artist];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            __block NSMutableArray *array = [NSMutableArray array];
            
            [regex enumerateMatchesInString:url options:NSMatchingReportProgress range:NSMakeRange(0, url.length)
                                 usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
                                     if (result)
                                         [array addObject:[url substringWithRange:result.range]];
                                 }];
            
            url = [array componentsJoinedByString:@"-"];
            url = [NSString stringWithFormat:@"http://www.metrolyrics.com/%@.html",url];
            NSLog(@"%@",url);
            return [NSURL URLWithString:url];
        }
        default:
            return nil;
    }
}

#pragma mark - Parser

- (NSString *)parseMetroLyric:(NSData *)rawData{
    NSError *error;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:rawData options:NSXMLDocumentTidyHTML error:&error];
    NSXMLElement *rootNode = [document rootElement];
    
    NSString *xpathQueryString = @"//div[@id='lyrics-body']/p";
    NSArray *newItemsNodes = [rootNode nodesForXPath:xpathQueryString error:&error];
    
    NSXMLElement *doc = [newItemsNodes lastObject];
    
    NSString *rawHTML = [doc XMLString];
    rawHTML = [rawHTML stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    
    if (!rawHTML)//Prevent: NSScanner: nil string argument
        return nil;
    
	NSScanner *scanner = [NSScanner scannerWithString:rawHTML];
    NSString *finalString = @"";
	NSString *foundString = @"";
    NSString *br = @"";
    NSString *start = @"<span class=\"line line-s\" id=\"line_";
	NSString *end = @"</span>";
	while ([scanner isAtEnd] == NO) {
		if ([scanner scanUpToString:start intoString:&br] && [scanner scanString:start intoString:NULL] && [scanner scanUpToString:end intoString:&foundString]) {
            //Replace HTML newline tag with \n
            if ([[br lowercaseString] rangeOfString:@"</br>"].location != NSNotFound)
                finalString  = [finalString stringByAppendingString:@"\n"];
            
            NSRange range = NSMakeRange(0, [foundString rangeOfString:@">"].location + 1);
            foundString = [foundString stringByReplacingCharactersInRange:range withString:@""];
            
            //Remove [From:http://www.metrolyrics.com]
            if ([foundString rangeOfString:@"<span"].location == NSNotFound)
                finalString = [finalString stringByAppendingFormat:@"%@\n",foundString];
		}
	}
    
    return ([finalString isEqualToString:@""] ? nil : finalString);
    //return finalString;
}

@end