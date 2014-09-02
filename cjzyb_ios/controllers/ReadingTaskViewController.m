//
//  ReadingTaskViewController.m
//  cjzyb_ios
//
//  Created by david on 14-3-4.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "ReadingTaskViewController.h"

#import "DRSentenceSpellMatch.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeworkContainerController.h"
#import "ParseAnswerJsonFileTool.h"

#import "PreReadingTaskViewController.h"


#define APPID @"533e6dc2"
#define parentVC ((HomeworkContainerController *)[self parentViewController])
#define minRecoginCount 4
#define minRecoginLevel 0.5

@interface ReadingTaskViewController ()
@property (nonatomic,assign) BOOL shouldUpload;  //是否应该上传JSON
///预听界面
@property (nonatomic,strong) PreReadingTaskViewController *preReadingController;
@property (nonatomic,strong) AVAudioPlayer *avPlayer;
///当前读句子下标
@property (nonatomic,assign) int currentSentenceIndex;
///当前所做大题下标
@property (nonatomic,assign) int currentHomeworkIndex;
///读匹配次数
@property (nonatomic,assign) int readingCount;

@property (strong,nonatomic) NSMutableArray *propsArray;//道具

///是否在读内容
@property (nonatomic,assign) BOOL isReading;
///是否在听
@property (nonatomic,assign) BOOL isListening;
@property (weak, nonatomic) IBOutlet UIView *tipBackView;
@property (weak, nonatomic) IBOutlet UITextView *tipTextView;
///要读的文字内容
@property (weak, nonatomic) IBOutlet UITextView *readingTextView;
/// 点击开始录音按钮
@property (weak, nonatomic) IBOutlet UIButton *readingButton;
///点击开始听内容按钮
@property (weak, nonatomic) IBOutlet UIButton *listeningButton;
///显示当前题号 (3/5)
@property (strong,nonatomic) UILabel *currentNOLabel;
///当前小题已经读对的单词
@property (strong,nonatomic) __block NSMutableArray *rightWordArray;

/// 点击开始录音
- (IBAction)readingButtonClicked:(id)sender;

///点击开始听内容
- (IBAction)listeningButtonClicked:(id)sender;

@property (nonatomic,assign) BOOL currentSentencePassed; //当前题目是否及格

@property (nonatomic, assign) BOOL exitButtonHasBeenClicked; //用户点击了"退出"按钮
@end

@implementation ReadingTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([DataService sharedService].isHistory) {
        //初始化浏览历史
        [self.tipBackView setHidden:NO];
        [self.readingButton setHidden:YES];
        TaskObj *task = [DataService sharedService].taskObj;
        __weak ReadingTaskViewController *weakSelf = self;
        
        [ParseAnswerJsonFileTool parseAnswerJsonFileWithUserId:[DataService sharedService].user.userId withTask:task withReadingHistoryArray:^(NSArray *readingQuestionArr, int currentQuestionIndex, int currentQuestionItemIndex, int status, NSString *updateTime, NSString *userTime, int specifyTime,float ratio) {
            ReadingTaskViewController *tempSelf = weakSelf;
            if (tempSelf) {
                parentVC.timeLabel.text = [NSString stringWithFormat:@"%@",[Utility  formateDateStringWithSecond:userTime.intValue]];
                parentVC.rotioLabel.text = [NSString stringWithFormat:@"%.f%%",ratio * 100];
                [parentVC.checkHomeworkButton setTitle:@"下一个" forState:UIControlStateNormal];
                tempSelf.readingHomeworksArr = readingQuestionArr;
                tempSelf.isFirst = NO;
                tempSelf.currentSentenceIndex = 0;
                tempSelf.currentHomeworkIndex = 0;
                [tempSelf updateFirstSentence];
                self.view.hidden = NO;
            }
        } withParseError:^(NSError *error) {
            self.view.hidden = NO;
            [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
        }];
    }else{
        [self.tipBackView setHidden:YES];
        [self.readingButton setHidden:NO];
        int timeCount = [DataService sharedService].number_reduceTime;
        if (timeCount <= 0) {
            [parentVC.reduceTimeButton setEnabled:NO];
        }else{
            if (self.isFirst) {
                [parentVC.reduceTimeButton setEnabled:YES];
            }
        }
        
        if (self.isPrePlay) {
            [parentVC.checkHomeworkButton setTitle:@"继续" forState:UIControlStateNormal];
            [parentVC stopTimer];
            [parentVC.reduceTimeButton setEnabled:NO];
        }else{
            
        }
    }
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.exitButtonHasBeenClicked = NO;
    self.currentSentencePassed = NO;
    self.shouldUpload = NO;
    // 创建识别对象
    //初始化语音识别控件
    NSString *initString = [NSString stringWithFormat:@"appid=%@",APPID];
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center initParam:initString];
    _iflyRecognizerView.delegate = self;
    
    [_iflyRecognizerView setParameter:@"domain" value:@"iat"];
    [_iflyRecognizerView setParameter:@"asr_audio_path" value:@"asrview.pcm"];
    [_iflyRecognizerView setParameter:@"language" value:@"en_us"];
    [_iflyRecognizerView setParameter:@"asr_ptt" value:@"0"];
    [_iflyRecognizerView setParameter:@"asr_audio_path" value:nil];
    [_iflyRecognizerView setParameter:@"vad_eos" value:@"800"];
    [_iflyRecognizerView setParameter:@"vad_bos" value:@"1500"];
    //KVO,为播放按钮切换图片
    [self.readingButton addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    
    if ([DataService sharedService].isHistory) {
        self.view.hidden = YES;
    }else{
        self.preReadingController = [[PreReadingTaskViewController alloc] initWithNibName:@"PreReadingTaskViewController" bundle:nil];
        [self appearPrePlayControllerWithAnimation:YES];
        [self loadHomeworkFromFile];
        [self updateFirstSentence];
        self.propsArray = [Utility returnAnswerPropsandDate:[DataService sharedService].taskObj.taskStartDate];
        [self.preReadingController startPreListeningHomeworkSentence:self.currentHomework withPlayFinished:^(BOOL isSuccess) {
            
        }];
    }

    [self.listeningButton setImage:[UIImage imageNamed:@"listening_stop.png"] forState:UIControlStateNormal];
    [self.listeningButton setImage:[UIImage imageNamed:@"listening_start.png"] forState:UIControlStateDisabled];
    
    self.isReading = NO;
    self.isListening = NO;
}

- (void)dealloc{
    [self.readingButton removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

#pragma mark exchange homework切换题目
///
-(void)setCurrentSentence:(ReadingSentenceObj *)currentSentence withAnimation:(BOOL)ani{
    if (!currentSentence) {
        return;
    }
    self.currentSentence = currentSentence;//GO
    if (ani) {
        if (!(self.currentSentenceIndex == 0 && self.currentHomeworkIndex == 0)) {
            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromRight];
            [animation setDuration:0.5];
            [animation setRemovedOnCompletion:YES];
            [animation setDelegate:self];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [self.view.layer addAnimation:animation forKey:@"PushLeft"];
        }
    }
    //设置"完成"按钮
    if (self.currentSentenceIndex +1 == self.currentHomework.readingHomeworkSentenceObjArray.count && self.currentHomeworkIndex +1 == self.readingHomeworksArr.count) {
        [parentVC.checkHomeworkButton setTitle:@"完成" forState:UIControlStateNormal];
    }
}

///切换到指定句
-(void)updateFirstSentence{
    if (!self.currentHomework) {
        [self updateFirstHomework];
    }
    [self setCurrentSentence:[self.currentHomework.readingHomeworkSentenceObjArray objectAtIndex:self.currentSentenceIndex] withAnimation:YES];
    if (self.currentSentence) {
        
    }else{//当前大题中没有句子
        
    }
}

//TODO:减时间道具
-(void)reduceTimeProBtClicked{
    int timeCount = [DataService sharedService].number_reduceTime;
    if (timeCount <= 1) {
        [parentVC.reduceTimeButton setEnabled:NO];
    }
    [DataService sharedService].number_reduceTime--;
    parentVC.spendSecond = parentVC.spendSecond > 5 ? parentVC.spendSecond - 5 : 0;
    
    //显示 "-5" 动画效果
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){self.view.frame.size.width/2,120,70,50}];
    [label setFont:[UIFont systemFontOfSize:50]];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor orangeColor];
    label.text = @"-5";
    [parentVC.view addSubview:label];
    [parentVC.view setUserInteractionEnabled:NO];
    label.alpha = 1;
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        [parentVC.view setUserInteractionEnabled:YES];
    }];
    
    //存储道具记录JSON
    if (self.propsArray.count > 0) {
        NSMutableDictionary *timePropDic = [NSMutableDictionary dictionaryWithDictionary:[self.propsArray firstObject]];
        NSMutableArray *branchOfPropArray = [NSMutableArray arrayWithArray:[timePropDic objectForKey:@"branch_id"]];
        [branchOfPropArray addObject:[NSNumber numberWithInteger:self.currentSentence.readingSentenceID.integerValue]];
        [timePropDic setObject:branchOfPropArray forKey:@"branch_id"];
        [self.propsArray replaceObjectAtIndex:0 withObject:timePropDic];
        [Utility returnAnswerPathWithProps:self.propsArray andDate:[DataService sharedService].taskObj.taskStartDate];
    }
}

//TODO:退出作业界面
-(void)exithomeworkUI{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"作业提示" message:@"确定退出做题?" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"取消", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

-(void)quitNow{
    [self.preReadingController.avPlayer stop];
    [self.avPlayer stop];
    if (![DataService sharedService].isHistory && self.isFirst && self.shouldUpload) {
        //第一次做题且需上传
        __weak ReadingTaskViewController *weakSelf = self;
        TaskObj *task = [DataService sharedService].taskObj;
        NSString *path = [NSString stringWithFormat:@"%@/%@/answer_%@.json",[Utility returnPath],task.taskStartDate,[DataService sharedService].user.userId?:@""];
        
        
        //先保存一次JSON
        NSIndexPath *indexPath = [self findNextIndexWithHomeworkIndex:self.currentHomeworkIndex andSentenceIndex:self.currentSentenceIndex];
            //如果没有读过,保存本题index ,如果读过了 ,保存下一题index
        [ParseAnswerJsonFileTool writeReadingHomeworkToJsonFile:path
                                                    withUseTime:[NSString stringWithFormat:@"%llu",parentVC.spendSecond]
                                              withQuestionIndex:self.readingCount > 0 ? indexPath.section : self.currentHomeworkIndex
                                          withQuestionItemIndex:self.readingCount > 0 ? indexPath.row : self.currentSentenceIndex
                                          withReadingHomworkArr:self.readingHomeworksArr withSuccess:^{
            ReadingTaskViewController *tempSelf = weakSelf ;
            if (tempSelf) {
                //成功后上传
                [tempSelf uploadJSON];
            }
        } withFailure:^(NSError *error) {
            ReadingTaskViewController *tempSelf = weakSelf ;
            if (tempSelf) {
                [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
            }
        }];
        
        
    }else{
        [parentVC dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

//TODO:开始做题(点击"下一个"时也触发)
-(void)startBeginninghomework{
    if ([DataService sharedService].isHistory==YES) {
        [self updateNextSentence];
    }else{
        if (self.isPrePlay) {
            [self hiddlePrePlayControllerWithAnimation:YES];
        }else{
            //切换到下一题
            if (self.currentSentencePassed || self.readingCount >= minRecoginCount) {
                
                self.readingCount = 0;
                self.currentSentencePassed = NO;
                [self.tipBackView setHidden:YES];
                if (self.currentSentenceIndex+1 < self.currentHomework.readingHomeworkSentenceObjArray.count) {
                    [parentVC startTimer];
                    [ self updateNextSentence];
                }else{//已经是最后一个句子
                    if (self.currentHomeworkIndex+1 < self.readingHomeworksArr.count) {
                        [self updateNextHomework];
                        [self.preReadingController startPreListeningHomeworkSentence:self.currentHomework withPlayFinished:^(BOOL isSuccess) {
                            
                        }];
                        [self appearPrePlayControllerWithAnimation:YES];
                    }else{
                        //且是最后一个大题
                        [parentVC stopTimer];
                        if (self.isFirst && ![DataService sharedService].isHistory) {
                            [self uploadJSON];
                        }else{ //为重新做题
                            [self showResultView];
                        }
                    }
                }
            }else{
                MBProgressHUD *alert = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                alert.labelText = @"读不够好哦，再试一次吧";
                [alert hide:YES afterDelay:1];
            }
        }
    }
}

///切换到下一句
-(void)updateNextSentence{
    if (self.currentSentence) {
        if (self.currentSentenceIndex+1 < self.currentHomework.readingHomeworkSentenceObjArray.count) {
            self.currentSentenceIndex++;
            self.currentSentence.isFinished = YES;
            [self setCurrentSentence:[self.currentHomework.readingHomeworkSentenceObjArray objectAtIndex:self.currentSentenceIndex] withAnimation:YES];
        }else{//已经是最后一个句子
            if (self.currentHomeworkIndex+1 < self.readingHomeworksArr.count) {
                [self updateNextHomework];
                [self.preReadingController startPreListeningHomeworkSentence:self.currentHomework withPlayFinished:^(BOOL isSuccess) {
                }];
                [self appearPrePlayControllerWithAnimation:YES];
            }else{
                //TODO:已是最后一大题最后一小题
                [self quitNow];
            }
        }
    }else{//当前大题中没有句子
        [self updateFirstSentence];
    }
    
}

///计算下一题的homeworkIndex和sentenceIndex(section代表home,row代表sentence ,如都为-2代表已完成)
- (NSIndexPath *)findNextIndexWithHomeworkIndex:(NSInteger )homeIndex andSentenceIndex:(NSInteger)sentenceIndex{
    if (sentenceIndex + 1 < self.currentHomework.readingHomeworkSentenceObjArray.count) {
        //有下一小题
        return [NSIndexPath indexPathForRow:sentenceIndex + 1 inSection:homeIndex];
    }else{
        if (homeIndex + 1 < self.readingHomeworksArr.count) {
            ReadingHomeworkObj *nextHomework = self.readingHomeworksArr[homeIndex + 1];
            if (nextHomework.readingHomeworkSentenceObjArray.count >= 1) {
                //有下一大题且有小题
                return [NSIndexPath indexPathForRow:0 inSection:homeIndex + 1];
            }else{
                //有下一大题但无小题?
                return [NSIndexPath indexPathForRow:-2 inSection:-2];
            }
        }else{
            //无下一大题
            return [NSIndexPath indexPathForRow:-2 inSection:-2];
        }
    }
}

///读取当前指定大题
-(void)updateFirstHomework{
    //读取题目
    if (!self.readingHomeworksArr || self.readingHomeworksArr.count <= 0) {
        if (![DataService sharedService].isHistory) {
            [self loadHomeworkFromFile];
        }
    }
    if (self.readingHomeworksArr && self.readingHomeworksArr.count > 0) {
        self.currentHomework = [self.readingHomeworksArr objectAtIndex:self.currentHomeworkIndex];
    }else{//json文件中没有朗读的题目
        
    }
}

///切换到下一题
-(void)updateNextHomework{
    if (!self.currentHomework) {
        [self updateFirstHomework];
    }
    if (self.currentHomework) {
        if (self.currentHomeworkIndex+1 < self.readingHomeworksArr.count) {
            self.currentHomeworkIndex++;
            self.currentHomework.isFinished = YES;
            self.currentHomework = [self.readingHomeworksArr objectAtIndex:self.currentHomeworkIndex];
        }else{//已经是最后一个大题
        
        }
    }else{//json文件中没有朗读的题目
    
    }
}

//TODO:从json文件中加载题目数据(非历史)
-(void)loadHomeworkFromFile{
    TaskObj *task = [DataService sharedService].taskObj;
    __weak ReadingTaskViewController *weakSelf = self;
    [ParseAnswerJsonFileTool parseAnswerJsonFileWithUserId:[DataService sharedService].user.userId withTask:task withReadingHistoryArray:^(NSArray *readingQuestionArr, int currentQuestionIndex, int currentQuestionItemIndex, int status, NSString *updateTime, NSString *userTime, int specifyTime,float ratio){
        ReadingTaskViewController *tempSelf = weakSelf;
        if (tempSelf) {
            HomeworkContainerController *container = (HomeworkContainerController*)[tempSelf parentViewController];
            tempSelf.readingHomeworksArr = readingQuestionArr;
            tempSelf.specifiedSecond = specifyTime;
            if (status > 0 || [DataService sharedService].taskObj.isExpire) {
                //重新开始
                tempSelf.isFirst = NO;
                tempSelf.currentHomeworkIndex = 0;
                tempSelf.currentSentenceIndex = 0;
                container.spendSecond = 0;
            }else{
                //第一次(继续做题)
                tempSelf.isFirst = YES;
                tempSelf.currentHomeworkIndex = currentQuestionIndex < 0 ?0:currentQuestionIndex;
                tempSelf.currentSentenceIndex = currentQuestionItemIndex < 0 ?0:currentQuestionItemIndex;
                container.spendSecond = userTime ? userTime.intValue : 0;
            }
        }
    } withParseError:^(NSError *error) {
        [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
        //重新开始
        self.isFirst = NO;
        self.currentHomeworkIndex = 0;
        self.currentSentenceIndex = 0;
        parentVC.spendSecond = 0;
    }];
}

//TODO:上传JSON文件
- (void)uploadJSON{
    TaskObj *task = [DataService sharedService].taskObj;
    NSString *path = [NSString stringWithFormat:@"%@/%@/answer_%@.json",[Utility returnPath],task.taskStartDate,[DataService sharedService].user.userId?:@""];
    [parentVC  uploadAnswerJsonFileWithPath:path withSuccess:^(NSString *success) {
        [Utility returnAnswerPAthWithString:success];
        //退出或显示成绩界面
        if (self.currentHomeworkIndex + 1 >= self.readingHomeworksArr.count && self.currentSentenceIndex + 1 >= self.currentHomework.readingHomeworkSentenceObjArray.count && ![DataService sharedService].isHistory && !self.exitButtonHasBeenClicked) {
            [self showResultView];
        }else{
            [parentVC dismissViewControllerAnimated:YES completion:nil];
        }
    } withFailure:^(NSString *error) {
        [Utility errorAlert:error];
        [Utility uploadFaild];
        //退出或显示成绩界面
        if (self.currentHomeworkIndex + 1 >= self.readingHomeworksArr.count && self.currentSentenceIndex + 1 >= self.currentHomework.readingHomeworkSentenceObjArray.count && ![DataService sharedService].isHistory && !self.exitButtonHasBeenClicked) {
            [self showResultView];
        }else{
            [parentVC dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
#pragma mark --

#pragma mark 开始预听界面切换
-(void)appearPrePlayControllerWithAnimation:(BOOL)animation{
    [self.preReadingController willMoveToParentViewController:self];
    self.preReadingController.view.frame = self.view.bounds;
    [self.view addSubview:self.preReadingController.view];
    [self addChildViewController:self.preReadingController];
    [self.preReadingController didMoveToParentViewController:self];
    [parentVC.checkHomeworkButton setTitle:@"继续" forState:UIControlStateNormal];
    self.isPrePlay = YES;
    [parentVC stopTimer];
    [parentVC.reduceTimeButton setEnabled:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        parentVC.djView.hidden = YES;
        parentVC.view.backgroundColor = [UIColor whiteColor];
    });
    
    [self.tipBackView setHidden:YES];
    if (animation) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:0.5];
        [animation setRemovedOnCompletion:YES];
        [animation setDelegate:self];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:animation forKey:@"PushLeft"];
        [parentVC.djView.layer addAnimation:animation forKey:@"PushLeft"];
    }
}

-(void)hiddlePrePlayControllerWithAnimation:(BOOL)animation{
    self.preReadingController.shouldInterrupt = YES;
    [self.preReadingController willMoveToParentViewController:nil];
    [self.preReadingController.view removeFromSuperview];
    [self.preReadingController removeFromParentViewController];
    [self.preReadingController didMoveToParentViewController:nil];
    [self.preReadingController.avPlayer stop];
    [parentVC.checkHomeworkButton setTitle:@"下一题" forState:UIControlStateNormal];
    parentVC.djView.hidden = NO;
    self.isPrePlay = NO;
    
    [parentVC startTimer];
    if ([DataService sharedService].number_reduceTime > 0) {
        if (self.isFirst) {
            [parentVC.reduceTimeButton setEnabled:YES];
        }
    }
    
    if (animation) {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:0.5];
        [animation setRemovedOnCompletion:YES];
        [animation setDelegate:self];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:animation forKey:@"PushLeft"];
        [parentVC.djView.layer addAnimation:animation forKey:@"PushLeft"];
    }
}

#pragma mark --

#pragma mark 界面过度动画代理
-(void)animationDidStart:(CAAnimation *)anim{
    [self.view setUserInteractionEnabled:NO];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.view setUserInteractionEnabled:YES];
}
#pragma mark --


//TODO:显示通关界面
-(void)showResultView {
    TaskObj *task = [DataService sharedService].taskObj;
    for (HomeworkTypeObj *type in task.taskHomeworkTypeArray) {
        if (type.homeworkType == parentVC.homeworkType) {
            type.homeworkTypeIsFinished = YES;
        }
    }
    int count = 0;
    float radio = 0.0 ;
    for (ReadingHomeworkObj *homework in self.readingHomeworksArr) {
        for (ReadingSentenceObj *sentence in homework.readingHomeworkSentenceObjArray) {
            count++;
            radio += sentence.readingSentenceRatio.floatValue;
        }
    }
    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"TenSecChallengeResultView" owner:self options:nil];
    self.resultView = (TenSecChallengeResultView *)[viewArray objectAtIndex:0];
    self.resultView.delegate = self;
    self.resultView.timeCount = parentVC.spendSecond;
    self.resultView.ratio = radio/count*100;
    if (self.isFirst == YES) {
        self.resultView.resultBgView.hidden=NO;
        self.resultView.noneArchiveView.hidden=YES;
        
        self.resultView.timeLimit = self.specifiedSecond;
        self.resultView.isEarly = [Utility compareTime];
    }else {
        self.resultView.noneArchiveView.hidden=NO;
        self.resultView.resultBgView.hidden=YES;
    }
    
    [self.resultView initView];
    
    [self.view addSubview: self.resultView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//TODO:开始识别语音
/*
 * @开始录音
*/
- (IBAction)readingButtonClicked:(id)sender {
    //启动计时
    if (![DataService sharedService].isHistory) {
        [parentVC startTimer];
    }
    
    [_iflyRecognizerView start];;
    
    self.isReading = YES;
    [self.readingButton setUserInteractionEnabled:NO];
    [self.listeningButton setUserInteractionEnabled:NO];
}


//TODO:开始播放音频，如果没有就tts
- (IBAction)listeningButtonClicked:(id)sender {
    if (self.isListening) {
        if (self.avPlayer.isPlaying) {
            [self.avPlayer stop];
        }
    }else{
        if (self.currentSentence.readingSentenceLocalFileURL) {
            if (self.avPlayer.isPlaying) {
                [self.avPlayer stop];
            }
            NSError *playerError = nil;
            self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.currentSentence.readingSentenceLocalFileURL] error:&playerError];
            self.avPlayer.delegate = self;
            if (!playerError && [self.avPlayer prepareToPlay]) {
                [self.avPlayer play];
                self.isListening = YES;
                [self.readingButton setUserInteractionEnabled:NO];
            }else{
                self.isListening = NO;
                [self.readingButton setUserInteractionEnabled:YES];
            }
        }else{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [GoogleTTSAPI checkGoogleTTSAPIAvailabilityWithCompletionBlock:^(BOOL available) {
                if (available) {
                    [GoogleTTSAPI textToSpeechWithText:self.readingTextView.text andLanguage:@"en" success:^(NSData *data) {
                        NSURL *audioFileURL = [self fileURLWithFileName:@"converted.mp3"];
                        [data writeToURL:audioFileURL atomically:NO];
                        if (self.avPlayer.isPlaying) {
                            [self.avPlayer stop];
                        }
                        NSError *error = nil;
                        self.avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
                        self.avPlayer.delegate = self;
                        if (error) {
                            [Utility errorAlert:@"播放文件不存在或者格式错误"];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            return;
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([self.avPlayer prepareToPlay]) {
                                [self.avPlayer play];
                                self.isListening = YES;
                                [self.readingButton setUserInteractionEnabled:NO];
                            }else{
                                self.isListening = NO;
                                [self.readingButton setUserInteractionEnabled:YES];
                            }
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                        });
                    } failure:^(NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.isListening = NO;
                            [self.readingButton setUserInteractionEnabled:YES];
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [Utility errorAlert:[NSString stringWithFormat:@"%@",[error localizedDescription]]];
                        });
                    }];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isListening = NO;
                        [self.readingButton setUserInteractionEnabled:YES];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [Utility errorAlert:@"当前无网络"];
                    });
                }
            }];
        }
    }
}


- (NSURL*) fileURLWithFileName: (NSString*) fileName {
    NSURL *documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentDirectory URLByAppendingPathComponent:fileName];
}
//TODO:更新所有的位置
-(void)updateAllFrame{
    //更新上方句子
    NSAttributedString *attributeString = self.readingTextView.attributedText;
    CGRect textRect = [attributeString boundingRectWithSize:(CGSize){CGRectGetWidth(self.readingTextView.frame),self.view.frame.size.height - 350} options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading context:nil];
    self.readingTextView.frame = (CGRect){self.readingTextView.frame.origin,CGRectGetWidth(self.readingTextView.frame),textRect.size.height + 10};
    
    //更新按钮
    self.readingButton.frame = (CGRect){CGRectGetMinX(self.readingButton.frame),CGRectGetMaxY(self.readingTextView.frame)+20,self.readingButton.frame.size};
    
    //更新tip的位置和大小
    NSAttributedString *attributeTip = self.tipTextView.attributedText;
    float maxTipHeight = (self.view.frame.size.height - CGRectGetMaxY(self.readingTextView.frame) - 30);
    CGRect tipRect = [attributeTip boundingRectWithSize:(CGSize){CGRectGetWidth(self.tipTextView.frame) - 5, maxTipHeight < 80 ? 80 : maxTipHeight} options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading context:nil];
    self.tipBackView.frame = (CGRect){CGRectGetMinX(self.tipBackView.frame),CGRectGetMaxY(self.readingButton.frame) + 30,self.tipBackView.frame.size.width,tipRect.size.height + 60};
}

///标记颜色
-(void)markErrorColorRangeForArr:(NSArray*)rangeArray{

}

#pragma mark --

#pragma mark TenSecChallengeResultViewDelegate显示结果代理
-(void)resultViewCommitButtonClicked {//确认完成
    [self.resultView removeFromSuperview];
    [parentVC dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)resultViewRestartButtonClicked {//再次挑战
    [self.resultView removeFromSuperview];
    
    parentVC.checkHomeworkButton.enabled=YES;
    parentVC.spendSecond = 0;
    self.currentHomework = nil;
    self.currentSentence = nil;
    self.currentSentenceIndex = 0;
    self.currentHomeworkIndex = 0;
    self.readingHomeworksArr = nil;
    [self updateFirstSentence];
    self.isFirst = NO;
    [self appearPrePlayControllerWithAnimation:YES];
    [self.preReadingController startPreListeningHomeworkSentence:self.currentHomework withPlayFinished:^(BOOL isSuccess) {
        
    }];
}
#pragma mark --

#pragma mark AVAudioPlayerDelegate 播放代理
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.isListening = NO;
    [self.readingButton setUserInteractionEnabled:YES];
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{}
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{}
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{}
#pragma mark --

#pragma mark property
///添加题号显示label
- (UILabel *)currentNOLabel{
    if (!_currentNOLabel) {
        _currentNOLabel = [[UILabel alloc] initWithFrame:(CGRect){660,20,100,30}];
        _currentNOLabel.font = [UIFont systemFontOfSize:26.0];
        _currentNOLabel.textAlignment = NSTextAlignmentLeft;
        _currentNOLabel.textColor = [UIColor colorWithRed:39./255. green:48./255. blue:57./255. alpha:1.0];
        [parentVC.djView addSubview:_currentNOLabel];
    }
    return _currentNOLabel;
}

////改变题号时,更改题号label显示数字
//- (void)setCurrentSentenceIndex:(int)currentSentenceIndex{
//    _currentSentenceIndex = currentSentenceIndex;
//    
//}

-(void)setIsPrePlay:(BOOL)isPrePlay{
    _isPrePlay = isPrePlay;
    if (isPrePlay) {
        [parentVC.reduceTimeButton setEnabled:NO];
    }else{
        int timeCount = [DataService sharedService].number_reduceTime;
        if (timeCount <= 0) {
            [parentVC.reduceTimeButton setEnabled:NO];
        }else{
            if (self.isFirst) {
                [parentVC.reduceTimeButton setEnabled:YES];
            }
        }
    }
}

-(void)setIsReading:(BOOL)isReading{
    _isReading = isReading;
    if (!isReading) {
        [self.readingButton setImage:[UIImage imageNamed:@"reading_stop.png"] forState:UIControlStateNormal];
        
    }else{
        [self.readingButton setImage:[UIImage imageNamed:@"reading_start.png"] forState:UIControlStateNormal];
    }
}
-(void)setIsListening:(BOOL)isListening{
    _isListening = isListening;
    [self.listeningButton setEnabled:!isListening];
}

//TODO:载入新句子
-(void)setCurrentSentence:(ReadingSentenceObj *)currentSentence{
    _currentSentence = currentSentence;
    if (currentSentence) {
        //显示历史记录
        if ([DataService sharedService].isHistory) {
            NSMutableString *content = [NSMutableString stringWithFormat:@"需要多读的词"];
            if (currentSentence.readingErrorWordArray.count < 1 && [DataService sharedService].taskObj.isExpire) {
                [content appendString:@"\n"];
                [content appendString:@"未完成本小题"];
            }
            for (NSString *errorWord in currentSentence.readingErrorWordArray) {
                [content appendString:@"\n"];
                [content appendString:errorWord];
            }
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:content];
            [attriString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(0, content.length)];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.alignment = NSTextAlignmentCenter;
            [attriString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, content.length)];
            self.tipTextView.attributedText = attriString;
        }else{
            self.rightWordArray = [NSMutableArray array];
        }
        
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:currentSentence.readingSentenceContent];
        [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:35] range:NSMakeRange(0, attri.length)];
        [attri addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, attri.length)];
        self.readingTextView.attributedText = attri;
         [self updateAllFrame];
        if (self.currentHomeworkIndex >= self.readingHomeworksArr.count && self.currentSentenceIndex >= ((ReadingHomeworkObj *)[self.readingHomeworksArr lastObject]).readingHomeworkSentenceObjArray.count) {
            [parentVC.checkHomeworkButton setTitle:@"完成" forState:UIControlStateNormal];
        }
        
        //显示题号Label
        if (self.currentSentenceIndex < self.currentHomework.readingHomeworkSentenceObjArray.count) {
            self.currentNOLabel.text = [NSString stringWithFormat:@"%d/%d",self.currentSentenceIndex + 1,self.currentHomework.readingHomeworkSentenceObjArray.count];
        }
    }
}

#pragma mark -- UIAlert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *choice = [alertView buttonTitleAtIndex:buttonIndex];
    if ([choice isEqualToString:@"退出"]) {
        self.exitButtonHasBeenClicked = YES;
        [self quitNow];
    }else if ([choice isEqualToString:@"取消"]){
        
    }
}

#pragma mark --
#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        if (self.readingButton.userInteractionEnabled == YES) {
            [self.readingButton setImage:[UIImage imageNamed:@"reading_stop.png"] forState:UIControlStateNormal];
        }else{
//            [self.readingButton setImage:[UIImage imageNamed:@"reading_start.png"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark --
#pragma mark - IFlySpeechRecognizerDelegate

- (void)onResult:(IFlyRecognizerView *)iFlyRecognizerView theResult:(NSArray *)resultArray{
    [parentVC stopTimer];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    [_iflyRecognizerView cancel];
    
    [self.readingButton setUserInteractionEnabled:YES];
    [self.listeningButton setUserInteractionEnabled:YES];
    
    TaskObj *task = [DataService sharedService].taskObj;
    NSString *path = [NSString stringWithFormat:@"%@/%@/answer_%@.json",[Utility returnPath],task.taskStartDate,[DataService sharedService].user.userId?:@""];
    
    [DRSentenceSpellMatch checkSentence:self.currentSentence.readingSentenceContent
                 withSpellMatchSentence:result
           andSpellMatchAttributeString:^(NSMutableAttributedString *spellAttriString,float matchScore,NSArray *errorWordArray,NSArray *rightWordArray){
        self.readingCount++;
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        //记录读对的词
        for(NSString *rightWord in rightWordArray){
            if (![self.rightWordArray containsObject:rightWord]) {
                [self.rightWordArray addObject:rightWord];
            }
        }
        
        NSMutableAttributedString *spellAttriStringFinally = [[NSMutableAttributedString alloc] initWithAttributedString:spellAttriString];
        for(NSString *rightWord in self.rightWordArray){
            NSRange greenRange = [spellAttriStringFinally.string rangeOfString:rightWord];
            if (greenRange.length > 0) {
                [spellAttriStringFinally addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:53/255.0 green:207/255.0 blue:143/255.0 alpha:1] range:greenRange];
            }
        }
        self.readingTextView.attributedText = nil;
        self.readingTextView.attributedText = spellAttriStringFinally;
        [self.tipBackView setHidden:NO];
        NSString *tip = @"";
        float score = self.rightWordArray.count / (float)[Utility shared].orgArray.count;
        NSLog(@"正确次数:%d ,总次数: %d",self.rightWordArray.count,[Utility shared].orgArray.count);
        if (score >= minRecoginLevel) {
            tip = @"你的发音真的很不错哦,让我们再来读读其它的句子吧！";
            self.currentSentencePassed = YES;
        }else
        {
            tip = @"看到橘黄色的这些词了吗,发音还不够标准哦,再来试试吧！";
        }
        if (self.readingCount <= 1) {//计入成绩
            //存内存中
            self.currentSentence.readingErrorWordArray = [NSMutableArray arrayWithArray:errorWordArray];
            self.currentSentence.readingSentenceRatio = [NSString stringWithFormat:@"%0.2f",score];
            //标志本大题完成
            if (self.currentSentenceIndex == self.currentHomework.readingHomeworkSentenceObjArray.count-1) {
                self.currentHomework.isFinished = YES;
            }
            if (self.isFirst) {
                //保存JSON
                __weak ReadingTaskViewController *weakSelf = self;
                self.currentSentence.isFinished = YES;
                
                NSIndexPath *indexPath = [self findNextIndexWithHomeworkIndex:self.currentHomeworkIndex andSentenceIndex:self.currentSentenceIndex];
                //TODO:此处已经完成本小题,保存的是下一题的对应index
                [ParseAnswerJsonFileTool writeReadingHomeworkToJsonFile:path
                                                            withUseTime:[NSString stringWithFormat:@"%llu",parentVC.spendSecond]
                                                      withQuestionIndex:indexPath.section
                                                  withQuestionItemIndex:indexPath.row
                                                  withReadingHomworkArr:self.readingHomeworksArr
                                                            withSuccess:^{
                                                                ReadingTaskViewController *tempSelf = weakSelf ;
                                                                if (tempSelf) {
                                                                    self.shouldUpload = YES;
                                                                }
                                                            } withFailure:^(NSError *error) {
                                                                ReadingTaskViewController *tempSelf = weakSelf ;
                                                                if (tempSelf) {
                                                                    [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
                                                                }
                                                            }];
            }
        }
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:tip];
        [attriString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:NSMakeRange(0,tip.length)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        [attriString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0,tip.length)];
        self.tipTextView.attributedText = attriString;
        [self updateAllFrame];
    } orSpellMatchFailure:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
    }];
}
- (void)onEnd:(IFlyRecognizerView *)iFlyRecognizerView theError:(IFlySpeechError *)error
{
    [self.readingButton setUserInteractionEnabled:YES];
}
@end
