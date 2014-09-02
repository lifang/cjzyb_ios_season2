//
//  HomeworkDailyCollectionViewController.m
//  cjzyb_ios
//
//  Created by david on 14-2-28.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "HomeworkDailyCollectionViewController.h"

@interface HomeworkDailyCollectionViewController ()
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation HomeworkDailyCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)resizeItemSize{
    float itemWidth = CGRectGetWidth(self.view.frame)/3;
    [self.flowLayout setItemSize:(CGSize){itemWidth,itemWidth}];
    [self.flowLayout setMinimumInteritemSpacing:0];
    [self.flowLayout setMinimumLineSpacing:20];
    [self.flowLayout setSectionInset:UIEdgeInsetsZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HomeworkTypeCollctionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cell"];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self resizeItemSize];
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    [self.collectionView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark HomeworkTypeCollctionCellDelegate
-(void)homeworkTypeCollctionCell:(HomeworkTypeCollctionCell *)cell rankingButtonClickedAtIndexPath:(NSIndexPath *)path{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeworkDailyController:rankingButtonClickedAtIndexPath:)]) {
        [self.delegate homeworkDailyController:self rankingButtonClickedAtIndexPath:path];
    }
}
#pragma mark --


#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeworkDailyController:didSelectedAtIndexPath:)]) {
        [self.delegate homeworkDailyController:self didSelectedAtIndexPath:indexPath];
    }
}
#pragma mark --

#pragma mark UICollectionViewDataSource
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeworkTypeCollctionCell *cell = (HomeworkTypeCollctionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    HomeworkTypeObj *obj = [self.taskObj.taskHomeworkTypeArray objectAtIndex:indexPath.item];
    cell.isFinished = obj.homeworkTypeIsFinished;
    cell.homeworkType = obj.homeworkType;
    cell.isShowRankingBtn = obj.homeworkTypeIsRanking;
    cell.path = indexPath;
    cell.delegate = self;
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.taskObj.taskHomeworkTypeArray.count;
}
#pragma mark --

#pragma mark property
-(void)setTaskObj:(TaskObj *)taskObj{
    _taskObj = taskObj;
    [self.collectionView reloadData];
}

#pragma mark --

@end
