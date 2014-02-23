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
- (NSString *)parseLyricWiki:(NSData *)rawData;
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
        lyricsFreak = [defaults boolForKey:kLyricsFreak];
        lyricWiki = true; //[defaults boolForKey:kLyricWiki];
        metroLyrics = false; //[defaults boolForKey:kMetroLyrics];
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
    
    if (lyricsFreak){
        //_responseCode[0]
    }
    
    if (lyricWiki){
        NSURLRequest *request = [NSURLRequest requestWithURL:[self urlFromSource:ITLyricWiki]];
        AFJSONRequestOperation *jop = [[AFJSONRequestOperation alloc] initWithRequest:request];
        [jop startAndWaitUntilFinished];
        
        NSString *lyric = [[jop responseJSON] objectForKey:@"lyrics"];
        
        if ([lyric isEqualToString:@"Not found"])
            _responseCode[1] = 404;
        else {//now that is know the lyric exist. go to lyricwiki page to get the lyric
            //lyricWiki can't show us the full lyric by API. so we go to their site grab the full lyric
            NSURL *url = [NSURL URLWithString:[[jop responseJSON] objectForKey:@"url"]];
            request = [NSURLRequest requestWithURL:url];
            AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [op startAndWaitUntilFinished];
            _responseCode[1] = [[op response] statusCode];
            
            if (_responseCode[1] == 200) {
                NSString *lyric = [self parseLyricWiki:op.responseData];
                //NSLog(@"%@",lyric);
                if (lyric)
                    [self.track setLyricWiki:lyric];
                else
                    _responseCode[1] = 404;
            }
        }
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
    
    dispatch_async(dispatch_get_main_queue(),^{
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
            //URL Formart: lyrics.wikia.com/api.php?fmt=realjson&artist=<#Artist#>&song=<#Song-Name#>
            NSString *url = [NSString stringWithFormat:@"fmt=realjson&artist=%@&song=%@",self.track.artist,self.track.name];
            url = [url stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            url = [@"http://lyrics.wikia.com/api.php?" stringByAppendingString:url];
            NSLog(@"%@",url);
            return [NSURL URLWithString:url];
        }
        case ITmetroLyrics:{
            //URL Format: metrolyrics.com/<#Song-Name#>-lyrics-<#Artist#>.html
            NSString *url = [NSString stringWithFormat:@"%@-lyrics-%@",self.track.name,self.track.artist];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            __block NSMutableArray *array = [[NSMutableArray alloc] init];
            
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

- (NSString *)parseLyricWiki:(NSData *)rawData{
    NSError *error;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:rawData options:NSXMLDocumentTidyHTML error:&error];
    NSXMLElement *rootNode = [document rootElement];
    NSArray *newItemsNodes = [rootNode nodesForXPath:@"//div[contains(@class,'lyricbox')]" error:&error];
    NSXMLElement *doc = [newItemsNodes lastObject];
    NSString *rawHTML = [doc XMLString];
    
    NSRange range = [rawHTML rangeOfString:@"</div>" options:NSCaseInsensitiveSearch];
    NSString *lyric = [rawHTML substringFromIndex:range.location+range.length];
    
    //HTML tags to be removed
    //TODO: remove all the remaining 
    NSArray *tags = @[@"<br>",@"</br>",@"<i>",@"</i>"];
    for (NSString *tag in tags){
        //lyric = [lyric stringByReplacingOccurrencesOfString:tag withString:@""];
        lyric = [lyric stringByReplacingOccurrencesOfString:tag withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, lyric.length)];
    }
    
    //TODO: do this using regular expression
    //remove everything after "<!--"
    NSRange cRange = [lyric rangeOfString:@"<!--" options:NSCaseInsensitiveSearch];
    if (cRange.location != NSNotFound)//temporary fix
        lyric = [lyric substringToIndex:cRange.location];
    
    return ([lyric isEqualToString:@""] ? nil : lyric);
    //return lyric;
}

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
            
            //Remove "[From:http://www.metrolyrics.com]"
            if ([foundString rangeOfString:@"<span"].location == NSNotFound)
                finalString = [finalString stringByAppendingFormat:@"%@\n",foundString];
		}
	}
    
    return ([finalString isEqualToString:@""] ? nil : finalString);
    //return finalString;
}

@end