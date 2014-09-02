//
//  HomeworkHistoryCollectionCell.m
//  cjzyb_ios
//
//  Created by david on 14-2-28.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "HomeworkHistoryCollectionCell.h"

@interface HomeworkHistoryCollectionCell()

@end
@implementation HomeworkHistoryCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(HomeworkDailyCollectionViewController *)dailyCollectionViewController{
    if (!_dailyCollectionViewController) {
        _dailyCollectionViewController = [[HomeworkDailyCollectionViewController alloc] initWithNibName:@"HomeworkDailyCollectionViewController" bundle:nil];
    }
    return _dailyCollectionViewController;
}
@end
