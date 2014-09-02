
//
//  NewLogInterface.m
//  cjzyb_ios
//
//  Created by comdosoft on 14-5-27.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "NewLogInterface.h"
#import "NSDictionary+AllKeytoLowerCase.h"
#import "NSString+URLEncoding.h"
#import "NSString+HTML.h"

@implementation NewLogInterface
-(void)getNewLogInterfaceDelegateWithName:(NSString *)name password:(NSString *)pwd
{
    NSMutableDictionary *reqheaders = [[NSMutableDictionary alloc] init];
    
    AppDelegate *appDel = [AppDelegate shareIntance];
    
    [reqheaders setValue:[NSString stringWithFormat:@"%@",name] forKey:@"email"];
    [reqheaders setValue:[NSString stringWithFormat:@"%@",pwd] forKey:@"password"];
    [reqheaders setValue:[NSString stringWithFormat:@"%@",appDel.pushstr] forKey:@"token"];
    
    self.interfaceUrl =@"http://new.cjzyb.com/api/students/login_for_ipad";
    
    self.baseDelegate = self;
    self.headers = reqheaders;
    
    [self connectWithMethod:@"POST"];
}

#pragma mark - BaseInterfaceDelegate
-(void)parseResult:(ASIHTTPRequest *)request{
    NSData *data = [[NSData alloc]initWithData:[request responseData]];
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject !=nil) {
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonData=(NSDictionary *)jsonObject;
            if (jsonData) {
                [self.delegate getNewLogInfoDidFinished:jsonData];
            }else {
                [self.delegate getNewLogInfoDidFailed:@"登录失败!"];
            }
        }
    }
}
-(void)requestIsFailed:(NSError *)error{
    [self.delegate getNewLogInfoDidFailed:@"请求失败!"];
}

@end
