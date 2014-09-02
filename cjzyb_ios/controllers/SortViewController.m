//
//  SortViewController.m
//  cjzyb_ios
//
//  Created by comdosoft on 14-3-13.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "SortViewController.h"

static BOOL isCanUpLoad = NO;

@interface SortViewController ()
@property (nonatomic, strong) TenSecChallengeResultView *resultView;
@end


#define Textfield_Width  180
#define Textfield_Height  60
#define Textfield_Space_Width 57
#define Textfield_Space_Height 20
#define CP_Answer_Button_Tag_Offset 1000
#define CP_Word_Button_Tag_Offset 10000

@implementation SortViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(UILabel *)returnPointLabel {
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:18];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    return label;
}
-(UIButton *)returnButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor whiteColor];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:8];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:33];
    [btn setExclusiveTouch :YES];
    return btn;
}
-(void)setUI {
    [self.checkHomeworkButton setTitle:@"检查" forState:UIControlStateNormal];
    [self.checkHomeworkButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.checkHomeworkButton addTarget:self action:@selector(checkAnswer:) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentWordIndex = 0;self.maps = nil;self.preBtn= nil;self.restartBtn=nil;self.actionArray=nil;self.isRestart=NO;
    
    [self.wordsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.wordsContainerView removeFromSuperview];
    self.wordsContainerView = [[UIView alloc]init];
    self.wordsContainerView.tag = 873663;
    self.wordsContainerView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = CGRectMake(0, 0, Textfield_Width, Textfield_Height);
    CGRect point_frame = CGRectMake(0, 0, 20, 20);
    NSString *content = [self.branchQuestionDic objectForKey:@"content"];

    [Utility shared].isOrg = NO;
    [Utility shared].rangeArray = [[NSMutableArray alloc]init];
    self.orgArray = [Utility handleTheString:content];
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.orgArray];
    NSInteger count = tmpArray.count;
    
    int num1 = self.orgArray.count/3;//除以3的整数
    int num2 = self.orgArray.count%3;//除以3的余数
    //
    for (int i=0; i<num1; i++) {
        for (int k=0; k<3; k++) {
            UIButton *btn3 = [self returnButton];
            btn3.tag = 3*i+CP_Answer_Button_Tag_Offset+k;
            frame.origin.x = Textfield_Space_Width+(Textfield_Width+Textfield_Space_Width)*k;
            frame.origin.y = (Textfield_Height+Textfield_Space_Height)*i;
            btn3.frame = frame;
            [btn3 setTitleColor:[UIColor colorWithRed:0/255.0 green:5/255.0 blue:28/255.0 alpha:1] forState:UIControlStateNormal];
            
            [btn3 addTarget:self action:@selector(answerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
            btn3.enabled = NO;
            [self.wordsContainerView addSubview:btn3];
            
            NSTextCheckingResult *math = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag-CP_Answer_Button_Tag_Offset];
            NSRange range = [math rangeAtIndex:0];
            if (btn3.tag-CP_Answer_Button_Tag_Offset==0 && range.location != 0) {//第一位出现标点的情况
                NSString *str = [content substringWithRange:NSMakeRange(0, range.location)];
                UILabel *label = [self returnPointLabel];
                point_frame.origin.x = 0;
                point_frame.origin.y = frame.origin.y+frame.size.height-20;
                label.frame = point_frame;
                label.text = str;
                [self.wordsContainerView addSubview:label];
            }else if (btn3.tag-CP_Answer_Button_Tag_Offset<self.orgArray.count-1) {
                NSTextCheckingResult *math2 = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag+1-CP_Answer_Button_Tag_Offset];
                NSRange range2 = [math2 rangeAtIndex:0];
                
                NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, range2.location-range.location-range.length)];
                str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
                if (str.length>0) {
                    UILabel *label = [self returnPointLabel];
                    point_frame.origin.x = frame.origin.x+frame.size.width+10;
                    point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                    label.frame = point_frame;
                    label.text = str;
                    [self.wordsContainerView addSubview:label];
                }
            }else {
                int number = content.length - range.location - range.length;
                if (number>0) {
                    NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, number)];
                    str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
                    if (str.length>0) {
                        UILabel *label = [self returnPointLabel];
                        point_frame.origin.x = frame.origin.x+frame.size.width+10;
                        point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                        label.frame = point_frame;
                        label.text = str;
                        [self.wordsContainerView addSubview:label];
                    }
                }
            }
            
        }
    }
    
    frame.origin.y += Textfield_Height+Textfield_Space_Height;
    for (int i=0; i<num2; i++) {
        UIButton *btn3 = [self returnButton];
        btn3.tag = 3*num1+CP_Answer_Button_Tag_Offset+i;
        CGFloat space = (768-Textfield_Width*num2)/(num2+1);
        frame.origin.x = space + (Textfield_Width+space)*i;
        btn3.frame = frame;
        [btn3 setTitleColor:[UIColor colorWithRed:0/255.0 green:5/255.0 blue:28/255.0 alpha:1] forState:UIControlStateNormal];
        
        [btn3 addTarget:self action:@selector(answerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        btn3.enabled = NO;
        [self.wordsContainerView addSubview:btn3];
        
        NSTextCheckingResult *math = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag-CP_Answer_Button_Tag_Offset];
        NSRange range = [math rangeAtIndex:0];
        if (btn3.tag-CP_Answer_Button_Tag_Offset==0 && range.location != 0) {//第一位出现标点的情况
            NSString *str = [content substringWithRange:NSMakeRange(0, range.location)];
            UILabel *label = [self returnPointLabel];
            point_frame.origin.x = 0;
            point_frame.origin.y = frame.origin.y+frame.size.height-20;
            label.frame = point_frame;
            label.text = str;
            [self.wordsContainerView addSubview:label];
        }else if (btn3.tag-CP_Answer_Button_Tag_Offset<self.orgArray.count-1) {
            NSTextCheckingResult *math2 = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag+1-CP_Answer_Button_Tag_Offset];
            NSRange range2 = [math2 rangeAtIndex:0];
            
            NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, range2.location-range.location-range.length)];
            str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
            if (str.length>0) {
                UILabel *label = [self returnPointLabel];
                point_frame.origin.x = frame.origin.x+frame.size.width+10;
                point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                label.frame = point_frame;
                label.text = str;
                [self.wordsContainerView addSubview:label];
            }
        }else {
            int number = content.length - range.location - range.length;
            if (number>0) {
                NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, number)];
                str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
                if (str.length>0) {
                    UILabel *label = [self returnPointLabel];
                    point_frame.origin.x = frame.origin.x+frame.size.width+10;
                    point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                    label.frame = point_frame;
                    label.text = str;
                    [self.wordsContainerView addSubview:label];
                }
            }
        }
    }
    
    //TODO:下半部分
    frame.origin.x = 0;
    CGFloat height = frame.origin.y + Textfield_Height+Textfield_Space_Height*5;
    for (int i=0; i<num1; i++) {
        for (int k=0; k<3; k++) {
            UIButton *btn3 = [self returnButton];
            btn3.tag = 3*i+CP_Word_Button_Tag_Offset+k;
            frame.origin.x = Textfield_Space_Width+(Textfield_Width+Textfield_Space_Width)*k;
            frame.origin.y = height+(Textfield_Height+Textfield_Space_Height)*i;
            btn3.frame = frame;
            btn3.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:57/255.0 alpha:1];
            int index = arc4random() % count;
            [btn3 setTitle:[tmpArray objectAtIndex:index] forState:UIControlStateNormal];
            [tmpArray removeObjectAtIndex:index];
            count--;
            
            [btn3 addTarget:self action:@selector(wordButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self.wordsContainerView addSubview:btn3];
        }
    }
    frame.origin.y += Textfield_Height+Textfield_Space_Height;
    for (int i=0; i<num2; i++) {
        UIButton *btn3 = [self returnButton];
        btn3.tag = 3*num1+CP_Word_Button_Tag_Offset+i;
        
        CGFloat space = (768-Textfield_Width*num2)/(num2+1);
        frame.origin.x = space + (Textfield_Width+space)*i;
        btn3.frame = frame;
        btn3.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:57/255.0 alpha:1];
        int index = arc4random() % count;
        [btn3 setTitle:[tmpArray objectAtIndex:index] forState:UIControlStateNormal];
        [tmpArray removeObjectAtIndex:index];
        count--;
        
        [btn3 addTarget:self action:@selector(wordButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.wordsContainerView addSubview:btn3];
    }
    
    self.preBtn.frame = CGRectMake(122, frame.origin.y+Textfield_Height+Textfield_Space_Height*5, 200, 80);
    self.restartBtn.frame = CGRectMake(445, frame.origin.y+Textfield_Height+Textfield_Space_Height*5, 200, 80);
    
    [self.wordsContainerView setFrame:CGRectMake(-768, 0, 768, frame.origin.y+Textfield_Height+Textfield_Space_Height*5+100)];
    [self.myScroll addSubview:self.wordsContainerView];
    self.myScroll.contentSize = CGSizeMake(768,self.wordsContainerView.frame.size.height+30);
    [self.myScroll setScrollEnabled:YES];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.wordsContainerView setFrame:CGRectMake(0, 0, 768, frame.origin.y+Textfield_Height+Textfield_Space_Height*5+100)];
    } completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.25 animations:^{
                NSArray *subViews = [self.wordsContainerView subviews];
                for (UIView *vv in subViews) {
                    if ([vv isKindOfClass:[UIButton class]]) {
                        UIButton *btn = (UIButton *)vv;
                        CGRect frame = btn.frame;
                        frame.size.width = Textfield_Width;
                        frame.size.height = Textfield_Height;
                        btn.frame = frame;
                    }
                }
            } completion:^(BOOL finished){
            }];
        }
    }];
}
-(void)getQuestionData {
    self.branchScore = 0;
    self.questionDic = [self.questionArray objectAtIndex:self.number];
    self.branchQuestionArray = [self.questionDic objectForKey:@"branch_questions"];
    self.branchQuestionDic = [self.branchQuestionArray objectAtIndex:self.branchNumber];
    
    if ([DataService sharedService].isHistory==YES) {
        self.history_questionDic = [self.history_questionArray objectAtIndex:self.number];
        self.history_branchQuestionArray = [self.history_questionDic objectForKey:@"branch_questions"];
        self.history_branchQuestionDic = [self.history_branchQuestionArray objectAtIndex:self.branchNumber];
        
        NSString *txt = [self.history_branchQuestionDic objectForKey:@"answer"];
        self.historyAnswer.text = [NSString stringWithFormat:@"你的排序: %@",txt];
        
        self.homeControl.numberOfQuestionLabel.text = [NSString stringWithFormat:@"%d/%d",self.branchNumber+1,self.history_branchQuestionArray.count];
        [self setHistoryUI];
    }else {
        self.homeControl.numberOfQuestionLabel.text = [NSString stringWithFormat:@"%d/%d",self.branchNumber+1,self.branchQuestionArray.count];
        [self setUI];
    }
    
}
-(void)setHistoryUI {
    if (self.branchNumber==self.history_branchQuestionArray.count-1 && self.number==self.history_questionArray.count-1) {
        [self.checkHomeworkButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.checkHomeworkButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [self.checkHomeworkButton addTarget:self action:@selector(finishHistoryQuestion:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [self.checkHomeworkButton setTitle:@"下一题" forState:UIControlStateNormal];
        [self.checkHomeworkButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [self.checkHomeworkButton addTarget:self action:@selector(nextHistoryQuestion:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.wordsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.wordsContainerView removeFromSuperview];
    self.wordsContainerView = [[UIView alloc]init];
    self.wordsContainerView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = CGRectMake(0, 0, Textfield_Width, Textfield_Height);
    CGRect point_frame = CGRectMake(0, 0, 20, 20);
    NSString *content = [self.branchQuestionDic objectForKey:@"content"];
    
    [Utility shared].isOrg = NO;
    [Utility shared].rangeArray = [[NSMutableArray alloc]init];
    
    self.orgArray = [Utility handleTheString:content];
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.orgArray];
    NSInteger count = tmpArray.count;
    int num1 = self.orgArray.count/3;//除以3的整数
    int num2 = self.orgArray.count%3;//除以3的余数
    //TODO:上半部分
    for (int i=0; i<num1; i++) {
        for (int k=0; k<3; k++) {
            UIButton *btn3 = [self returnButton];
            btn3.tag = 3*i+CP_Answer_Button_Tag_Offset+k;
            frame.origin.x = Textfield_Space_Width+(Textfield_Width+Textfield_Space_Width)*k;
            frame.origin.y = (Textfield_Height+Textfield_Space_Height)*i;
            btn3.frame = frame;
            [btn3 setTitleColor:[UIColor colorWithRed:0/255.0 green:5/255.0 blue:28/255.0 alpha:1] forState:UIControlStateNormal];
            [btn3 setTitle:[tmpArray objectAtIndex:3*i+k] forState:UIControlStateNormal];
            [self.wordsContainerView addSubview:btn3];
            
            NSTextCheckingResult *math = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag-CP_Answer_Button_Tag_Offset];
            NSRange range = [math rangeAtIndex:0];
            if (btn3.tag-CP_Answer_Button_Tag_Offset==0 && range.location != 0) {//第一位出现标点的情况
                NSString *str = [content substringWithRange:NSMakeRange(0, range.location)];
                UILabel *label = [self returnPointLabel];
                point_frame.origin.x = 0;
                point_frame.origin.y = frame.origin.y+frame.size.height-20;
                label.frame = point_frame;
                label.text = str;
                [self.wordsContainerView addSubview:label];
            }else if (btn3.tag-CP_Answer_Button_Tag_Offset<self.orgArray.count-1) {
                NSTextCheckingResult *math2 = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag+1-CP_Answer_Button_Tag_Offset];
                NSRange range2 = [math2 rangeAtIndex:0];
                
                NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, range2.location-range.location-range.length)];
                str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
                if (str.length>0) {
                    UILabel *label = [self returnPointLabel];
                    point_frame.origin.x = frame.origin.x+frame.size.width+10;
                    point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                    label.frame = point_frame;
                    label.text = str;
                    [self.wordsContainerView addSubview:label];
                }
            }else {
                int number = content.length - range.location - range.length;
                if (number>0) {
                    NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, number)];
                    str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
                    if (str.length>0) {
                        UILabel *label = [self returnPointLabel];
                        point_frame.origin.x = frame.origin.x+frame.size.width+10;
                        point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                        label.frame = point_frame;
                        label.text = str;
                        [self.wordsContainerView addSubview:label];
                    }
                }
            }
        }
    }
    frame.origin.y += Textfield_Height+Textfield_Space_Height;
    for (int i=0; i<num2; i++) {
        UIButton *btn3 = [self returnButton];
        btn3.tag = 3*num1+CP_Answer_Button_Tag_Offset+i;
        CGFloat space = (768-Textfield_Width*num2)/(num2+1);
        frame.origin.x = space + (Textfield_Width+space)*i;
        btn3.frame = frame;
        [btn3 setTitleColor:[UIColor colorWithRed:0/255.0 green:5/255.0 blue:28/255.0 alpha:1] forState:UIControlStateNormal];
        [btn3 setTitle:[tmpArray objectAtIndex:3*num1+i] forState:UIControlStateNormal];
        [self.wordsContainerView addSubview:btn3];
        
        NSTextCheckingResult *math = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag-CP_Answer_Button_Tag_Offset];
        NSRange range = [math rangeAtIndex:0];
        if (btn3.tag-CP_Answer_Button_Tag_Offset==0 && range.location != 0) {//第一位出现标点的情况
            NSString *str = [content substringWithRange:NSMakeRange(0, range.location)];
            UILabel *label = [self returnPointLabel];
            point_frame.origin.x = 0;
            point_frame.origin.y = frame.origin.y+frame.size.height-20;
            label.frame = point_frame;
            label.text = str;
            [self.wordsContainerView addSubview:label];
        }else if (btn3.tag-CP_Answer_Button_Tag_Offset<self.orgArray.count-1) {
            NSTextCheckingResult *math2 = (NSTextCheckingResult *)[[Utility shared].rangeArray objectAtIndex:btn3.tag+1-CP_Answer_Button_Tag_Offset];
            NSRange range2 = [math2 rangeAtIndex:0];
            
            NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, range2.location-range.location-range.length)];
            str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
            if (str.length>0) {
                UILabel *label = [self returnPointLabel];
                point_frame.origin.x = frame.origin.x+frame.size.width+10;
                point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                label.frame = point_frame;
                label.text = str;
                [self.wordsContainerView addSubview:label];
            }
        }else {
            int number = content.length - range.location - range.length;
            if (number>0) {
                NSString *str = [content substringWithRange:NSMakeRange(range.location+range.length, number)];
                str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
                if (str.length>0) {
                    UILabel *label = [self returnPointLabel];
                    point_frame.origin.x = frame.origin.x+frame.size.width+10;
                    point_frame.origin.y = frame.origin.y+frame.size.height-20 ;
                    label.frame = point_frame;
                    label.text = str;
                    [self.wordsContainerView addSubview:label];
                }
            }
        }
    }
    
    //TODO:下半部分
    frame.origin.x = 0;
    CGFloat height = frame.origin.y + Textfield_Height+Textfield_Space_Height*5;
    for (int i=0; i<num1; i++) {
        for (int k=0; k<3; k++) {
            UIButton *btn3 = [self returnButton];
            btn3.tag = 3*i+CP_Word_Button_Tag_Offset+k;
            frame.origin.x = Textfield_Space_Width+(Textfield_Width+Textfield_Space_Width)*k;
            frame.origin.y = height+(Textfield_Height+Textfield_Space_Height)*i;
            btn3.frame = frame;
            btn3.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:57/255.0 alpha:1];
            int index = arc4random() % count;
            [btn3 setTitle:[tmpArray objectAtIndex:index] forState:UIControlStateNormal];
            [tmpArray removeObjectAtIndex:index];
            count--;
            
            [self.wordsContainerView addSubview:btn3];
        }
    }
    frame.origin.y += Textfield_Height+Textfield_Space_Height;
    for (int i=0; i<num2; i++) {
        UIButton *btn3 = [self returnButton];
        btn3.tag = 3*num1+CP_Word_Button_Tag_Offset+i;
        
        CGFloat space = (768-Textfield_Width*num2)/(num2+1);
        frame.origin.x = space + (Textfield_Width+space)*i;
        btn3.frame = frame;
        btn3.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:57/255.0 alpha:1];
        int index = arc4random() % count;
        [btn3 setTitle:[tmpArray objectAtIndex:index] forState:UIControlStateNormal];
        [tmpArray removeObjectAtIndex:index];
        count--;
        
        [self.wordsContainerView addSubview:btn3];
    }
    
    [self.wordsContainerView setFrame:CGRectMake(-768, 0, 768, frame.origin.y+Textfield_Height+Textfield_Space_Height*5+100)];
    [self.myScroll addSubview:self.wordsContainerView];
    
    self.myScroll.contentSize = CGSizeMake(768,self.wordsContainerView.frame.size.height+80);
    [self.myScroll setScrollEnabled:YES];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.wordsContainerView setFrame:CGRectMake(0, 0, 768, frame.origin.y+Textfield_Height+Textfield_Space_Height*5+100)];
    } completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.25 animations:^{
                NSArray *subViews = [self.wordsContainerView subviews];
                for (UIView *vv in subViews) {
                    if ([vv isKindOfClass:[UIButton class]]) {
                        UIButton *btn = (UIButton *)vv;
                        CGRect frame = btn.frame;
                        frame.size.width = Textfield_Width;
                        frame.size.height = Textfield_Height;
                        btn.frame = frame;
                    }
                }
            } completion:^(BOOL finished){
            }];
        }
    }];
}

-(void)nextHistoryQuestion:(id)sender {
    [self.myScroll setContentOffset:CGPointMake(0, 0)];
    if (self.branchNumber == self.history_branchQuestionArray.count-1) {
        self.number++;self.branchNumber = 0;
    }else {
        self.branchNumber++;
    }
    [self getQuestionData];
}
-(void)finishHistoryQuestion:(id)sender {
    [self.homeControl dismissViewControllerAnimated:YES completion:nil];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.myScroll setContentOffset:CGPointMake(0, 0)];
    self.again_radio=0;
    
    self.historyView.hidden=YES;
    NSDictionary * dic = [Utility initWithJSONFile:[DataService sharedService].taskObj.taskStartDate];
    NSDictionary *sortDic = [dic objectForKey:@"sort"];
    self.questionArray = [NSMutableArray arrayWithArray:[sortDic objectForKey:@"questions"]];
    self.specified_time = [[sortDic objectForKey:@"specified_time"]intValue];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.homeControl = (HomeworkContainerController *)self.parentViewController;
    self.homeControl.appearCorrectButton.enabled=NO;
    self.homeControl.reduceTimeButton.enabled = NO;
    self.number=0;self.branchNumber=0;self.isFirst= NO;
    //TODO:初始化答案的字典
    self.answerDic = [Utility returnAnswerDictionaryWithName:SORT andDate:[DataService sharedService].taskObj.taskStartDate];
    int number_question = [[self.answerDic objectForKey:@"questions_item"]intValue];
    
    self.preBtn.hidden=YES;self.restartBtn.hidden=YES;
    
    if ([DataService sharedService].taskObj.isExpire == YES) {//作业过期时间
        
        NSMutableArray *h_questions = [[NSMutableArray alloc]init];
        for (int i=0; i<self.questionArray.count; i++) {
            NSMutableDictionary *question = [[NSMutableDictionary alloc]init];
            NSDictionary *dic = [self.questionArray objectAtIndex:i];
            NSArray *b_array = [dic objectForKey:@"branch_questions"];
            NSMutableArray *h_b_question = [[NSMutableArray alloc]init];
            for (int k=0; k<b_array.count; k++) {
                NSDictionary *b_dic = [b_array objectAtIndex:k];
                NSDictionary *answer_dic = [NSDictionary dictionaryWithObjectsAndKeys:[b_dic objectForKey:@"id"],@"id",@"0",@"ratio",@"您未作答",@"answer", nil];
                [h_b_question addObject:answer_dic];
            }
            [question setObject:[dic objectForKey:@"id"] forKey:@"id"];
            [question setObject:h_b_question forKey:@"branch_questions"];
            [h_questions addObject:question];
        }
        if (number_question<0) {//没有过往记录
            [self.answerDic setObject:h_questions forKey:@"questions"];
        }else {
            NSMutableArray *a_question =[NSMutableArray arrayWithArray:[self.answerDic objectForKey:@"questions"]];
            for (int i=0; i<h_questions.count; i++) {
                NSDictionary *dic = [h_questions objectAtIndex:i];
                NSArray *b_array = [dic objectForKey:@"branch_questions"];
                
                if (i<=a_question.count-1) {
                    NSMutableDictionary *a_dic = [NSMutableDictionary dictionaryWithDictionary:[a_question objectAtIndex:i]];
                    NSMutableArray *a_array = [NSMutableArray arrayWithArray:[a_dic objectForKey:@"branch_questions"]];
                    
                    for (int k=0; k<b_array.count; k++) {
                        NSDictionary *b_dic = [b_array objectAtIndex:k];
                        if (k<=a_array.count-1) {
                            
                        }else {
                            [a_array addObject:b_dic];
                        }
                    }
                    [a_dic setObject:a_array forKey:@"branch_questions"];
                    [a_question replaceObjectAtIndex:i withObject:a_dic];
                }else {
                    [a_question addObject:dic];
                }
            }
            [self.answerDic setObject:a_question forKey:@"questions"];
        }
    }
    
    if ([DataService sharedService].isHistory==YES) {
        if (number_question<0 && [DataService sharedService].taskObj.isExpire == NO) {
            [Utility errorAlert:@"暂无历史记录!"];
        }else {
            self.historyView.hidden=NO;
            self.history_questionArray = [NSMutableArray arrayWithArray:[self.answerDic objectForKey:@"questions"]];
            self.homeControl.timeLabel.text = [NSString stringWithFormat:@"%@",[Utility formateDateStringWithSecond:[[self.answerDic objectForKey:@"use_time"]integerValue]]];
            
            CGFloat score_radio=0;int count =0;
            for (int i=0; i<self.history_questionArray.count; i++) {
                NSDictionary *question_dic = [self.history_questionArray objectAtIndex:i];
                NSArray *branchArray = [question_dic objectForKey:@"branch_questions"];
                
                for (int j=0; j<branchArray.count; j++) {
                    count++;
                    NSDictionary *branch_dic = [branchArray objectAtIndex:j];
                    CGFloat radio = [[branch_dic objectForKey:@"ratio"]floatValue];
                    score_radio += radio;
                }
            }
            score_radio = score_radio/count;
            self.homeControl.rotioLabel.text = [NSString stringWithFormat:@"%d%%",(int)score_radio];
            
            [self getQuestionData];
        }
    }else {
        self.preBtn.hidden=NO;self.restartBtn.hidden=NO;
        self.propsArray = [Utility returnAnswerPropsandDate:[DataService sharedService].taskObj.taskStartDate];
        int status = [[self.answerDic objectForKey:@"status"]intValue];
        if (status == 1) {
            
        }else if ([DataService sharedService].taskObj.isExpire == NO){
            
            self.isFirst= YES;
            if ([DataService sharedService].number_reduceTime>0) {
                self.homeControl.reduceTimeButton.enabled = YES;
            }
            if ([DataService sharedService].number_correctAnswer>0) {
                self.homeControl.appearCorrectButton.enabled=YES;
            }
            
            
            int number_branch_question = [[self.answerDic objectForKey:@"branch_item"]intValue];
            
            if (number_question>=0) {
                NSDictionary *dic = [self.questionArray objectAtIndex:number_question];
                NSArray *array = [dic objectForKey:@"branch_questions"];
                if (number_branch_question == array.count-1) {
                    self.number = +1;self.branchNumber = 0;
                }else {
                    self.number = number_question;self.branchNumber = number_branch_question+1;
                }
                
                int useTime = [[self.answerDic objectForKey:@"use_time"]integerValue];
                self.homeControl.spendSecond = useTime;
                NSString *timeStr = [Utility formateDateStringWithSecond:useTime];
                self.homeControl.timerLabel.text = timeStr;
            }
            
        }
        [self getQuestionData];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIButton *)preBtn {
    if (!_preBtn) {
        _preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preBtn setTitle:@"后退一步" forState:UIControlStateNormal];
        [_preBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _preBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
        _preBtn.enabled = NO;
        _preBtn.tag = 567;
        [_preBtn.layer setMasksToBounds:YES];
        [_preBtn.layer setCornerRadius:8];
        [_preBtn setExclusiveTouch :YES];
        _preBtn.titleLabel.font = [UIFont systemFontOfSize:33];
        [_preBtn addTarget:self action:@selector(preButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.wordsContainerView addSubview:_preBtn];
    }
    return _preBtn;
}
-(UIButton *)restartBtn {
    if (!_restartBtn) {
        _restartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_restartBtn setTitle:@"重新排序" forState:UIControlStateNormal];
        [_restartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _restartBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
        _restartBtn.enabled = NO;
        _restartBtn.tag = 854;
        [_restartBtn setExclusiveTouch :YES];
        [_restartBtn.layer setMasksToBounds:YES];
        [_restartBtn.layer setCornerRadius:8];
        _restartBtn.titleLabel.font = [UIFont systemFontOfSize:33];
        [_restartBtn addTarget:self action:@selector(restartButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.wordsContainerView addSubview:_restartBtn];
    }
    return _restartBtn;
}
-(NSMutableDictionary *)maps {
    if (!_maps) {
        _maps = [[NSMutableDictionary alloc]init];
    }
    return _maps;
}
-(NSMutableArray *)actionArray {
    if (!_actionArray) {
        _actionArray = [[NSMutableArray alloc]init];
    }
    return _actionArray;
}

-(NSMutableArray *)propsArray {
    if (!_propsArray) {
        _propsArray = [[NSMutableArray alloc]init];
    }
    return _propsArray;
}
-(AppDelegate *)appDel {
    if (!_appDel) {
        _appDel = [AppDelegate shareIntance];
    }
    return _appDel;
}
#pragma mark -
#pragma mark - button点击事件
-(void)setPreButtonUI {
    if (self.actionArray.count>0) {
        self.preBtn.backgroundColor = [UIColor clearColor];
        [self.preBtn setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
        self.preBtn.enabled = YES;
    }else {
        self.preBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
        [self.preBtn setBackgroundImage:nil forState:UIControlStateNormal];
        self.preBtn.enabled = NO;
    }
}
-(void)setRestartButtonUI {
    if (self.isRestart>0) {
        self.restartBtn.backgroundColor = [UIColor clearColor];
        [self.restartBtn setBackgroundImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
        self.restartBtn.enabled = YES;
    }else {
        self.restartBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
        [self.restartBtn setBackgroundImage:nil forState:UIControlStateNormal];
        self.restartBtn.enabled = NO;
    }
}
-(void)answerButtonSelected:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if([btn.titleLabel.text length]>0){
        [btn setTitle:nil forState:UIControlStateNormal];
        btn.titleLabel.text = nil;
        btn.enabled = NO;
        self.isRestart--;
        [self setRestartButtonUI];
        
        int targetTag = [[self.maps objectForKey:[NSString stringWithFormat:@"%d",btn.tag]] intValue];
        [self.maps removeObjectForKey:[NSString stringWithFormat:@"%d",btn.tag]];

        UIButton *wordBtn = (UIButton *)[self.wordsContainerView viewWithTag:targetTag];
        wordBtn.enabled = YES;
        wordBtn.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:57/255.0 alpha:1];
        
        [self.actionArray addObject:[NSString stringWithFormat:@"%d_%d",btn.tag,wordBtn.tag]];
        [self setPreButtonUI];
        
        if(self.currentWordIndex > (btn.tag - CP_Answer_Button_Tag_Offset)) {
            self.currentWordIndex = btn.tag - CP_Answer_Button_Tag_Offset;
        }
    }
}
- (void)wordButtonSelected:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *text = btn.titleLabel.text;
    
    UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:(self.currentWordIndex+CP_Answer_Button_Tag_Offset)];
    [answerBtn setTitle:text forState:UIControlStateNormal];
    answerBtn.enabled = YES;
    [self.actionArray addObject:[NSString stringWithFormat:@"%d_%d",btn.tag,answerBtn.tag]];
    [self setPreButtonUI];
    
    self.isRestart++;
    [self setRestartButtonUI];
    
    [self.maps setObject:[NSString stringWithFormat:@"%d",btn.tag] forKey:[NSString stringWithFormat:@"%d",answerBtn.tag]];
    
    btn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
    btn.enabled = NO;
    
    // 当前填的字不是最后一个，看下后面的字是否已经填了
    while (self.currentWordIndex!=(self.orgArray.count-1)) {
        self.currentWordIndex++;
        UIButton *ab = (UIButton *)[self.wordsContainerView viewWithTag:(self.currentWordIndex+CP_Answer_Button_Tag_Offset)];
        if([ab.titleLabel.text length]==0){
            return;
        }
    }
}
//后退一步
-(void)preButtonSelected:(id)sender {
    if (self.actionArray.count>0) {
        NSString *tagStr = [self.actionArray lastObject];
        NSArray *array = [tagStr componentsSeparatedByString:@"_"];
        NSString *tag1 = [array objectAtIndex:0];
        NSString *tag2 = [array objectAtIndex:1];
        if (tag1.length==5) {//表示添加
            UIButton *wordBtn = (UIButton *)[self.wordsContainerView viewWithTag:[tag1 intValue]];
            wordBtn.enabled = YES;
            wordBtn.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:57/255.0 alpha:1];
            
            UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:[tag2 intValue]];
            [answerBtn setTitle:nil forState:UIControlStateNormal];
            answerBtn.titleLabel.text = nil;
            answerBtn.enabled = NO;
            
            [self.maps removeObjectForKey:tag2];
            
            self.isRestart--;
            [self setRestartButtonUI];
            
        }else{//表示删除
            UIButton *wordBtn = (UIButton *)[self.wordsContainerView viewWithTag:[tag2 intValue]];
            wordBtn.enabled = NO;
            wordBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
            
            NSString *text = wordBtn.titleLabel.text;
            UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:[tag1 intValue]];
            [answerBtn setTitle:text forState:UIControlStateNormal];
            answerBtn.enabled = YES;
            [self.maps setObject:tag2 forKey:tag1];
            self.isRestart++;
            [self setRestartButtonUI];
        }
        
        [self.actionArray removeLastObject];
        [self setPreButtonUI];
        
        //计算－－－currentWordIndex

        for (int i=0; i<self.orgArray.count; i++) {
            UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:(i+CP_Answer_Button_Tag_Offset)];
            NSString *text = answerBtn.titleLabel.text;
            
            if (text.length==0) {
                self.currentWordIndex = i;
                break;
            }
        }
    }
}
//重新开始
-(void)restartButtonSelected:(id)sender {
    self.actionArray=nil;self.isRestart=0;self.maps=nil;self.currentWordIndex=0;
    [self setPreButtonUI];[self setRestartButtonUI];
    
    for (int i=0; i<self.orgArray.count; i++) {
        UIButton *wordBtn = (UIButton *)[self.wordsContainerView viewWithTag:i+CP_Word_Button_Tag_Offset];
        wordBtn.enabled = YES;
        wordBtn.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:57/255.0 alpha:1];
        
        UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:i+CP_Answer_Button_Tag_Offset];
        [answerBtn setTitle:nil forState:UIControlStateNormal];
        answerBtn.titleLabel.text = nil;
    }
}

//检查
-(void)checkAnswer:(id)sender {
    
    NSString *str = @"";
    NSMutableString *anserString = [NSMutableString string];
    
    for (int i=0; i<self.orgArray.count; i++) {
        UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:i+CP_Answer_Button_Tag_Offset];
        NSString *text = answerBtn.titleLabel.text;
        [anserString appendFormat:@"%@ ",text];
        
        if (text.length<=0) {
            str = @"请先填写您的答案～";
            anserString = [NSMutableString string];
            break;
        }
    }
    
    if (str.length>0) {
        [Utility errorAlert:str];
    }else {
        [self.myScroll setContentOffset:CGPointMake(0, 0)];
        [self.homeControl stopTimer];
        self.homeControl.appearCorrectButton.enabled=NO;
        
        for (int i=0; i<self.orgArray.count; i++) {
            UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:i+CP_Answer_Button_Tag_Offset];
            NSString *text = answerBtn.titleLabel.text;
            if ([text isEqualToString:[self.orgArray objectAtIndex:i]]) {
                self.branchScore++;
                
                [answerBtn setTitleColor:[UIColor colorWithRed:53/255.0 green:207/255.0 blue:143/255.0 alpha:1] forState:UIControlStateNormal];
            }else {
                [answerBtn setTitleColor:[UIColor colorWithRed:245/255.0 green:0/255.0 blue:18/255.0 alpha:1] forState:UIControlStateNormal];
            }
        }
        
        for (UIView *vv in [self.wordsContainerView subviews]) {
            if ([vv isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)vv;
                btn.enabled = NO;
            }
        }
        
        if (self.branchScore == self.orgArray.count) {
            self.again_radio += 100;
            TRUESOUND;
        }else {
            FALSESOUND;
        }
        if (self.branchNumber==self.branchQuestionArray.count-1 && self.number==self.questionArray.count-1) {
            self.homeControl.reduceTimeButton.enabled=NO;
            [self.checkHomeworkButton setTitle:@"完成" forState:UIControlStateNormal];
            [self.checkHomeworkButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
            [self.checkHomeworkButton addTarget:self action:@selector(finishQuestion:) forControlEvents:UIControlEventTouchUpInside];
        }else {
            [self.checkHomeworkButton setTitle:@"下一题" forState:UIControlStateNormal];
            [self.checkHomeworkButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
            [self.checkHomeworkButton addTarget:self action:@selector(nextQuestion:) forControlEvents:UIControlEventTouchUpInside];
        }
        //TODO:写入json
        if (self.isFirst==YES){
            int number_question = [[self.answerDic objectForKey:@"questions_item"]intValue];
            int number_branch_question = [[self.answerDic objectForKey:@"branch_item"]intValue];
            if (number_question>self.number) {
                //表示已经做过这道题
            }else if (number_question==self.number){
                if (number_branch_question>=self.branchNumber) {
                    //表示已经做过这道题
                }else {
                    [self writeToAnswerJsonWithString:anserString];
                }
            }else {
                [self writeToAnswerJsonWithString:anserString];
            }
        }
    }
}
-(void)writeToAnswerJsonWithString:(NSString *)string {
    isCanUpLoad = YES;
    
    if (self.branchNumber==self.branchQuestionArray.count-1 && self.number==self.questionArray.count-1) {
        [self.answerDic setObject:[NSString stringWithFormat:@"%d",1] forKey:@"status"];
        NSString *str = [Utility returnTypeOfQuestionWithString:SORT];
        [[DataService sharedService].taskObj.finish_types addObject:str];
    }
    NSString *time = [Utility getNowDateFromatAnDate];
    [self.answerDic setObject:time forKey:@"update_time"];
    [self.answerDic setObject:[NSString stringWithFormat:@"%d",self.number] forKey:@"questions_item"];
    [self.answerDic setObject:[NSString stringWithFormat:@"%d",self.branchNumber] forKey:@"branch_item"];
    [self.answerDic setObject:[NSString stringWithFormat:@"%lld",self.homeControl.spendSecond] forKey:@"use_time"];
    //一道题目------------------------------------------------------------------
    //正确率
    int ratio;
    if (self.branchScore != self.orgArray.count) {
        ratio = 0;
    }else {
        ratio = 100;
    }
    NSString *a_id = [NSString stringWithFormat:@"%@",[self.branchQuestionDic objectForKey:@"id"]];
    NSDictionary *answer_dic = [NSDictionary dictionaryWithObjectsAndKeys:a_id,@"id",[NSString stringWithFormat:@"%d",ratio],@"ratio",string,@"answer", nil];
    
    NSMutableArray *questions = [NSMutableArray arrayWithArray:[self.answerDic objectForKey:@"questions"]];
    if (questions.count>0) {
        BOOL isExit = NO;
        for (int i=0; i<questions.count; i++) {
            NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:[questions objectAtIndex:i]];
            if ([[mutableDic objectForKey:@"id"]intValue] == [[self.questionDic objectForKey:@"id"]intValue]) {
                isExit = YES;
                
                NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[mutableDic objectForKey:@"branch_questions"]];
                [mutableArray addObject:answer_dic];
                [mutableDic setObject:mutableArray forKey:@"branch_questions"];
                [questions replaceObjectAtIndex:i withObject:mutableDic];
                break;
            }
        }
        
        if (isExit==NO) {
            NSArray *branch_questions = [[NSArray alloc]initWithObjects:answer_dic, nil];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[self.questionDic objectForKey:@"id"],@"id",branch_questions,@"branch_questions", nil];
            [questions addObject:dictionary];
        }
    }else {
        NSArray *branch_questions = [[NSArray alloc]initWithObjects:answer_dic, nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[self.questionDic objectForKey:@"id"],@"id",branch_questions,@"branch_questions", nil];
        [questions addObject:dictionary];
    }
    
    [self.answerDic setObject:questions forKey:@"questions"];
    
    [Utility returnAnswerPathWithDictionary:self.answerDic andName:SORT andDate:[DataService sharedService].taskObj.taskStartDate];
}
-(void)nextQuestion:(id)sender {
    [self.homeControl startTimer];
    [self.myScroll setContentOffset:CGPointMake(0, 0)];
    if ([DataService sharedService].number_correctAnswer>0) {
        self.homeControl.appearCorrectButton.enabled=YES;
    }
    if (self.branchNumber == self.branchQuestionArray.count-1) {
        self.number++;self.branchNumber = 0;
    }else {
        self.branchNumber++;
    }
    
    [self getQuestionData];
}
//结果
-(void)showResultView {
    for (HomeworkTypeObj *type in [DataService sharedService].taskObj.taskHomeworkTypeArray) {
        if (type.homeworkType == self.homeControl.homeworkType) {
            type.homeworkTypeIsFinished = YES;
        }
    }
    
    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"TenSecChallengeResultView" owner:self options:nil];
    self.resultView = (TenSecChallengeResultView *)[viewArray objectAtIndex:0];
    self.resultView.delegate = self;
    self.resultView.timeCount = self.homeControl.spendSecond;
    
    if (self.isFirst == YES) {
        NSString *path = [Utility returnPath];
        NSString *documentDirectory = [path stringByAppendingPathComponent:[DataService sharedService].taskObj.taskStartDate];
        NSString *jsPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"answer_%@.json",[DataService sharedService].user.userId]];
        
        NSError *error = nil;
        Class JSONSerialization = [Utility JSONParserClass];
        NSDictionary *dataObject = [JSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsPath] options:0 error:&error];
        NSMutableDictionary *answerDic = [dataObject objectForKey:SORT];
        NSArray *questionArray = [answerDic objectForKey:@"questions"];
        
        CGFloat score_radio=0;int count =0;
        for (int i=0; i<questionArray.count; i++) {
            NSDictionary *question_dic = [questionArray objectAtIndex:i];
            NSArray *branchArray = [question_dic objectForKey:@"branch_questions"];
            
            for (int j=0; j<branchArray.count; j++) {
                count++;
                NSDictionary *branch_dic = [branchArray objectAtIndex:j];
                CGFloat radio = [[branch_dic objectForKey:@"ratio"]floatValue];
                score_radio += radio;
            }
        }
        score_radio = score_radio/count;
        
        self.resultView.resultBgView.hidden=NO;
        self.resultView.noneArchiveView.hidden=YES;
        self.resultView.ratio = (NSInteger)score_radio;
        self.resultView.timeLimit = self.specified_time;
        self.resultView.isEarly = [Utility compareTime];
    }else {
        int count =0;
        for (int i=0; i<self.questionArray.count; i++) {
            NSDictionary *question_dic = [self.questionArray objectAtIndex:i];
            NSArray *branchArray = [question_dic objectForKey:@"branch_questions"];
            for (int j=0; j<branchArray.count; j++) {
                count++;
            }
        }
        self.resultView.noneArchiveView.hidden=NO;
        self.resultView.resultBgView.hidden=YES;
        self.resultView.ratio = (NSInteger)(self.again_radio/count);
    }
    
    [self.resultView initView];
    
    [self.myScroll addSubview: self.resultView];
}

-(void)finishQuestion:(id)sender {
    self.homeControl.appearCorrectButton.enabled=NO;
    self.homeControl.reduceTimeButton.enabled=NO;
    
    [self.myScroll setContentOffset:CGPointMake(0, 0)];
    if (self.isFirst==YES) {
        self.postNumber = 0;
        if (self.appDel.isReachable == NO) {
            [Utility errorAlert:@"暂无网络!"];
        }else {
            [MBProgressHUD showHUDAddedTo:self.appDel.window animated:YES];
            self.postInter = [[BasePostInterface alloc]init];
            self.postInter.delegate = self;
            [self.postInter postAnswerFileWith:[DataService sharedService].taskObj.taskStartDate];
        }
    }else {
        [self showResultView];
    }
    
}
#pragma mark
#pragma mark - PostDelegate
-(void)getPostInfoDidFinished:(NSDictionary *)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.appDel.window animated:YES];
            [DataService sharedService].cardsCount = [[result objectForKey:@"knowledges_cards_count"]integerValue];
            //上传answer.json文件之后返回的更新时间
            NSString *timeStr = [result objectForKey:@"updated_time"];
            [Utility returnAnswerPAthWithString:timeStr];
            self.checkHomeworkButton.enabled=NO;
            isCanUpLoad=NO;
            if (self.postNumber==0) {
                [self showResultView];
            }else {
                [self.homeControl dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        });
    });
}
-(void)getPostInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.appDel.window animated:YES];
    [Utility errorAlert:errorMsg];
    [Utility uploadFaild];
    [self.homeControl dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark - TenSecChallengeResultViewDelegate
-(void)resultViewCommitButtonClicked {//确认完成
    [self.resultView removeFromSuperview];
    [self.homeControl dismissViewControllerAnimated:YES completion:nil];
}
-(void)resultViewRestartButtonClicked {//再次挑战
    [self.resultView removeFromSuperview];
    
    self.checkHomeworkButton.enabled=YES;
    self.number=0;self.branchNumber=0;self.isFirst = NO;
    self.homeControl.spendSecond = 0;self.again_radio=0;
    self.homeControl.reduceTimeButton.enabled=NO;
    self.homeControl.appearCorrectButton.enabled=NO;
    [self.homeControl startTimer];
    [self getQuestionData];
}

#pragma mark
#pragma mark - 道具
//道具  显示正确答案
-(void)showSortCorrectAnswer {
    [DataService sharedService].number_correctAnswer -= 1;
    if ([DataService sharedService].number_correctAnswer==0) {
        self.homeControl.appearCorrectButton.enabled = NO;
    }
    NSMutableString *anserString = [NSMutableString string];
    
    NSMutableDictionary *branch_propDic = [NSMutableDictionary dictionaryWithDictionary:[self.propsArray objectAtIndex:1]];
    NSMutableArray *branch_propArray = [NSMutableArray arrayWithArray:[branch_propDic objectForKey:@"branch_id"]];
    [branch_propArray addObject:[NSNumber numberWithInt:[[self.branchQuestionDic objectForKey:@"id"] intValue]]];
    [branch_propDic setObject:branch_propArray forKey:@"branch_id"];
    [self.propsArray replaceObjectAtIndex:1 withObject:branch_propDic];
    [Utility returnAnswerPathWithProps:self.propsArray andDate:[DataService sharedService].taskObj.taskStartDate];
    
    self.branchScore = self.orgArray.count;
    for (int i=0; i<self.orgArray.count; i++) {
        [anserString appendFormat:@"%@ ",[self.orgArray objectAtIndex:i]];
        NSString *title_str = [self.orgArray objectAtIndex:i];

        UIButton *answerBtn = (UIButton *)[self.wordsContainerView viewWithTag:i+CP_Answer_Button_Tag_Offset];
        [answerBtn setTitle:title_str forState:UIControlStateDisabled];
        [answerBtn setTitleColor:[UIColor colorWithRed:53/255.0 green:207/255.0 blue:143/255.0 alpha:1] forState:UIControlStateDisabled];
        answerBtn.enabled = NO;
        
        UIButton *wordBtn = (UIButton *)[self.wordsContainerView viewWithTag:i+CP_Word_Button_Tag_Offset];
        wordBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
        wordBtn.enabled = NO;
    }
    self.preBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
    [self.preBtn setBackgroundImage:nil forState:UIControlStateNormal];
    self.preBtn.enabled = NO;
    
    self.restartBtn.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
    [self.restartBtn setBackgroundImage:nil forState:UIControlStateNormal];
    self.restartBtn.enabled = NO;
    
    [self.homeControl stopTimer];
    self.homeControl.appearCorrectButton.enabled=NO;
    
    if (self.branchNumber==self.branchQuestionArray.count-1 && self.number==self.questionArray.count-1) {
        [self.checkHomeworkButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.checkHomeworkButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [self.checkHomeworkButton addTarget:self action:@selector(finishQuestion:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [self.checkHomeworkButton setTitle:@"下一题" forState:UIControlStateNormal];
        [self.checkHomeworkButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [self.checkHomeworkButton addTarget:self action:@selector(nextQuestion:) forControlEvents:UIControlEventTouchUpInside];
    }
    //TODO:写入json
    int number_question = [[self.answerDic objectForKey:@"questions_item"]intValue];
    int number_branch_question = [[self.answerDic objectForKey:@"branch_item"]intValue];
    if (number_question>self.number) {
        //表示已经做过这道题
    }else if (number_question==self.number){
        if (number_branch_question>=self.branchNumber) {
            //表示已经做过这道题
        }else {
            [self writeToAnswerJsonWithString:anserString];
        }
    }else {
        [self writeToAnswerJsonWithString:anserString];
    }
}
//道具  减少时间
- (void)sortViewReduceTimeButtonClicked{
    [DataService sharedService].number_reduceTime -= 1;
    if ([DataService sharedService].number_reduceTime==0) {
        self.homeControl.reduceTimeButton.enabled = NO;
    }
    if (self.homeControl.spendSecond > 5) {
        self.homeControl.spendSecond = self.homeControl.spendSecond -5;
    }else{
        self.homeControl.spendSecond = 0;
    }
    self.homeControl.timerLabel.text = [Utility formateDateStringWithSecond:(NSInteger)self.homeControl.spendSecond];
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){self.view.frame.size.width/2,120,70,50}];
    [label setFont:[UIFont systemFontOfSize:50]];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor orangeColor];
    label.text = @"-5";
    [self.homeControl.view addSubview:label];
    [self.homeControl.view setUserInteractionEnabled:NO];
    label.alpha = 1;
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        [self.homeControl.view setUserInteractionEnabled:YES];
    }];
    
    NSMutableDictionary *branch_propDic = [NSMutableDictionary dictionaryWithDictionary:[self.propsArray objectAtIndex:0]];
    NSMutableArray *branch_propArray = [NSMutableArray arrayWithArray:[branch_propDic objectForKey:@"branch_id"]];
    [branch_propArray addObject:[NSNumber numberWithInt:[[self.branchQuestionDic objectForKey:@"id"] intValue]]];
    [branch_propDic setObject:branch_propArray forKey:@"branch_id"];
    [self.propsArray replaceObjectAtIndex:0 withObject:branch_propDic];
    [Utility returnAnswerPathWithProps:self.propsArray andDate:[DataService sharedService].taskObj.taskStartDate];
}

-(void)exitSortView {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"作业提示" message:@"确定退出做题?" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"取消", nil];
    alert.tag = 100;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (alertView.tag == 100) {
        if (buttonIndex==0) {
            if (self.isFirst==YES && isCanUpLoad==YES) {
                self.postNumber = 1;
                if (self.appDel.isReachable == NO) {
                    [Utility errorAlert:@"暂无网络!"];
                }else {
                    [MBProgressHUD showHUDAddedTo:self.appDel.window animated:YES];
                    self.postInter = [[BasePostInterface alloc]init];
                    self.postInter.delegate = self;
                    [self.postInter postAnswerFileWith:[DataService sharedService].taskObj.taskStartDate];
                }
            }else {
                [self.homeControl dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}
@end
