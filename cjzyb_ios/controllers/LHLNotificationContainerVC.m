//
//  LHLNotificationContainerVC.m
//  cjzyb_ios
//
//  Created by apple on 14-3-31.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "LHLNotificationContainerVC.h"

@interface LHLNotificationContainerVC ()

@end

@implementation LHLNotificationContainerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self tabBarInit];

    [self setSelectedIndex:[DataService sharedService].notificationPage animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //如果通知页面有小红点,就刷新到该页面
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if(![[appDelegate.notification_dic objectForKey:[DataService sharedService].theClass.classId] isKindOfClass:[NSNull class]] && [appDelegate.notification_dic objectForKey:[DataService sharedService].theClass.classId] != nil){
        NSArray *noticeArray = [appDelegate.notification_dic objectForKey:[DataService sharedService].theClass.classId];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (((NSString *)[noticeArray firstObject]).integerValue == 1) {
                LHLNotificationViewController *noticeViewController = (LHLNotificationViewController *)[self.pagesContainer.viewControllers lastObject];
                [noticeViewController requestSysNoticeWithStudentID:[DataService sharedService].user.studentId andClassID:[DataService sharedService].theClass.classId andPage:@"1"];
                [self setSelectedIndex:1 animated:YES];
            }else if(noticeArray.count > 1 && ((NSString *)noticeArray[1]).integerValue == 1){
                LHLReplyNotificationViewController *replyNotificationViewController = (LHLReplyNotificationViewController *)[self.pagesContainer.viewControllers firstObject];
                [replyNotificationViewController requestMyNoticeWithUserID:[DataService sharedService].user.userId andClassID:[DataService sharedService].theClass.classId andPage:@"1"];
                [self setSelectedIndex:0 animated:YES];
            }
        });
    }
}

- (void)tabBarInit{
    self.pagesContainer = [[DAPagesContainer alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = self.view.bounds;
    
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];
    [self addChildViewController:self.pagesContainer];
    self.pagesContainer.topBarBackgroundColor = [UIColor colorWithRed:0.8235 green:0.8275 blue:0.8314 alpha:1];
    
    //加入子页面
    LHLReplyNotificationViewController *replyVC = [[LHLReplyNotificationViewController alloc] initWithNibName:@"LHLReplyNotificationViewController" bundle:nil];
    replyVC.title = @"回复通知";
    replyVC.view.frame = (CGRect){0, self.pagesContainer.topBarHeight, 768, 1024-67-self.pagesContainer.topBarHeight};
    
    LHLNotificationViewController *notiVC = [[LHLNotificationViewController alloc] initWithNibName:@"LHLNotificationViewController" bundle:nil];
    notiVC.title = @"系统通知";
    notiVC.view.frame = (CGRect){0, self.pagesContainer.topBarHeight, 768, 1024-67-self.pagesContainer.topBarHeight};
    
    self.pagesContainer.viewControllers = [NSArray arrayWithObjects:replyVC,notiVC,nil];
    
    [self.pagesContainer.topBar setDAPagesContainerTopBarItemsOffset:3.1415926];
    [self.pagesContainer.topBar setDAPagesContainerTopBarItemViewWidth:self.pagesContainer.view.frame.size.width / 3];
    
    [self.pagesContainer.topBar layoutSubviews];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated{
    if (self.pagesContainer) {
        [self.pagesContainer setSelectedIndex:index animated:animated];
        [self.pagesContainer.topBar layoutSubviews];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
