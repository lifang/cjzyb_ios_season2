//
//  MainViewController.m
//  cjzyb_ios
//
//  Created by comdosoft on 14-2-26.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "MainViewController.h"

//4个子页面
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)tabBarInit {
    self.pagesContainer = [[DAPagesContainer alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = self.view.bounds;
    
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer didMoveToParentViewController:self];
    self.pagesContainer.topBarBackgroundColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1];
    
    //TODO:加入子页面
    FirstViewController *firstView = [[FirstViewController alloc]initWithNibName:@"FirstViewController" bundle:nil];
    firstView.title = @"first";
    firstView.view.frame = CGRectMake(0, self.pagesContainer.topBarHeight, 768, 1024-67-self.pagesContainer.topBarHeight);

    SecondViewController *secondView = [[SecondViewController alloc]initWithNibName:@"SecondViewController" bundle:nil];
    secondView.title = @"second";
    secondView.view.frame = firstView.view.frame;
    [secondView viewDidAppear:NO];
    
    ThirdViewController *thirdView = [[ThirdViewController alloc]initWithNibName:@"ThirdViewController" bundle:nil];
    thirdView.title = @"third";
    thirdView.view.frame = firstView.view.frame;
    
    FourthViewController *fourthView = [[FourthViewController alloc]initWithNibName:@"FourthViewController" bundle:nil];
    fourthView.title = @"fourth";
    fourthView.view.frame = firstView.view.frame;
    
    self.pagesContainer.viewControllers = [NSArray arrayWithObjects:firstView,secondView,fourthView,thirdView, nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (platform>=7.0) {
        AppDelegate *appDel = [AppDelegate shareIntance];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.view.frame = CGRectMake(0, 0, appDel.window.frame.size.width, appDel.window.frame.size.height-67);
    }
    
    [self tabBarInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedViewController:) name:@"selectedViewController" object:nil];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(void)selectedViewController:(NSNotification *)notification {
    [self.pagesContainer setSelectedIndex:0 animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
