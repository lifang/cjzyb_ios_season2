//
//  LeftTabBarView.m
//  cjzyb_ios
//
//  Created by david on 14-2-26.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "LeftTabBarView.h"
@interface LeftTabBarView()

@end
@implementation LeftTabBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)defaultSelected{
    [self unSelectedAllItems];
}

-(void)unSelectedAllItems{
    self.mainTabBarItem.isSelected = NO;
    self.homeworkTabBarItem.isSelected = NO;
    self.notificationTabBarItem.isSelected = NO;
    self.carBarTabBarItem.isSelected = NO;
    self.logOutItem.isSelected = NO;
}

- (IBAction)userGroupItemClicked:(id)sender {
    self.userGroupTabBarItem.isSelected = !self.userGroupTabBarItem.isSelected;
    [self.userGroupTabBarItem setUserInteractionEnabled:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(leftTabBar:selectedItem:)]) {
        [self.delegate leftTabBar:self selectedItem:LeftTabBarItemType_userGroup];
    }
}

- (IBAction)carBagItemClicked:(id)sender {
    [self unSelectedAllItems];
    self.carBarTabBarItem.isSelected = YES;
    [self.delegate leftTabBar:self selectedItem:LeftTabBarItemType_carBag];
}

- (IBAction)notificationItemClicked:(id)sender {
    [self unSelectedAllItems];
    self.notificationTabBarItem.isSelected = YES;
    [self.delegate leftTabBar:self selectedItem:LeftTabBarItemType_notification];
}

- (IBAction)homeworkItemClicked:(id)sender {
    [self unSelectedAllItems];
    self.homeworkTabBarItem.isSelected = YES;
    [self.delegate leftTabBar:self selectedItem:LeftTabBarItemType_homework];
}

- (IBAction)mainItemClicked:(id)sender {
    [self unSelectedAllItems];
    self.mainTabBarItem.isSelected = YES;
    [self.delegate leftTabBar:self selectedItem:LeftTabBarItemType_main];
}

-(IBAction)logOutItemClicked:(id)sender {
    [self unSelectedAllItems];
    self.logOutItem.isSelected = YES;
    [self.delegate leftTabBar:self selectedItem:LeftTabBarItemType_logOut];
}
@end
