//
//  TaskObj.m
//  cjzyb_ios
//
//  Created by david on 14-3-1.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "TaskObj.h"

@implementation TaskObj

+(TaskObj *)taskFromDictionary:(NSDictionary *)aDic {
    TaskObj *task = [[TaskObj alloc]init];
    
    [task setTaskID:[NSString stringWithFormat:@"%@",[aDic objectForKey:@"id"]]];
    [task setTaskName:[NSString stringWithFormat:@"%@",[aDic objectForKey:@"name"]]];
    [task setTaskStartDate:[NSString stringWithFormat:@"%@",[aDic objectForKey:@"start_time"]]];
    [task setTaskEndDate:[NSString stringWithFormat:@"%@",[aDic objectForKey:@"end_time"]]];
    [task setTaskFileDownloadURL:[NSString stringWithFormat:@"%@",[aDic objectForKey:@"question_packages_url"]]];
    [task setFinish_types:[NSMutableArray arrayWithArray:[aDic objectForKey:@"finish_types"]]];
    
    if (![[aDic objectForKey:@"answer_url"] isKindOfClass:[NSNull class]] && [aDic objectForKey:@"answer_url"]!=nil) {
        [task setTaskAnswerFileDownloadURL:[NSString stringWithFormat:@"%@",[aDic objectForKey:@"answer_url"]]];
    }
    [task setTaskAnswerFileUpdateDate:[NSString stringWithFormat:@"%@",[aDic objectForKey:@"updated_at"]]];
    if (task.taskStartDate.length > 0) {
        [task setTaskFolderPath:[[Utility returnPath] stringByAppendingPathComponent:[aDic objectForKey:@"start_time"]]];
    }
    return task;
}


@end
