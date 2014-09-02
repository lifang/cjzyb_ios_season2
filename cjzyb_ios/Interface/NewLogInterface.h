//
//  NewLogInterface.h
//  cjzyb_ios
//
//  Created by comdosoft on 14-5-27.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "BaseInterface.h"

@protocol NewLogInterfaceDelegate;
@interface NewLogInterface : BaseInterface<BaseInterfaceDelegate>

@property (nonatomic, assign) id <NewLogInterfaceDelegate> delegate;

-(void)getNewLogInterfaceDelegateWithName:(NSString *)name password:(NSString *)pwd;
@end

@protocol NewLogInterfaceDelegate <NSObject>

-(void)getNewLogInfoDidFinished:(NSDictionary *)result;
-(void)getNewLogInfoDidFailed:(NSString *)errorMsg;

@end
