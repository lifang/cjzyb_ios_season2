//
//  ClassGroupViewController.m
//  cjzyb_ios
//
//  Created by david on 14-2-27.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "ClassGroupViewController.h"
#import "UserObjDaoInterface.h"
#import "ModelTypeViewController.h"
@interface ClassGroupViewController ()
@property (nonatomic,strong) UIView *footerBackView;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
-(IBAction)addMoreClasses;
@end

@implementation ClassGroupViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//TODO:加入更多班级
-(IBAction)addMoreClasses{
    __weak ClassGroupViewController *weakSelf = self;
    DataService *data = [DataService sharedService];
    
    [ModelTypeViewController presentTypeViewWithTipString:@"请输入班级验证码:" withFinishedInput:^(NSString *inputString) {
        AppDelegate *app = [AppDelegate shareIntance];

        if (inputString.length < 1 || inputString.length > 30) {
            [Utility errorAlert:@"班级号码长度不符!"];
            return ;
        }
        
        [MBProgressHUD showHUDAddedTo:app.window animated:YES];
        [UserObjDaoInterface joinNewGradeWithUserId:data.user.studentId withIdentifyCode:inputString withSuccess:^(UserObject *userObj, ClassObject *gradeObj) {
            ClassGroupViewController *tempSelf = weakSelf;
            if (tempSelf) {
                data.user = userObj;
                data.theClass = gradeObj;
                [data.theClass archiverClass];

                [MBProgressHUD hideHUDForView:app.window animated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:kChangeGradeNotification object:nil];
            }
        } withFailure:^(NSError *error) {
            ClassGroupViewController *tempSelf = weakSelf;
            if (tempSelf) {
                [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
                [MBProgressHUD hideHUDForView:app.window animated:YES];
            }
        }];
    } withCancel:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.classArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    DataService *data = [DataService sharedService];
    ClassObject *grade = [self.classArray objectAtIndex:indexPath.row];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    cell.textLabel.text = grade.name;
    if ([data.theClass.classId integerValue]==[grade.classId integerValue]) {
        UIImageView *imgView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        imgView.image = [UIImage imageNamed:@"point"];
        cell.accessoryView = imgView;
    }else{
        cell.accessoryView = nil;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataService *data = [DataService sharedService];
    ClassObject *grade = [self.classArray objectAtIndex:indexPath.row];
    if ([data.theClass.classId integerValue]==[grade.classId integerValue]) {
        return;
    }
    //TODO:切换班级
    __weak ClassGroupViewController *weakSelf = self;
    AppDelegate *app = [AppDelegate shareIntance];
    [MBProgressHUD showHUDAddedTo:app.window animated:YES];
    [UserObjDaoInterface exchangeGradeWithUserId:data.user.studentId withGradeId:grade.classId withSuccess:^(UserObject *userObj, ClassObject *gradeObj) {
        ClassGroupViewController *tempSelf = weakSelf;
        if (tempSelf) {
            data.user = userObj;
            data.theClass = gradeObj;
            [data.theClass archiverClass];
            
            [MBProgressHUD hideHUDForView:app.window animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeGradeNotification object:nil];
        }
    } withFailure:^(NSError *error) {
        ClassGroupViewController *tempSelf = weakSelf;
        if (tempSelf) {
            [Utility errorAlert:[error.userInfo objectForKey:@"msg"]];
            [MBProgressHUD hideHUDForView:app.window animated:YES];
        }
    }];
    
}


#pragma mark property
-(NSMutableArray *)classArray{
    if (!_classArray) {
        _classArray = [NSMutableArray array];
    }
    return _classArray;
}
#pragma mark --
@end
