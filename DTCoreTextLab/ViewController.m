//
//  ViewController.m
//  DTCoreTextLab
//
//  Created by Kolyvan on 11.07.13.
//  Copyright (c) 2013 Konstantin Bukreev. All rights reserved.
//

#import "ViewController.h"
#import "DTAttributedTextView.h"
#import "NSAttributedString+HTML.h"

@interface ViewController ()

@end

@implementation ViewController {
    
    DTAttributedTextView        *_textView;
    UIActivityIndicatorView     *_activityIndicatorView;

}

- (id) init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
    }
    return self;
}

- (void) loadView
{
    const CGRect frame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareHTMLView];
}

+ (NSAttributedString *) loadHTML:(CGSize)imageSize
{
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"content-0009" ofType:@"xhtml"];
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"content-0011" ofType:@"xhtml"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content-0017" ofType:@"xhtml"];
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *options = @{
                              DTMaxImageSize          : [NSValue valueWithCGSize:imageSize],
                              NSBaseURLDocumentOption : [NSURL fileURLWithPath:path],
                              DTProcessCustomHTMLAttributes : @(NO),
                              };
    
    NSLog(@"initializing the attribute string ..");
    NSDate *timestamp = [NSDate date];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data
                                                                      options:options
                                                           documentAttributes:NULL];
    
    NSLog(@"complete in %.3f sec.", -[timestamp timeIntervalSinceNow]);
    
    return string;
}

- (void) prepareHTMLView
{   
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.center = self.view.center;
    [_activityIndicatorView startAnimating];
    [self.view addSubview:_activityIndicatorView];
    
    const CGSize imageSize = {
        self.view.bounds.size.width - 20.0,
        self.view.bounds.size.height - 20.0
    };
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        NSAttributedString *string = [ViewController loadHTML:imageSize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf didLoadHTML:string];
        });        
    });
    
}

- (void) didLoadHTML:(NSAttributedString *)string
{
    _textView = [[DTAttributedTextView alloc] initWithFrame:self.view.bounds];
    [_textView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    _textView.contentInset = UIEdgeInsetsMake(10, 10, 54, 10);
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_textView];
    
    _textView.attributedString = string;
    
    [_activityIndicatorView removeFromSuperview];
    _activityIndicatorView = nil;
}

@end
