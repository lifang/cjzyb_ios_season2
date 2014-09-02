//
//  HomeworkViewController.m
//  cjzyb_ios
//
//  Created by david on 14-2-28.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "HomeworkViewController.h"
#import "HomeworkHistoryCollectionCell.h"
#import "HomeworkDaoInterface.h"
#import "HomeworkRankingViewController.h"
#import "HomeworkContainerController.h"
//{"id": "181", "content": "This is! an aps!", "resource_url": "/question_packages/201402/questions_package_222/media_181.mp3"},
@interface HomeworkViewController ()
///选择的任务
@property (nonatomic,strong) HomeworkDailyCollectionViewController *selectedDailyController;

@property (nonatomic,strong) WYPopoverController *calendarPopController;
@property (nonatomic,strong) HomeworkContainerController *homeworkContainer;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

///顶部显示当前任务时显示
@property (weak, nonatomic) IBOutlet UIView *currentTopBackView;
///顶部显示历史任务时显示
@property (weak, nonatomic) IBOutlet UIView *historyTopBackView;

@property (weak, nonatomic) IBOutlet UILabel *currentDayTaskName;
@property (weak, nonatomic) IBOutlet UILabel *currentDayTaskEndTime;
@property (weak, nonatomic) IBOutlet UILabel *currentDay;
///底部显示历史任务发布时间
@property (weak, nonatomic) IBOutlet UILabel *historyStartTaskLabel;
///底部显示历史任务名称
@property (weak, nonatomic) IBOutlet UILabel *historyNameLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
///底部向左滑动的按钮
@property (weak, nonatomic) IBOutlet UIButton *leftSwipButton;
///底部向右滑动的按钮
@property (weak, nonatomic) IBOutlet UIButton *rightSwipButton;
///显示历史任务
- (IBAction)historyButtonClicked:(id)sender;
///显示日历
- (IBAction)calendarButtonClicked:(id)sender;
///回到当前记录
- (IBAction)backButtonClicked:(id)sender;
///显示上一次的历史任务
- (IBAction)leftSwipButtonClicked:(id)sender;
///显示下一次的历史任务
- (IBAction)rightSwipButtonClicked:(id)sender;


@end

@implementation HomeworkViewController
-(AppDelegate *)appDel {
    if (!_appDel) {
        _appDel = [AppDelegate shareIntance];
    }
    return _appDel;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)refreshData:(id)sender {
    NSArray *visibleItemIndexPath  = [self.collectionView indexPathsForVisibleItems];
    if (visibleItemIndexPath && visibleItemIndexPath.count > 0) {
        NSIndexPath *path = visibleItemIndexPath.firstObject;
        if (path.item -1 >= 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
    }
    
    [self getHomeworkData];
}
-(void)getHomeworkData {
    __weak HomeworkViewController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    DataService *data = [DataService sharedService];
    [HomeworkDaoInterface downloadCurrentTaskWithUserId:data.user.studentId withClassId:data.theClass.classId withSuccess:^(NSArray *taskObjArr) {
        [self performSelectorOnMainThread:@selector(postNotification) withObject:nil waitUntilDone:NO];
        HomeworkViewController *tempSelf= weakSelf;
        if (tempSelf) {
            tempSelf.currentDayTaskArray = [NSMutableArray arrayWithArray:taskObjArr];
            if (tempSelf.currentDayTaskArray.count==0) {
                self.currentDay.hidden = NO;
                self.currentDay.text = @"今日暂无作业";
            }
            tempSelf.isShowHistory = NO;
            [tempSelf.collectionView reloadData];
            [MBProgressHUD hideAllHUDsForView:tempSelf.view animated:YES];
        }
    } withError:^(NSError *error) {
        HomeworkViewController *tempSelf= weakSelf;
        if (tempSelf) {
            
            [MBProgressHUD hideAllHUDsForView:tempSelf.view animated:YES];
        }
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isShowHistory = NO;
    [self.collectionView registerClass:[HomeworkHistoryCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.flowLayout setItemSize:(CGSize){CGRectGetWidth(self.collectionView.frame),CGRectGetHeight(self.collectionView.frame)}];
    [self.flowLayout setMinimumInteritemSpacing:0];
    [self.flowLayout setMinimumLineSpacing:0];
    [self.flowLayout setSectionInset:UIEdgeInsetsZero];
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    [self getHomeworkData];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![[self.appDel.notification_dic objectForKey:[DataService sharedService].theClass.classId]isKindOfClass:[NSNull class]] && [self.appDel.notification_dic objectForKey:[DataService sharedService].theClass.classId]!=nil) {
        NSArray *array = [self.appDel.notification_dic objectForKey:[DataService sharedService].theClass.classId];
        
        int value = [[array objectAtIndex:2]integerValue];
        if (value == 1) {
            [self getHomeworkData];
        }
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)historyButtonClicked:(id)sender {
    __weak HomeworkViewController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    DataService *data = [DataService sharedService];
    [HomeworkDaoInterface downloadHistoryTaskWithUserId:data.user.studentId withClassId:data.theClass.classId withCurrentTaskID:self.taskObj.taskID withSuccess:^(NSArray *taskObjArr) {
        HomeworkViewController *tempSelf= weakSelf;
        if (tempSelf) {
            tempSelf.allHistoryTaskArray = [NSMutableArray arrayWithArray:taskObjArr];
            [DataService sharedService].historyTaskArray = tempSelf.allHistoryTaskArray;
            tempSelf.isShowHistory = YES;
            [tempSelf.collectionView reloadData];
            [MBProgressHUD hideAllHUDsForView:tempSelf.view animated:YES];
        }
    } withError:^(NSError *error) {
        HomeworkViewController *tempSelf= weakSelf;
        if (tempSelf) {
            [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
            [MBProgressHUD hideAllHUDsForView:tempSelf.view animated:YES];
        }
    }];

}

- (IBAction)calendarButtonClicked:(id)sender {

    CalendarViewController *calendarViewContr = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
    self.calendarPopController = [[WYPopoverController alloc] initWithContentViewController:calendarViewContr];
    self.calendarPopController.theme.tintColor = [UIColor colorWithRed:53./255. green:207./255. blue:143./255. alpha:1.0];
    self.calendarPopController.theme.fillTopColor = [UIColor colorWithRed:53./255. green:207./255. blue:143./255. alpha:1.0];
    self.calendarPopController.theme.fillBottomColor = [UIColor colorWithRed:53./255. green:207./255. blue:143./255. alpha:1.0];
    self.calendarPopController.theme.glossShadowColor = [UIColor colorWithRed:53./255. green:207./255. blue:143./255. alpha:1.0];
    
    calendarViewContr.selectedDateBlock =   ^(NSString *dateString){
        NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"taskStartDate", dateString];
        NSMutableArray  *filteredArray = [NSMutableArray arrayWithArray:[[DataService sharedService].historyTaskArray filteredArrayUsingPredicate:predicateString]];
        if (filteredArray.count>0) {
            self.historyNameLabel.hidden = NO;
            self.historyStartTaskLabel.hidden = NO;
            self.allHistoryTaskArray = [NSMutableArray arrayWithArray:filteredArray];
        }else {
            self.historyNameLabel.hidden = YES;
            self.historyStartTaskLabel.text = @"暂无作业";
            self.allHistoryTaskArray = nil;
        }
        self.isShowHistory = YES;
        [self.collectionView reloadData];

    };
    self.calendarPopController.popoverContentSize = (CGSize){500,583};
    CGRect frame = [(UIButton*)sender frame];
    frame.origin.y -= 10;
    [self.calendarPopController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES completion:^{
        
    }];
}

- (IBAction)backButtonClicked:(id)sender {
    self.isShowHistory = NO;
    NSArray *visibleItemIndexPath  = [self.collectionView indexPathsForVisibleItems];
    if (visibleItemIndexPath && visibleItemIndexPath.count > 0) {
        NSIndexPath *path = visibleItemIndexPath.firstObject;
        if (path.item -1 >= 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
    }
    
    [DataService sharedService].historyTaskArray = nil;
    
    if (self.currentDayTaskArray.count==0) {
        self.historyNameLabel.hidden = YES;
        self.historyStartTaskLabel.hidden = YES;
        self.currentDay.hidden = NO;
        self.currentDay.text = @"今日暂无作业";
    }
    [self.collectionView reloadData];
}

- (IBAction)leftSwipButtonClicked:(id)sender {
    NSArray *visibleItemIndexPath  = [self.collectionView indexPathsForVisibleItems];
    if (visibleItemIndexPath && visibleItemIndexPath.count > 0) {
        NSIndexPath *path = visibleItemIndexPath.firstObject;
        if (path.item -1 >= 0) {
             [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:path.item-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }

        if (path.item - 1 > 0 ) {
            [self.leftSwipButton setHidden:NO];
        }else{
            [self.leftSwipButton setHidden:YES];
        }
        [self.rightSwipButton setHidden:NO];
        if (self.isShowHistory) {
            if (self.allHistoryTaskArray.count <= 1) {
                [self.rightSwipButton setHidden:YES];
                [self.leftSwipButton setHidden:YES];
            }
        }else {
            if (self.currentDayTaskArray.count <= 1) {
                [self.rightSwipButton setHidden:YES];
                [self.leftSwipButton setHidden:YES];
            }
        }
        
    }
}

- (IBAction)rightSwipButtonClicked:(id)sender {
    NSArray *visibleItemIndexPath  = [self.collectionView indexPathsForVisibleItems];
    if (visibleItemIndexPath && visibleItemIndexPath.count > 0) {
        NSIndexPath *path = visibleItemIndexPath.firstObject;
        if (self.isShowHistory) {
            if (path.item+1 < self.allHistoryTaskArray.count) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:path.item+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            }
            
            if (path.item+1 == self.allHistoryTaskArray.count-1) {
                [self.rightSwipButton setHidden:YES];
            }else{
                [self.rightSwipButton setHidden:NO];
            }
            [self.leftSwipButton setHidden:NO];
            if (self.allHistoryTaskArray.count <= 1) {
                [self.rightSwipButton setHidden:YES];
                [self.leftSwipButton setHidden:YES];
            }
        }else {
            if (path.item+1 < self.currentDayTaskArray.count) {
                [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:path.item+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            }
            
            if (path.item+1 == self.currentDayTaskArray.count-1) {
                [self.rightSwipButton setHidden:YES];
            }else{
                [self.rightSwipButton setHidden:NO];
            }
            [self.leftSwipButton setHidden:NO];
            if (self.currentDayTaskArray.count <= 1) {
                [self.rightSwipButton setHidden:YES];
                [self.leftSwipButton setHidden:YES];
            }
        }
        
    }
}

#pragma mark UIAlertViewDelegate
-(void)postNotification {
    if (![[self.appDel.notification_dic objectForKey:[DataService sharedService].theClass.classId]isKindOfClass:[NSNull class]] && [self.appDel.notification_dic objectForKey:[DataService sharedService].theClass.classId]!=nil) {
    NSArray *array = [self.appDel.notification_dic objectForKey:[DataService sharedService].theClass.classId];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    [mutableArray replaceObjectAtIndex:2 withObject:@"0"];
    [self.appDel.notification_dic setObject:mutableArray forKey:[DataService sharedService].theClass.classId];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadByNotification" object:mutableArray];
    }
}
#pragma mark - 弹出层
- (void)dismissPopView:(AlertViewController *)alertView andType:(NSInteger)type{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];
    if (alertView.isSuccess == NO) {
        if (type==1) {//重新答题
            [DataService sharedService].isHistory = NO;
            [self presentViewController:self.homeworkContainer animated:YES completion:^{
                [self.selectedDailyController.collectionView reloadData];
            }];
        }
    }else {
        if (type==0) {//下载
             __block TaskObj *task = [DataService sharedService].taskObj;
            AppDelegate *app = [AppDelegate shareIntance];
            __block MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:app.window animated:YES];
            progress.labelText = @"正在下载作业包，请稍后...";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                ;
                NSDictionary *dicData = [Utility downloadQuestionWithAddress:task.taskFileDownloadURL andStartDate:task.taskStartDate];
                if (![task.taskAnswerFileDownloadURL isKindOfClass:[NSNull class]] && task.taskAnswerFileDownloadURL.length>10) {
                    [Utility downloadAnswerWithAddress:task.taskAnswerFileDownloadURL andStartDate:task.taskStartDate];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!dicData || dicData.count <= 0) {
                        [MBProgressHUD hideHUDForView:app.window animated:YES];
                        [Utility errorAlert:@"下载作业数据包失败"];
                    }else{
                        progress.labelText = @"作业包下载成功";
                        [progress hide:YES afterDelay:1];
                    }
                });
            });
        }else {//查看历史记录
            [DataService sharedService].isHistory = YES;
            [self presentViewController:self.homeworkContainer animated:YES completion:^{
                [self.selectedDailyController.collectionView reloadData];
            }];
        }
    }
    
    self.alertViewControl = nil;
}

#pragma mark - 查看历史或重新答题
-(void)showAlertWith:(HomeworkTypeObj *)typeObj {
    //判断卡包
    if ([DataService sharedService].cardsCount >=20) {
        MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.appDel.window animated:YES];
        progress.labelText = @"卡包数量大于20,先去清理卡包";
        [progress hide:YES afterDelay:1];
    }else {
        if (typeObj.homeworkTypeIsFinished) {
            self.alertViewControl = [[AlertViewController alloc]initWithNibName:@"AlertViewController" bundle:nil];
            self.alertViewControl.delegate = self;
            self.alertViewControl.type = 1;
            [self presentPopupViewController:self.alertViewControl animationType:MJPopupViewAnimationSlideBottomBottom];
        }else{
            [DataService sharedService].isHistory = NO;
            [self presentViewController:self.homeworkContainer animated:YES completion:^{
                [self.selectedDailyController.collectionView reloadData];
            }];
        }
    }
}
#pragma mark HomeworkDailyCollectionViewControllerDelegate每一个题目类型cell代理
-(void)homeworkDailyController:(HomeworkDailyCollectionViewController *)controller didSelectedAtIndexPath:(NSIndexPath *)path{
    if ([DataService sharedService].user.active_status == 2) {
        [Utility errorAlert:@"暂未进行激活，无法作答作业"];
    }else {
        HomeworkTypeObj *typeObj = [controller.taskObj.taskHomeworkTypeArray objectAtIndex:path.item];
        TaskObj *task = controller.taskObj;
        [DataService sharedService].taskObj = task;
        self.selectedDailyController = controller;
        HomeworkContainerController *homeworkContainer = [[HomeworkContainerController alloc ] initWithNibName:@"HomeworkContainerController" bundle:nil];
        homeworkContainer.homeworkType = typeObj.homeworkType;
        self.homeworkContainer = homeworkContainer;
        homeworkContainer.spendSecond = 0;
        
        if ([Utility judgeQuestionJsonFileIsExistForTaskObj:task]) {//存在question
            NSInteger status = [Utility judgeAnswerJsonFileIsLastVersionForTaskObj:task];
            //0:不存在answer文件   1:存在不是最新的  2:最新的
            if (task.isExpire == YES) {
                if (status==1) {//存在不是最新的
                    AppDelegate *app = [AppDelegate shareIntance];
                    __block MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:app.window animated:YES];
                    progress.labelText = @"正在更新历史记录包，请稍后...";
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSDictionary *dicData = [Utility downloadAnswerWithAddress:task.taskAnswerFileDownloadURL andStartDate:task.taskStartDate];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!dicData || dicData.count <= 0) {
                                [Utility errorAlert:@"下载历史记录包失败"];
                            }else{
                                self.alertViewControl = [[AlertViewController alloc]initWithNibName:@"AlertViewController" bundle:nil];
                                self.alertViewControl.delegate = self;
                                self.alertViewControl.type = 1;
                                [self presentPopupViewController:self.alertViewControl animationType:MJPopupViewAnimationSlideBottomBottom];
                            }
                            [MBProgressHUD hideHUDForView:app.window animated:YES];
                        });
                    });
                }else {
                    self.alertViewControl = [[AlertViewController alloc]initWithNibName:@"AlertViewController" bundle:nil];
                    self.alertViewControl.delegate = self;
                    self.alertViewControl.type = 1;
                    [self presentPopupViewController:self.alertViewControl animationType:MJPopupViewAnimationSlideBottomBottom];
                }
            }else {
                if (status == 0) {
                    if (![task.taskAnswerFileDownloadURL isKindOfClass:[NSNull class]] && task.taskAnswerFileDownloadURL!=nil && task.taskAnswerFileDownloadURL.length>10) {
                        //answer的下载地址
                        AppDelegate *app = [AppDelegate shareIntance];
                        __block MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:app.window animated:YES];
                        progress.labelText = @"正在更新历史记录包，请稍后...";
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                            NSDictionary *dicData = [Utility downloadAnswerWithAddress:task.taskAnswerFileDownloadURL andStartDate:task.taskStartDate];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (!dicData || dicData.count <= 0) {
                                    [Utility errorAlert:@"下载历史记录包失败"];
                                }else{
                                    [self showAlertWith:typeObj];
                                }
                                [MBProgressHUD hideHUDForView:app.window animated:YES];
                            });
                        });
                    }else {
                        [self showAlertWith:typeObj];
                    }
                }else if (status==1) {//存在不是最新的
                    AppDelegate *app = [AppDelegate shareIntance];
                    __block MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:app.window animated:YES];
                    progress.labelText = @"正在更新历史记录包，请稍后...";
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSDictionary *dicData = [Utility downloadAnswerWithAddress:task.taskAnswerFileDownloadURL andStartDate:task.taskStartDate];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!dicData || dicData.count <= 0) {
                                [Utility errorAlert:@"下载历史记录包失败"];
                            }else{
                                [self showAlertWith:typeObj];
                            }
                            [MBProgressHUD hideHUDForView:app.window animated:YES];
                        });
                    });
                }else {
                    if (!self.isShowHistory) {
                        NSString *path = [Utility returnPath];
                        NSString *documentDirectory = [path stringByAppendingPathComponent:task.taskStartDate];
                        NSString *jsPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"answer_%@.json",[DataService sharedService].user.userId]];
                        NSError *error = nil;
                        Class JSONSerialization = [Utility JSONParserClass];
                        NSDictionary *dataObject = [JSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsPath] options:0 error:&error];
                        int isSuccess = [[dataObject objectForKey:@"isSuccessToUpload"]integerValue];
                        if (isSuccess == 1) {
                            [self showAlertWith:typeObj];
                        }else {
                            if (self.appDel.isReachable == NO) {
                                [Utility errorAlert:@"暂无网络!"];
                            }else {
                                [MBProgressHUD showHUDAddedTo:self.appDel.window animated:YES];
                                self.postInter = [[BasePostInterface alloc]init];
                                self.postInter.delegate = self;
                                [self.postInter postAnswerFileWith:task.taskStartDate];
                            }
                        }
                    }else {
                        [self showAlertWith:typeObj];
                    }
                }
            }
        }else{
            self.alertViewControl = [[AlertViewController alloc]initWithNibName:@"AlertViewController" bundle:nil];
            self.alertViewControl.delegate = self;
            self.alertViewControl.type = 0;
            
            [self presentPopupViewController:self.alertViewControl animationType:MJPopupViewAnimationSlideBottomBottom];
        }
    }
}

-(void)homeworkDailyController:(HomeworkDailyCollectionViewController *)controller rankingButtonClickedAtIndexPath:(NSIndexPath *)path{
    TaskObj *task = controller.taskObj;

    if (task.isExpire==YES) {
        HomeworkRankingViewController *rankingController = [[HomeworkRankingViewController alloc] initWithNibName:@"HomeworkRankingViewController" bundle:nil];
        rankingController.modalPresentationStyle = UIModalPresentationFormSheet;
        rankingController.view.frame = (CGRect){0,0,514,350};
        [self presentViewController:rankingController animated:YES completion:^{
            
        }];
        HomeworkTypeObj *typeObj = [controller.taskObj.taskHomeworkTypeArray objectAtIndex:path.item];
        [rankingController reloadDataWithTaskId:controller.taskObj.taskID withHomeworkType:typeObj.homeworkType];
    }else {
        [Utility errorAlert:@"暂无排名情况!"];
    }
}
#pragma mark --
#pragma mark UICollectionViewDataSource
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeworkHistoryCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (![cell.subviews containsObject:cell.dailyCollectionViewController.view]) {
        cell.dailyCollectionViewController.view.frame = (CGRect){10,0,cell.bounds.size.width-20,cell.bounds.size.height};
        [cell.dailyCollectionViewController resizeItemSize];
        [cell addSubview:cell.dailyCollectionViewController.view];
    }
    cell.dailyCollectionViewController.delegate = self;
    if (self.isShowHistory) {
        self.historyNameLabel.hidden = NO;
        self.historyStartTaskLabel.hidden = NO;
        self.currentDay.hidden = YES;
        self.currentDayTaskName.hidden = YES;
        self.currentDayTaskEndTime.hidden = YES;
        TaskObj *task = [self.allHistoryTaskArray objectAtIndex:indexPath.item];
        cell.dailyCollectionViewController.taskObj = task;
        self.historyStartTaskLabel.text = [NSString stringWithFormat:@"%@ 发布",task.taskStartDate];
        self.historyNameLabel.text = [NSString stringWithFormat:@"%@",task.taskName];
    }else{
        self.historyNameLabel.hidden = YES;
        self.historyStartTaskLabel.hidden = YES;
        self.currentDay.hidden = NO;
        
        if (self.currentDayTaskArray.count==0) {
            self.currentDay.text = @"今日暂无作业";
            self.currentDayTaskName.hidden = YES;
            self.currentDayTaskEndTime.hidden = YES;
        }else {
            self.currentDay.text = @"今日作业";
            self.currentDayTaskName.hidden = NO;
            self.currentDayTaskEndTime.hidden = NO;
            
            TaskObj *task = [self.currentDayTaskArray objectAtIndex:indexPath.item];
            cell.dailyCollectionViewController.taskObj = task;
            self.currentDayTaskName.text = [NSString stringWithFormat:@"%@",task.taskName];
            self.currentDayTaskEndTime.text = [NSString stringWithFormat:@"截止日期    %@",task.taskEndDate];
        }
    }
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.isShowHistory) {
        return self.allHistoryTaskArray.count;
    }else{
        return self.currentDayTaskArray.count;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.isShowHistory) {
        NSArray *visibleItemIndexPath  = [self.collectionView indexPathsForVisibleItems];
        if (visibleItemIndexPath && visibleItemIndexPath.count > 0) {
            NSIndexPath *indexPath = visibleItemIndexPath.firstObject;
            if (indexPath.item == 0) {
                [self.leftSwipButton setHidden:YES];
            }else{
                [self.leftSwipButton setHidden:NO];
            }
            
            if (indexPath.item == self.allHistoryTaskArray.count-1) {
                [self.rightSwipButton setHidden:YES];
            }else{
                [self.rightSwipButton setHidden:NO];
            }
            
        }
    }else {
        NSArray *visibleItemIndexPath  = [self.collectionView indexPathsForVisibleItems];
        if (visibleItemIndexPath && visibleItemIndexPath.count > 0) {
            NSIndexPath *indexPath = visibleItemIndexPath.firstObject;
            if (indexPath.item == 0) {
                [self.leftSwipButton setHidden:YES];
            }else{
                [self.leftSwipButton setHidden:NO];
            }
            
            if (indexPath.item == self.currentDayTaskArray.count-1) {
                [self.rightSwipButton setHidden:YES];
            }else{
                [self.rightSwipButton setHidden:NO];
            }
        }
    }
}
#pragma mark --

#pragma mark property
-(void)setIsShowHistory:(BOOL)isShowHistory{
    _isShowHistory = isShowHistory;
    [self.historyTopBackView setHidden:!isShowHistory];
    [self.currentTopBackView setHidden:isShowHistory];
    [self.historyStartTaskLabel setHidden:!isShowHistory];
    [self.leftSwipButton setHidden:YES];
    if (isShowHistory) {
        [self.rightSwipButton setHidden:self.allHistoryTaskArray.count > 1?NO:YES];
    }else{
        [self.rightSwipButton setHidden:self.currentDayTaskArray.count > 1?NO:YES];
    }
}

-(NSMutableArray *)allHistoryTaskArray{
    if (!_allHistoryTaskArray) {
        _allHistoryTaskArray = [NSMutableArray array];
    }
    return _allHistoryTaskArray;
}
#pragma mark
#pragma mark - PostDelegate
-(void)getPostInfoDidFinished:(NSDictionary *)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.appDel.window animated:YES];
            NSString *timeStr = [result objectForKey:@"updated_time"];
            [Utility returnAnswerPAthWithString:timeStr];
            [self getHomeworkData];
        });
    });
}
-(void)getPostInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.appDel.window animated:YES];
    [Utility errorAlert:errorMsg];
    [Utility uploadFaild];
}

#pragma mark --
@end
