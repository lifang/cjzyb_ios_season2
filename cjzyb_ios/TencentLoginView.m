//
//  TencentLoginView.m
//  TencentOAuthDemo
//
//  Created by cloudxu on 11-8-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "TencentLoginView.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <QuartzCore/QuartzCore.h>

@interface TencentLoginView (Private)
- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;
- (void)bounceNormalAnimationStopped;
- (void)allAnimationsStopped;
@end

static CGFloat kTransitionDuration = 0.3;

BOOL TencentIsDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	}
#endif
	return NO;
}



///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TencentLoginView

@synthesize delegate = _delegate,params   = _params;


- (void)addRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect radius:(float)radius {
	CGContextBeginPath(context);
	CGContextSaveGState(context);
	
	if (radius == 0) {
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
	} else {
		rect = CGRectOffset(CGRectInset(rect, 0.5, 0.5), 0.5, 0.5);
		CGContextTranslateCTM(context, CGRectGetMinX(rect)-0.5, CGRectGetMinY(rect)-0.5);
		CGContextScaleCTM(context, radius, radius);
		float fw = CGRectGetWidth(rect) / radius;
		float fh = CGRectGetHeight(rect) / radius;
		
		CGContextMoveToPoint(context, fw, fh/2);
		CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
		CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
		CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
		CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	}
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect fill:(const CGFloat*)fillColors radius:(CGFloat)radius {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	if (fillColors) {
		CGContextSaveGState(context);
		CGContextSetFillColor(context, fillColors);
		if (radius) {
			[self addRoundedRectToPath:context rect:rect radius:radius];
			CGContextFillPath(context);
		} else {
			CGContextFillRect(context, rect);
		}
		CGContextRestoreGState(context);
	}
	
	CGColorSpaceRelease(space);
}

- (void)strokeLines:(CGRect)rect stroke:(const CGFloat*)strokeColor {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	
	CGContextSaveGState(context);
	CGContextSetStrokeColorSpace(context, space);
	CGContextSetStrokeColor(context, strokeColor);
	CGContextSetLineWidth(context, 1.0);
	
	{
		CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y-0.5},
			{rect.origin.x+rect.size.width, rect.origin.y-0.5}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y+rect.size.height-0.5},
			{rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height-0.5}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {{rect.origin.x+rect.size.width-0.5, rect.origin.y},
			{rect.origin.x+rect.size.width-0.5, rect.origin.y+rect.size.height}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	{
		CGPoint points[] = {{rect.origin.x+0.5, rect.origin.y},
			{rect.origin.x+0.5, rect.origin.y+rect.size.height}};
		CGContextStrokeLineSegments(context, points, 2);
	}
	
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(space);
}

- (void)bounceOutAnimationStopped{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceInAnimationStopped)];
    [panelView setAlpha:0.8];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
	[UIView commitAnimations];
}
- (void)bounceInAnimationStopped{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceNormalAnimationStopped)];
    [panelView setAlpha:1.0];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)];
	[UIView commitAnimations];
}
- (void)bounceNormalAnimationStopped{
    [self allAnimationsStopped];
}
- (void)allAnimationsStopped{
    
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8);
			
			[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
			[escaped_value release];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];

		
		return [NSURL URLWithString:url];
	} 
	else {
		return [NSURL URLWithString:baseURL];
	}
}

- (void)postDismissCleanup {
	[self removeFromSuperview];
}

- (void)dismiss:(BOOL)animated {
	[self dialogWillDisappear];
	
	[_loadingURL release];
	_loadingURL = nil;
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kTransitionDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
		self.alpha = 0;
		[UIView commitAnimations];
	} else {
		[self postDismissCleanup];
	} 
}

- (void)cancel {
	[self dialogDidCancel:nil];
	if ([_delegate respondsToSelector:@selector(tencentDialogNotLogin:)]) {
		[_delegate tencentDialogNotLogin:YES];
	}	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super initWithFrame:[UIScreen mainScreen].applicationFrame]) {
		_delegate = nil;
		_loadingURL = nil;
        
		self.backgroundColor = [UIColor clearColor];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentMode = UIViewContentModeRedraw;
		
        
        // add the panel view
        panelView = [[UIView alloc] initWithFrame:CGRectMake(34, 30, 700, self.frame.size.height - 50)];
        [panelView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.55]];
        [[panelView layer] setMasksToBounds:NO]; // very important
        [[panelView layer] setCornerRadius:10.0];
        [self addSubview:panelView];
        
        // add the conainer view
        containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 680, self.frame.size.height - 70)];
        [[containerView layer] setBorderColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7].CGColor];
        [[containerView layer] setBorderWidth:1.0];
        
        
        // add the web view
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 680, self.frame.size.height - 70)];
		[_webView setDelegate:self];
		[containerView addSubview:_webView];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(self.frame.size.width - 130, 5,35, 35);
        [_closeButton setImage:[UIImage imageNamed:@"login_close.png"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage imageNamed:@"login_close_selected.png"] forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [containerView addSubview:_closeButton];
        
        [panelView addSubview:containerView];
        
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_spinner setCenter:CGPointMake(384, ([UIScreen mainScreen].applicationFrame.size.height)/2)];
        [self addSubview:_spinner];


	}
	return self;
}

- (void)dealloc {
	_webView.delegate = nil;
	[_webView release];
	[_params release];
	[_serverURL release];
	[_spinner release];
	[_closeButton release];
	[_loadingURL release];
	[super dealloc];
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[_spinner startAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
	NSURL* url = request.URL;
	
	NSRange start = [[url absoluteString] rangeOfString:@"access_token="];
	if (start.location != NSNotFound)
	{
		NSString * token = [self getStringFromUrl:[url absoluteString] needle:@"access_token="];
		NSString * expireTime = [self getStringFromUrl:[url absoluteString] needle:@"expires_in="];
		NSDate *expirationDate =nil;
		
		if (expireTime != nil) {
			int expVal = [expireTime intValue];
			if (expVal == 0) {
				expirationDate = [NSDate distantFuture];
			} else {
				expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
			} 
		} 
		
		if ((token == (NSString *) [NSNull null]) || (token.length == 0)) {
			[self dialogDidCancel:url];
			if ([_delegate respondsToSelector:@selector(tencentDialogNotLogin:)]) {
				[_delegate tencentDialogNotLogin:NO];
			}
		} else {
			if ([_delegate respondsToSelector:@selector(tencentDialogLogin:expirationDate:)]) {
				[_delegate tencentDialogLogin:token expirationDate:expirationDate];
			}
		}
		return NO;
	}
	else
	{
		return YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //修改服务器页面的meta的值
    NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=0.90, minimum-scale=0.90, maximum-scale=0.90, user-scalable=no\"", 280.00];
    [webView stringByEvaluatingJavaScriptFromString:meta];
    
	[_spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    if (error.code == -999) {
        return;
    }
    
	// 102 == WebKitErrorFrameLoadInterruptedByPolicyChange
	if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102)) {
		[self dismissWithError:error animated:YES];
		if ([_delegate respondsToSelector:@selector(tencentDidNotNetWork)]) {
			[_delegate tencentDidNotNetWork];
		}	
		
	}
    
    [_spinner stopAnimating];

}

/**
 * Find a specific parameter from the url
 */
- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
	NSString * str = nil;
	NSRange start = [url rangeOfString:needle];
	if (start.location != NSNotFound) {
		NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
		NSUInteger offset = start.location+start.length;
		str = end.location == NSNotFound
		? [url substringFromIndex:offset]
		: [url substringWithRange:NSMakeRange(offset, end.location)];
		str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	
	return str;
}

- (id)initWithURL: (NSString *) serverURL
           params: (NSMutableDictionary *) params
         delegate: (id <TencentLoginViewDelegate>) delegate {
	
	self = [self init];
	_serverURL = [serverURL retain];
	_params = [params retain];
	_delegate = delegate;
	
	return self;
}

- (void)load {
	[self loadURL:_serverURL get:_params];
}

- (void)loadURL:(NSString*)url get:(NSDictionary*)getParams {
	
	[_loadingURL release];
	_loadingURL = [[self generateURL:url params:getParams] retain];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:_loadingURL];
	
	[_webView loadRequest:request];
}

- (void)show:(BOOL)animated {
	[self load];

	
	UIWindow* window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	
	[window addSubview:self];
    
    if (animated)
    {
        [panelView setAlpha:0];
        CGAffineTransform transform = CGAffineTransformIdentity;
        [panelView setTransform:CGAffineTransformScale(transform, 0.3, 0.3)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounceOutAnimationStopped)];
        [panelView setAlpha:0.5];
        [panelView setTransform:CGAffineTransformScale(transform, 1.1, 1.1)];
        [UIView commitAnimations];
    }else{
        [self allAnimationsStopped];
    }

}

- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated {
	if (success) {
		if ([_delegate respondsToSelector:@selector(dialogDidComplete:)]) {
			[_delegate dialogDidComplete:self];
		}
	} else {
		if ([_delegate respondsToSelector:@selector(dialogDidNotComplete:)]) {
			[_delegate dialogDidNotComplete:self];
		}
	}
	
	[self dismiss:animated];
}

- (void)dismissWithError:(NSError*)error animated:(BOOL)animated {
	if ([_delegate respondsToSelector:@selector(dialog:didFailWithError:)]) {
		[_delegate dialog:self didFailWithError:error];
	}
	
	[self dismiss:animated];
}

- (void)dialogWillAppear {
}

- (void)dialogWillDisappear {
}

- (void)dialogDidSucceed:(NSURL *)url {
	
	if ([_delegate respondsToSelector:@selector(dialogCompleteWithUrl:)]) {
		[_delegate dialogCompleteWithUrl:url];
	}
	[self dismissWithSuccess:YES animated:YES];
}

- (void)dialogDidCancel:(NSURL *)url {
	if ([_delegate respondsToSelector:@selector(dialogDidNotCompleteWithUrl:)]) {
		[_delegate dialogDidNotCompleteWithUrl:url];
	}
	[self dismissWithSuccess:NO animated:YES];
}

@end
