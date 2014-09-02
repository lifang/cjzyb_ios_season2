
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol TencentLoginViewDelegate;

@interface TencentLoginView : UIView <UIWebViewDelegate> {
    
    UIView *panelView;
    UIView *containerView;
    
	NSMutableDictionary *_params;
	NSString * _serverURL;
	NSURL* _loadingURL;
	UIWebView* _webView;
	UIActivityIndicatorView* _spinner;
	UIButton* _closeButton;

}

@property(nonatomic,assign) id<TencentLoginViewDelegate> delegate;

@property(nonatomic, retain) NSMutableDictionary* params;

@property(nonatomic,copy) NSString* title;

- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle;

- (id)initWithURL: (NSString *) serverURL
           params: (NSMutableDictionary *) params
         delegate: (id <TencentLoginViewDelegate>) delegate;

- (void)show:(BOOL)animated;

- (void)load;

- (void)loadURL:(NSString*)url
            get:(NSDictionary*)getParams;

- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated;

- (void)dismissWithError:(NSError*)error animated:(BOOL)animated;

- (void)dialogWillAppear;

- (void)dialogWillDisappear;

- (void)dialogDidSucceed:(NSURL *)url;

- (void)dialogDidCancel:(NSURL *)url;
@end


@protocol TencentLoginViewDelegate <NSObject>

@optional

- (void)dialogDidComplete:(TencentLoginView *)dialog;

- (void)dialogCompleteWithUrl:(NSURL *)url;

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url;

- (void)dialogDidNotComplete:(TencentLoginView *)dialog;

- (void)tencentDidNotNetWork;
- (void)dialog:(TencentLoginView*)dialog didFailWithError:(NSError *)error;

- (void)tencentDialogLogin:(NSString*)token expirationDate:(NSDate*)expirationDate;

- (void)tencentDialogNotLogin:(BOOL)cancelled;

@end
