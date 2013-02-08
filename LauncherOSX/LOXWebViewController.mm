//
//  LOXWebViewController.m
//  LauncherOSX
//
//  Created by Boris Schneiderman.
//  Copyright (c) 2012-2013 The Readium Foundation.
//
//  The Readium SDK is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "LOXWebViewController.h"
#import "LOXePubApi.h"
#import "LOXPageNumberTextController.h"


@interface LOXWebViewController ()
- (void)updateUI;

@end

@implementation LOXWebViewController


- (void)displayHtml:(NSString *)html withBaseUrlPath:(NSString *) baseUrlPath
{
    NSURL *baseUrl = [NSURL fileURLWithPath:baseUrlPath];
    [[_webView mainFrame] loadHTMLString:html baseURL:baseUrl];
}


- (IBAction)onPrevPageClick:(id)sender
{
    WebScriptObject* script = [_webView windowScriptObject];
    [script evaluateWebScript:@"window.ReadiumSdk.Reader.getInstance().movePrevPage()"];
}


- (IBAction)onNextPageClick:(id)sender
{
    WebScriptObject* script = [_webView windowScriptObject];
    [script evaluateWebScript:@"window.ReadiumSdk.Reader.getInstance().moveNextPage()"];
}

- (void)openPageIndex:(int)pageIx
{
    WebScriptObject* script = [_webView windowScriptObject];
    [script evaluateWebScript:[NSString stringWithFormat:@"window.ReadiumSdk.Reader.getInstance().openPage(%d)", pageIx]];
}


-(void)displayUrlPath:(NSString *)urlPath
{
    NSURL* fileURL = [NSURL fileURLWithPath:urlPath];
    NSURLRequest* request = [NSURLRequest requestWithURL:fileURL  ];
    [[_webView mainFrame] loadRequest:request];
}

- (void)clear
{
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}



- (NSURLRequest *)webView:(WebView *)sender
                 resource:(id)identifier
          willSendRequest:(NSURLRequest *)request
         redirectResponse:(NSURLResponse *)redirectResponse
           fromDataSource:(WebDataSource *)dataSource
{

    NSString *path = request.URL.path;

    [self.epubApi prepareResourceWithPath: path];

    return request;
}

//this allows JavaScript to call the -logJavaScriptString: method
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
    if(sel == @selector(onOpenPageIndex:ofPages:))
        return NO;
    return YES;
}

//this returns a nice name for the method in the JavaScript environment
+(NSString*)webScriptNameForSelector:(SEL)sel
{
    if(sel == @selector(onOpenPageIndex:ofPages:))
        return @"onOpenPageIndexOfPages";
    return nil;
}


//this is called as soon as the script environment is ready in the webview
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
    //add the controller to the script environment
    //the "Cocoa" object will now be available to JavaScript
    [windowScriptObject setValue:self forKey:@"LauncherUI"];
}

//this is a simple log command
- (void)onOpenPageIndex:(int)index ofPages:(int)count
{
    [self.pageNumController setPageIndex:index ofPages:count];
    [self updateUI];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    NSLog(@"controlTextDidChange: stringValue == %@", [textField stringValue]);
}

- (void)updateUI
{
    [self.prevPageButton setEnabled:self.pageNumController.pageCount > 0 && self.pageNumController.pageIx > 0];
    [self.nextPageButton setEnabled:self.pageNumController.pageCount > 0 && self.pageNumController.pageIx < self.pageNumController.pageCount - 1];
}

@end
