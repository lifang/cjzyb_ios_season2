//
//  SecondViewController.m
//  cjzyb_ios
//
//  Created by comdosoft on 14-2-26.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "SecondViewController.h"
#define Head_Size 102.75
#define Insets 10
#define Label_Height 20
#define Space_head_text 23.25
#define CELL_WIDTH self.view.frame.size.width
#define SECOND_HEADER_IDENTIFIER  @"second_header"

//static NSInteger tmpPagecount = 0;

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)textBarInit {

    self.textView.frame = CGRectMake(3, 3, 710, 44);
    [self.textBar addSubview:self.textView];
    
    self.textBar.frame = CGRectMake(0, self.view.frame.size.height, 768, 50);
    [self.view addSubview:self.textBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isReloading = NO;self.isLoading=NO;
    [self.secondTable registerClass:[FirstViewHeader class] forHeaderFooterViewReuseIdentifier:SECOND_HEADER_IDENTIFIER];
    [self textBarInit];
    self.second = 1;
    //问答之后更新界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSecondArrayByThirdView:) name:@"reloadSecondArrayByThirdView" object:nil];
    
    //修改头像之后更新界面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSecondArrayByImage:) name:@"reloadSecondArrayByImage" object:nil];
    //下拉刷新
    __block SecondViewController *secondView = self;
    __block UITableView *table = self.secondTable;
    [_secondTable addPullToRefreshWithActionHandler:^{
        secondView.isReloading = YES;
        secondView.isLoading=NO;
        [secondView getMymessageData];
        [table.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:1];
    }];

    [self getMymessageData];
}
- (void)reloadSecondArrayByImage:(NSNotification *)notification {
    [self.secondTable reloadData];
}


- (void)reloadSecondArrayByThirdView:(NSNotification *)notification {
    MessageObject *message = [notification object];
    
    [self.secondArray insertObject:message atIndex:0];
    self.headerArray= nil;self.cellArray= nil;self.arrSelSection=nil;

    [self.secondTable reloadData];
    
    for (int i=0; i<self.secondArray.count; i++) {
        FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:i];
        header.aSection =i;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    int lastObject = [[[DataService sharedService].numberOfViewArray lastObject]intValue];
    
    if (lastObject==self.second) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShowSecond:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHideSecond:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
//获取我的主消息
-(void)getMymessageData {
    self.headerArray= nil;self.cellArray= nil;self.arrSelSection=nil;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.mMessageInter getMyMessageInterfaceDelegateWithClassId:[DataService sharedService].theClass.classId andUserId:[DataService sharedService].user.userId andPage:1];
}
#pragma mark -
#pragma mark - property
-(NSMutableArray *)secondArray {
    if (!_secondArray) {
        _secondArray = [[NSMutableArray alloc]init];
    }
    return _secondArray;
}
-(NSMutableArray *)cellArray {
    if (!_cellArray) {
        _cellArray = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return _cellArray;
}

-(NSMutableArray *)headerArray {
    if (!_headerArray) {
        _headerArray = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return _headerArray;
}
-(NSMutableArray *)arrSelSection {
    if (!_arrSelSection) {
        _arrSelSection = [[NSMutableArray alloc]init];
    }
    return _arrSelSection;
}

-(UIActivityIndicatorView *)indicView {
    if (!_indicView) {
        _indicView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(269, 10, 30, 30)];
        _indicView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [_indicView startAnimating];
    }
    return _indicView;
}
-(FocusInterface *)focusInter {
    if (!_focusInter) {
        _focusInter = [[FocusInterface alloc]init];
        _focusInter.delegate = self;
    }
    return _focusInter;
}
-(DeleteMessage *)deleteInter {
    if (!_deleteInter) {
        _deleteInter = [[DeleteMessage alloc]init];
        _deleteInter.delegate = self;
    }
    return _deleteInter;
}
-(ReplyMessageInterface *)rmessageInter {
    if (!_rmessageInter) {
        _rmessageInter = [[ReplyMessageInterface alloc]init];
        _rmessageInter.delegate = self;
    }
    return _rmessageInter;
}
-(SendMessageInterface *)sendInter {
    if (!_sendInter) {
        _sendInter = [[SendMessageInterface alloc]init];
        _sendInter.delegate = self;
    }
    return _sendInter;
}
-(MyMessageInterface *)mMessageInter {
    if (!_mMessageInter) {
        _mMessageInter = [[MyMessageInterface alloc]init];
        _mMessageInter.delegate = self;
    }
    return _mMessageInter;
}
-(AppDelegate *)appDel {
    if (!_appDel) {
        _appDel = [AppDelegate shareIntance];
    }
    return _appDel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark
#pragma mark - Keyboard notifications
- (void)keyboardWillShowSecond:(NSNotification *)notification {
    int lastObject = [[[DataService sharedService].numberOfViewArray lastObject]intValue];
    if (lastObject == self.second){
        
        NSDictionary *userInfo = [notification userInfo];
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        CGRect keyboardRect = [aValue CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
        
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             CGRect frame = keyboardRect;
                             frame.origin.y -= self.textBar.frame.size.height;
                             frame.size.height = self.textBar.frame.size.height;
                             self.textBar.frame = frame;
                         }];
    }
    
}
- (void)keyboardWillHideSecond:(NSNotification *)notification {
    int lastObject = [[[DataService sharedService].numberOfViewArray lastObject]intValue];
    if (lastObject == self.second){
        NSDictionary *userInfo = [notification userInfo];
        
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.textBar.frame = CGRectMake(0, self.view.frame.size.height, 768, 50);
                             
                         }];
    }
    
}

#pragma mark
#pragma mark - Text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)_textView {
    [self calculateTextLength];
    CGSize size = self.textView.contentSize;
    size.height -= 2;
    if ( size.height >= 368 ) {
        size.height = 368;
    }
    else if ( size.height <= 44 ) {
        size.height = 44;
    }
    if ( size.height != self.textView.frame.size.height ) {
        CGFloat span = size.height - self.textView.frame.size.height;
        CGRect frame = self.textBar.frame;
        frame.origin.y -= span;
        frame.size.height += span;
        self.textBar.frame = frame;
        
        frame = self.textView.frame;
        frame.size = size;
        self.textView.frame = frame;
        
        frame = self.textCountLabel.frame;
        frame.origin.y -= span;
        frame.size = size;
        self.textCountLabel.frame = frame;
    }
}
#pragma mark ---- 计算文本的字数
- (int)textLength:(NSString *)text
{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++)
    {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number + 0.5;
        }
    }
    return ceil(number);
}

- (void)calculateTextLength
{
    NSString *string = self.textView.text;
    int wordcount = [self textLength:string];
    
	[self.textCountLabel setText:[NSString stringWithFormat:@"%i/60",wordcount]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {

        int wordcount = [self textLength:self.textView.text];
        if (wordcount>60) {
            [Utility errorAlert:@"最多输入60个字!"];
        }else {
            [textView resignFirstResponder];
            if (self.type == 1) {//回复的主消息
                if (self.appDel.isReachable == NO) {
                    [Utility errorAlert:@"暂无网络!"];
                }else {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.tmpSection];
                    [self.sendInter getSendDelegateWithSendId:[DataService sharedService].user.userId andSendType:@"1" andClassId:[DataService sharedService].theClass.classId andReceiverId:message.userId andReceiverType:message.userType andmessageId:message.messageId andContent:self.textView.text andType:self.type];
                }
            }else {//回复的子消息
                if (self.appDel.isReachable == NO) {
                    [Utility errorAlert:@"暂无网络!"];
                }else {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.theIndex.section];
                    ReplyMessageObject *replyMsg = (ReplyMessageObject *)[message.replyMessageArray objectAtIndex:self.theIndex.row];
                    [self.sendInter getSendDelegateWithSendId:[DataService sharedService].user.userId andSendType:@"1" andClassId:[DataService sharedService].theClass.classId andReceiverId:replyMsg.sender_id andReceiverType:replyMsg.sender_types andmessageId:message.messageId andContent:self.textView.text andType:self.type];
                }
  
            }
        }
        return NO;
    }
    
    return YES;
}
#pragma mark
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 160;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:section];
    header.aSection = section;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FirstViewHeader *header = (FirstViewHeader*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:SECOND_HEADER_IDENTIFIER];
    header.delegate = self;
    MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:section];
    header.aMessage = message;
    if ([message.userId integerValue] == [[DataService sharedService].user.userId integerValue]) {
        header.msgStyle = MessageCellStyleMe;
    }else {
        header.msgStyle = MessageCellStyleOther;
    }
    header.aSection = section;
    
    BOOL isSelSection = NO;
    for (int i = 0; i < self.arrSelSection.count; i++) {
        NSString *strSection = [NSString stringWithFormat:@"%@",[self.arrSelSection objectAtIndex:i]];
        NSInteger selSection = strSection.integerValue;
        if (section == selSection) {
            isSelSection = YES;
            break;
        }
    }
    header.isSelected = isSelSection;
    
    return header;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.secondArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (int i = 0; i < self.arrSelSection.count; i++) {
        NSString *strSection = [NSString stringWithFormat:@"%@",[self.arrSelSection objectAtIndex:i]];
        NSInteger selSection = strSection.integerValue;
        if (section == selSection) {
            MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:section];
            ReplyMessageObject *replyMsg = (ReplyMessageObject *)[message.replyMessageArray lastObject];
            if (replyMsg.pageCountCell>replyMsg.pageCell) {//还有未加载数据
                return message.replyMessageArray.count+1;
            }else
                return message.replyMessageArray.count;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:indexPath.section];
    if (indexPath.row<message.replyMessageArray.count) {
        return 160;
    }else {
        return 50;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"secondCell";
    FirstCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[FirstCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:indexPath.section];
    if ([message.userId integerValue] == [[DataService sharedService].user.userId integerValue]) {
        cell.messageStyle = MessageCellStyleMe;
    }else {
        cell.messageStyle = MessageCellStyleOther;
    }
    
    if (indexPath.row<message.replyMessageArray.count) {
        ReplyMessageObject *replyMessage = (ReplyMessageObject *)[message.replyMessageArray objectAtIndex:indexPath.row];
        if ([replyMessage.sender_id integerValue] == [[DataService sharedService].user.userId integerValue]) {
            cell.msgStyle = ReplyMessageCellStyleMe;
        }else {
            cell.msgStyle = ReplyMessageCellStyleOther;
        }
        cell.aReplyMsg =replyMessage;
        cell.idxPath = indexPath;
        cell.isHiddenLoadButton = YES;
    }else {
        cell.isHiddenLoadButton = NO;;
    }
    
    BOOL isSelSection = NO;
    for (int i = 0; i < self.cellArray.count; i++) {
        NSIndexPath *idxPath = (NSIndexPath *)[self.cellArray objectAtIndex:i];
        if (idxPath.section==indexPath.section && idxPath.row==indexPath.row) {
            isSelSection = YES;
            break;
        }
    }
    cell.isSelected = isSelSection;
    cell.delegate = self;
    cell.aRow = indexPath.row;
    return cell;
}

-(void)initFooterView {
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 768, 50)];
    header.backgroundColor = [UIColor clearColor];
    [header addSubview:self.indicView];
    UILabel *loadLab = [[UILabel alloc]initWithFrame:CGRectMake(self.indicView.frame.origin.x+30, 10, 200, 30)];
    loadLab.text = @"正在努力加载中...";
    [header addSubview:loadLab];
    self.secondTable.tableFooterView = header;
}

//分页加载获取主消息
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0){
        if (scrollView.contentOffset.y + self.secondTable.frame.size.height >= scrollView.contentSize.height  && self.isLoading==NO) {
            self.isLoading=YES;
            MessageObject *message = (MessageObject *)[self.secondArray lastObject];
            if (message.pageCountHeader>message.pageHeader) {
                [self initFooterView];
                [self.secondTable setContentOffset:CGPointMake(0, scrollView.contentOffset.y+50)];
                //TODO:分页加载我的消息
                [self.mMessageInter getMyMessageInterfaceDelegateWithClassId:[DataService sharedService].theClass.classId andUserId:[DataService sharedService].user.userId andPage:message.pageHeader+1];
            }
        }
    }
}
//调整位置
-(void)setContentOfsetWithSection:(int)aSection {
    NSInteger rows = [self.secondTable numberOfRowsInSection:aSection];
    if(rows > 0) {
        MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:aSection];
        
        int row = 0;
        int replyMsgCount = message.replyMessageArray.count;
        if (replyMsgCount>10) {
            int left = replyMsgCount%10;
            if (left==0) {
                row = replyMsgCount-10;
            }else {
                row = replyMsgCount-left;
            }
        }
        
        [self.secondTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:aSection]
                               atScrollPosition:UITableViewScrollPositionTop
                                       animated:YES];
    }
}
#pragma mark
#pragma mark - FirstViewHeaderDelegate  主消息
-(void)comfirmTheCellWith:(NSInteger)aSection {
    if (self.cellArray.count > 0) {
        NSIndexPath *idx = (NSIndexPath *)[self.cellArray objectAtIndex:0];
        if (idx.section == aSection) {
            FirstCell *cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:idx];
            [cell close];
            [self.cellArray removeAllObjects];
        }
    }
}
-(void)resetTableViewHeaderByIndex:(NSInteger)theSection{
    if (self.headerArray.count > 0) {
        NSInteger aSection = [[self.headerArray objectAtIndex:0]integerValue];
        if (aSection != theSection) {
            FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:aSection];
            [self comfirmTheCellWith:aSection];
            [header close];
            [self.headerArray removeAllObjects];
            
            header = (FirstViewHeader *)[self.secondTable headerViewForSection:theSection];
            [header open];
            [self.headerArray addObject:[NSString stringWithFormat:@"%d",theSection]];
        }else {
            FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:theSection];
            [self comfirmTheCellWith:theSection];
            [header close];
            [self.headerArray removeAllObjects];
        }
    }else {
        FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:theSection];
        [header open];
        [self.headerArray addObject:[NSString stringWithFormat:@"%d",theSection]];
    }
}
- (void)contextMenuHeaderDidSelectCoverOption:(FirstViewHeader *)header{
    [self.textView resignFirstResponder];
    
    self.tmpSection = header.aSection;
    //判断打开还是关闭
    BOOL isSelSection = NO;
    if (self.arrSelSection.count>0) {
        NSString *string = [NSString stringWithFormat:@"%d",header.aSection];
        NSString *string2 = [self.arrSelSection objectAtIndex:0];
        if ([self.arrSelSection containsObject:string]) {
            isSelSection = YES;
            [self.arrSelSection removeAllObjects];
        }else {
            [self.arrSelSection removeAllObjects];
            [self resetTableViewHeaderByIndex:[string2 integerValue]];
            [self.secondTable beginUpdates];
            [self.secondTable reloadSections:[NSIndexSet indexSetWithIndex:[string2 integerValue]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.secondTable endUpdates];
        }
    }
    
    if (!isSelSection) {//关闭状态
        MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:header.aSection];
        [self.arrSelSection addObject:[NSString stringWithFormat:@"%d",header.aSection]];
        if ([message.replyCount integerValue]>0) {//有回复的前提下
            if (message.replyMessageArray.count==0) {//没有回复信息
                //获取子消息
                if (self.appDel.isReachable == NO) {
                    [Utility errorAlert:@"暂无网络!"];
                }else {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [self.rmessageInter getReplyMessageInterfaceDelegateWithMessageId:message.messageId andPage:1];
                }
            }else {
                [self.secondTable beginUpdates];
                [self.secondTable reloadSections:[NSIndexSet indexSetWithIndex:header.aSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.secondTable endUpdates];
                [self resetTableViewHeaderByIndex:header.aSection];
            }
        }else {
            [self resetTableViewHeaderByIndex:header.aSection];
        }
        
    }else {//打开状态
        [self resetTableViewHeaderByIndex:header.aSection];
        [self.secondTable beginUpdates];
        [self.secondTable reloadSections:[NSIndexSet indexSetWithIndex:header.aSection] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.secondTable endUpdates];
    }
}
- (void)contextMenuHeaderDidSelectFocusOption:(FirstViewHeader *)header {
    self.tmpSection = header.aSection;

    if (self.appDel.isReachable == NO) {
        [Utility errorAlert:@"暂无网络!"];
    }else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if (header.aMessage.isFollow == YES) {
            [self.focusInter getFocusInterfaceDelegateWithMessageId:header.aMessage.messageId andUserId:[DataService sharedService].user.userId andType:0];
        }else {
            [self.focusInter getFocusInterfaceDelegateWithMessageId:header.aMessage.messageId andUserId:[DataService sharedService].user.userId andType:1];
        }
    }
 
}
//TODO:回复主消息
- (void)contextMenuHeaderDidSelectCommentOption:(FirstViewHeader *)header {
    
    //    MessageObject *message = (MessageObject *)[self.firstArray objectAtIndex:header.aSection];
    //    if ([message.userId integerValue]==[[DataService sharedService].user.userId integerValue]) {
    //        //do nothing
    //    }else {
    [self.textView becomeFirstResponder];
    self.tmpSection = header.aSection;
    self.type = 1;//回复的主消息
    //    }
}
- (void)contextMenuHeaderDidSelectDeleteOption:(FirstViewHeader *)header {
    [header.superview sendSubviewToBack:header];
    self.tmpSection = header.aSection;
    if (self.appDel.isReachable == NO) {
        [Utility errorAlert:@"暂无网络!"];
    }else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:header.aSection];
        [self.deleteInter getDeleteMessageDelegateDelegateWithMessageId:message.messageId andType:1];
    }
}

#pragma mark
#pragma mark - FirstCellDelegate
-(void)resetTableViewCellByIndex:(NSIndexPath *)aIndex{
    if (self.cellArray.count > 0) {
        NSIndexPath *idx = (NSIndexPath *)[self.cellArray objectAtIndex:0];
        if (idx.section!=aIndex.section || idx.row!=aIndex.row) {
            FirstCell *cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:idx];
            [cell close];
            [self.cellArray removeAllObjects];
            
            cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:aIndex];
            [cell open];
            [self.cellArray addObject:aIndex];
        }else {
            FirstCell *cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:aIndex];
            [cell close];
            [self.cellArray removeAllObjects];
        }
    }else {
        FirstCell *cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:aIndex];
        [cell open];
        [self.cellArray addObject:aIndex];
    }
}

- (void)contextMenuCellDidSelectCoverOption:(FirstCell *)cell {
    [self.textView resignFirstResponder];
    self.theIndex = [self.secondTable indexPathForCell:cell];
    [self resetTableViewCellByIndex:self.theIndex];
}
//TODO:回复子消息
- (void)contextMenuCellDidSelectCommentOption:(FirstCell *)cell {
    self.theIndex = [self.secondTable indexPathForCell:cell];
    //
    //    MessageObject *message = (MessageObject *)[self.firstArray objectAtIndex:self.theIndex.section];
    //    ReplyMessageObject *replyMsg = (ReplyMessageObject *)[message.replyMessageArray objectAtIndex:self.theIndex.row];
    //    if ([replyMsg.sender_id integerValue]==[[DataService sharedService].user.userId integerValue]) {
    //        //do nothing
    //    }else {
    [self.textView becomeFirstResponder];
    self.type = 0;//回复的子消息
    //    }
}
- (void)contextMenuCellDidSelectDeleteOption:(FirstCell *)cell {
    [cell.superview sendSubviewToBack:cell];
    self.theIndex = [self.secondTable indexPathForCell:cell];

    if (self.appDel.isReachable == NO) {
        [Utility errorAlert:@"暂无网络!"];
    }else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.theIndex.section];
        ReplyMessageObject *replyMsg = (ReplyMessageObject *)[message.replyMessageArray objectAtIndex:self.theIndex.row];
        
        [self.deleteInter getDeleteMessageDelegateDelegateWithMessageId:replyMsg.micropost_id andType:0];
    }
}
- (void)contextMenuCellDidSelectLoadOption:(FirstCell *)cell {
    self.theIndex = [self.secondTable indexPathForCell:cell];
    self.tmpSection = self.theIndex.section;
    MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.theIndex.section];

    if (self.appDel.isReachable == NO) {
        [Utility errorAlert:@"暂无网络!"];
    }else {
        //获取子消息
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        int page = 1;
        int replyCount = [message.replyCount integerValue];
        int replyMsgCount = message.replyMessageArray.count;
        int left_number = replyCount-replyMsgCount;
        if (left_number>0) {
            page += replyMsgCount/10;
        }
        [self.rmessageInter getReplyMessageInterfaceDelegateWithMessageId:message.messageId andPage:page];
    }
    
}

#pragma mark
#pragma mark - 子消息
-(void)getReplyMessageInfoDidFinished:(NSDictionary *)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *aDic = [result objectForKey:@"reply_microposts"];
            
            
            NSArray *array = [aDic objectForKey:@"reply_microposts"];
            MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.tmpSection];
            if ([message.replyCount integerValue]<=10) {
                message.replyMessageArray = [[NSMutableArray alloc]init];
            }
            if (array.count>0) {
                for (int i=0; i<array.count; i++) {
                    NSDictionary *dic = [array objectAtIndex:i];
                    ReplyMessageObject *replyMsg = [ReplyMessageObject replyMessageFromDictionary:dic];
                    replyMsg.pageCell = [[aDic objectForKey:@"page"]integerValue];
                    replyMsg.pageCountCell = [[aDic objectForKey:@"pages_count"]integerValue];
                    [message.replyMessageArray addObject:replyMsg];
                }
                [self.secondTable beginUpdates];
                [self.secondTable reloadSections:[NSIndexSet indexSetWithIndex:self.tmpSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.secondTable endUpdates];
            }
            [self.headerArray removeAllObjects];
            [self resetTableViewHeaderByIndex:self.tmpSection];
            
            [self setContentOfsetWithSection:self.tmpSection];
        });
    });
}
-(void)getReplyMessageInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}

#pragma mark
#pragma mark - 关注
-(void)getFocusInfoDidFinished:(NSDictionary *)result andType:(NSInteger)type{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:self.tmpSection];
            MessageObject *message = header.aMessage;
            if (type == 0) {
                message.followCount = [NSString stringWithFormat:@"%d",[message.followCount integerValue]-1];
                message.isFollow = NO;
            }else{
                message.followCount = [NSString stringWithFormat:@"%d",[message.followCount integerValue]+1];
                message.isFollow = YES;
            }
            header.aMessage = message;
        });
    });
}
-(void)getFocusInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}
#pragma mark
#pragma mark - 删除

-(void)getDeleteMsgInfoDidFinished:(NSDictionary *)result andType:(NSInteger)type{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (type==1) {
                MessageObject *message = [self.secondArray objectAtIndex:self.tmpSection];
                [self.arrSelSection removeAllObjects];
                [self.secondArray removeObjectAtIndex:self.tmpSection];
                [self.secondTable beginUpdates];
                [self.secondTable deleteSections:[NSIndexSet indexSetWithIndex:self.tmpSection] withRowAnimation:UITableViewRowAnimationFade];
                [self.secondTable endUpdates];
                for (int i=0; i<self.secondArray.count; i++) {
                    FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:i];
                    header.aSection =i;
                }
                [self.arrSelSection removeAllObjects];
                [self.headerArray removeAllObjects];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFirstArrayHeaderBySecondView" object:message];
            }else {
                FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:self.theIndex.section];
                MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.theIndex.section];
                message.replyCount = [NSString stringWithFormat:@"%d",[message.replyCount integerValue]-1];
                [message.replyMessageArray removeObjectAtIndex:self.theIndex.row];
                header.aMessage = message;
                [self.secondTable beginUpdates];
                [self.secondTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:self.theIndex, nil] withRowAnimation:UITableViewRowAnimationFade];
                [self.secondTable endUpdates];
                [self.cellArray removeAllObjects];
                
                for (int i=0; i<message.replyMessageArray.count; i++) {
                    FirstCell *cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:self.theIndex.section]];
                    cell.aRow = i;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadFirstArrayCellBySecondView" object:self.theIndex];
            }
        });
    });
}
-(void)getDeleteMsgInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}

#pragma mark
#pragma mark - 回复
-(void)getSendInfoDidFinished:(NSDictionary *)result anType:(NSInteger)type{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.textView.text = @"";self.textCountLabel.text = @"0/60";
            if (type==1) {//回复的主消息
                NSArray *array = [result objectForKey:@"replymicropost"];
                NSDictionary *dic = [array objectAtIndex:0];
                ReplyMessageObject *replyMsg = [ReplyMessageObject replyMessageFromDictionary:dic];
                FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:self.tmpSection];
                MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.tmpSection];
                message.replyCount = [NSString stringWithFormat:@"%d",[message.replyCount integerValue]+1];
                [message.replyMessageArray insertObject:replyMsg atIndex:0];
                header.aMessage = message;
                if ([message.replyCount integerValue]==1) {
                    [self.arrSelSection addObject:[NSString stringWithFormat:@"%d",self.tmpSection]];
                    [self.secondTable beginUpdates];
                    [self.secondTable reloadSections:[NSIndexSet indexSetWithIndex:self.tmpSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.secondTable endUpdates];
                }else {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:self.tmpSection];
                    [self.secondTable beginUpdates];
                    [self.secondTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationFade];
                    [self.secondTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.secondTable endUpdates];
                }
                
                for (int i=0; i<message.replyMessageArray.count; i++) {
                    FirstCell *cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:self.tmpSection]];
                    cell.aRow = i;
                }
            }else {//回复的子消息
                NSArray *array = [result objectForKey:@"replymicropost"];
                NSDictionary *dic = [array objectAtIndex:0];
                ReplyMessageObject *replyMsg = [ReplyMessageObject replyMessageFromDictionary:dic];
                FirstViewHeader *header = (FirstViewHeader *)[self.secondTable headerViewForSection:self.theIndex.section];
                MessageObject *message = (MessageObject *)[self.secondArray objectAtIndex:self.theIndex.section];
                message.replyCount = [NSString stringWithFormat:@"%d",[message.replyCount integerValue]+1];
                [message.replyMessageArray insertObject:replyMsg atIndex:0];
                header.aMessage = message;
                [self.cellArray removeAllObjects];
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:self.theIndex.section];
                [self.secondTable beginUpdates];
                [self.secondTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationFade];
                [self.secondTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.secondTable endUpdates];
                
                for (int i=0; i<message.replyMessageArray.count; i++) {
                    FirstCell *cell = (FirstCell *)[self.secondTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:self.theIndex.section]];
                    cell.aRow = i;
                }
                
                index = [NSIndexPath indexPathForRow:self.theIndex.row+1 inSection:self.theIndex.section];
                [self.cellArray addObject:index];
                [self resetTableViewCellByIndex:index];
            }
        });
    });
}
-(void)getSendInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}
#pragma mark
#pragma mark - 我的主消息
-(void)getMyMessageInfoDidFinished:(NSDictionary *)result {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.isLoading=NO;
            
            NSArray *array = [result objectForKey:@"details_microposts"];
            if (array.count>0) {
                if (self.isReloading == YES) {
                    self.secondArray = nil;
                    self.isReloading = NO;
                }
                
                for (int i=0; i<array.count; i++) {
                    NSDictionary *dic = [array objectAtIndex:i];
                    MessageObject *message = [MessageObject messageFromDictionary:dic];
                    message.pageHeader = [[result objectForKey:@"page"]integerValue];
                    message.pageCountHeader = [[result objectForKey:@"pages_count"]integerValue];
                    [self.secondArray addObject:message];
                }
                [self.secondTable reloadData];
            }
        });
    });
}
-(void)getMyMessageInfoDidFailed:(NSString *)errorMsg {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Utility errorAlert:errorMsg];
}
@end
