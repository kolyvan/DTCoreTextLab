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

+ (NSAttributedString *) mkString:(NSData *)data
                        imageSize:(CGSize)imageSize
                          baseURL:(NSURL *)baseURL
{   
    NSDictionary *options = @{
                              DTMaxImageSize          : [NSValue valueWithCGSize:imageSize],
                              NSBaseURLDocumentOption : baseURL,
                              DTProcessCustomHTMLAttributes : @(NO),
                              };
    
    NSAttributedString *string;
    
    @autoreleasepool {
        
    
        string = [[NSAttributedString alloc] initWithHTMLData:data
                                                      options:options
                                           documentAttributes:NULL];
    }
    
    
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
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xhtml"];
        NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
        
        NSAttributedString *string;
        
        NSLog(@"loading html %d bytes", data.length);
        
        for (NSUInteger i = 0; i < 40; ++i) {
                    
            const NSTimeInterval ts1 = [NSDate timeIntervalSinceReferenceDate];
            
            string = [ViewController mkString:data imageSize:imageSize baseURL:[NSURL fileURLWithPath:path]];
                
            const NSTimeInterval ts2 = [NSDate timeIntervalSinceReferenceDate];
            NSLog(@"%02d. completed in %.3fs speed: %.1f",
                  i, ts2 - ts1, (CGFloat)string.length / (CGFloat)(ts2 - ts1) );
             
        }
        
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
