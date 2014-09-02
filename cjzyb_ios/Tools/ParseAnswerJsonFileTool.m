//
//  ParseAnswerJsonFileTool.m
//  cjzyb_ios
//
//  Created by david on 14-3-24.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "ParseAnswerJsonFileTool.h"
#import "ParseQuestionJsonFileTool.h"
@implementation ParseAnswerJsonFileTool
//TODO:使用的道具写入json文件
+(void)writePropsToJsonFile:(NSString*)jsonFilePath withQuestionId:(NSString*)questionId withPropsType:(NSString*)proposType withSuccess:(void (^)())success withFailure:(void (^)(NSError *error))failure{
    if (!questionId || !proposType || !jsonFilePath) {
        if (failure) {
            failure([NSError errorWithDomain:@"" code:2001 userInfo:@{@"msg": @"要保存的题目数据错误"}]);
        }
        return;
    }
    NSString *dircName = [jsonFilePath stringByDeletingLastPathComponent];
    dircName = [dircName lastPathComponent];
    NSMutableArray *propsArray = [Utility returnAnswerPropsandDate:dircName];
    //存储道具记录JSON
    if ([proposType isEqualToString:@"0"]) {
        NSMutableDictionary *timePropDic = [NSMutableDictionary dictionaryWithDictionary:[propsArray firstObject]];
        NSMutableArray *branchOfPropArray = [NSMutableArray arrayWithArray:[timePropDic objectForKey:@"branch_id"]];
        [branchOfPropArray addObject:[NSNumber numberWithInteger:questionId.integerValue]];
        [timePropDic setObject:branchOfPropArray forKey:@"branch_id"];
        [propsArray replaceObjectAtIndex:0 withObject:timePropDic];
        [Utility returnAnswerPathWithProps:propsArray andDate:dircName];
    }else{
        NSMutableDictionary *timePropDic = [NSMutableDictionary dictionaryWithDictionary:[propsArray lastObject]];
        NSMutableArray *branchOfPropArray = [NSMutableArray arrayWithArray:[timePropDic objectForKey:@"branch_id"]];
        [branchOfPropArray addObject:[NSNumber numberWithInteger:questionId.integerValue]];
        [timePropDic setObject:branchOfPropArray forKey:@"branch_id"];
        [propsArray replaceObjectAtIndex:1 withObject:timePropDic];
        [Utility returnAnswerPathWithProps:propsArray andDate:dircName];
    }
    if (success) {
        success();
    }
}

//TODO: 根据答案的json文件解析出朗读类型的做题记录
+(void)parseAnswerJsonFileWithUserId:(NSString*)userId withTask:(TaskObj*)task withReadingHistoryArray:( void(^)(NSArray *readingQuestionArr,int currentQuestionIndex,int currentQuestionItemIndex,int status,NSString *updateTime,NSString *userTime,int specifyTime ,float ratio))questionArr withParseError:(void (^)(NSError *error))failure{
    
    //读取answer
    NSDictionary *answerDic = [Utility returnAnswerDictionaryWithName:@"reading" andDate:task.taskStartDate];
    int status = 0;
    NSString *updateTime;
    NSString *useTime;
    int questionIndex = 0;
    int questionItemIndex = 0;
    if (answerDic && answerDic.count > 0) {
        status = [Utility filterValue:[answerDic objectForKey:@"status"]].intValue;
        updateTime = [Utility filterValue:[answerDic objectForKey:@"update_time"]];
        useTime = [Utility filterValue:[answerDic objectForKey:@"use_time"]];
        questionIndex = [Utility filterValue:[answerDic objectForKey:@"questions_item"]].intValue;
        questionItemIndex = [Utility filterValue:[answerDic objectForKey:@"branch_item"]].intValue;
    }
    
    //读取问题
    __block int count = 0;
    __block float totalRatio = 0.0;
    NSString *filePath = [NSString stringWithFormat:@"%@/questions.json",task.taskFolderPath];
    [ParseQuestionJsonFileTool parseQuestionJsonFile:filePath withReadingQuestionArray:^(NSArray *readingQuestionArr, NSInteger specifiedTime) {
        NSArray *answerArr = [answerDic objectForKey:@"questions"];
        for (int index = 0; index < answerArr.count && index < readingQuestionArr.count; index++) {
            NSDictionary *questionDic = [answerArr objectAtIndex:index];
            NSArray *questionArr = [questionDic objectForKey:@"branch_questions"];
            ReadingHomeworkObj *reading = [readingQuestionArr objectAtIndex:index];
            for (int i = 0; i < reading.readingHomeworkSentenceObjArray.count && i < questionArr.count; i++) {
                NSDictionary *sentenceDic = [questionArr objectAtIndex:i];
                ReadingSentenceObj *sentence = [reading.readingHomeworkSentenceObjArray objectAtIndex:i];
                //李宏亮修改 ,从answerJSON中读取值
                int intRatio = ((NSString *)[Utility filterValue:[sentenceDic objectForKey:@"ratio"]]).intValue;
                float ratio = ((float)intRatio) / 100.0;
                sentence.readingSentenceRatio = [NSString stringWithFormat:@"%0.2f",ratio];
                
                sentence.readingErrorWordArray = [ParseAnswerJsonFileTool getErrorWordArrayFromString:[sentenceDic objectForKey:@"answer"]];
                count++;
                totalRatio += sentence.readingSentenceRatio.floatValue;
            }
        }
        
        if (questionArr) {
            float ratio = 1;
            if (count > 0) {
                ratio = totalRatio/count;
            }
            questionArr(readingQuestionArr,questionIndex,questionItemIndex,status,updateTime,useTime,specifiedTime,ratio);
        }
    } withParseError:^(NSError *error) {
        if (failure) {
            failure([NSError errorWithDomain:@"" code:2001 userInfo:@{@"msg": @"没有发现作业包"}]);
        }
    }];
}


//TODO:将已经完成的朗读题写入json文件
+(void)writeReadingHomeworkToJsonFile:(NSString*)jsonFilePath withUseTime:(NSString*)useTime withQuestionIndex:(int)questionIndex withQuestionItemIndex:(int)questionItemIndex withReadingHomworkArr:(NSArray*)readingHomeworkArray withSuccess:(void (^)())success withFailure:(void (^)(NSError *error))failure{
    if (!readingHomeworkArray || readingHomeworkArray.count <= 0 || !jsonFilePath) {
        if (failure) {
            failure([NSError errorWithDomain:@"" code:2001 userInfo:@{@"msg": @"传入参数有误"}]);
        }
        return;
    }
    NSString *dircName = [jsonFilePath stringByDeletingLastPathComponent];
    dircName = [dircName lastPathComponent];
    
    NSString *status = [ParseAnswerJsonFileTool getStatusWithReadingHomeworkArray:readingHomeworkArray];
    NSMutableDictionary *readingDic = [NSMutableDictionary dictionary];
    [readingDic setValue:status forKey:@"status"];
    [readingDic setValue:useTime?:@"" forKey:@"use_time"];
    [readingDic setValue:[NSString stringWithFormat:@"%d",questionIndex] forKey:@"questions_item"];
    [readingDic setValue:[NSString stringWithFormat:@"%d",questionItemIndex] forKey:@"branch_item"];
    [readingDic setValue:[Utility getNowDateFromatAnDate] forKey:@"update_time"];
    
    NSMutableArray *homeworkArr = [NSMutableArray array];
    for (ReadingHomeworkObj *reading in readingHomeworkArray) {
        NSMutableDictionary *homeworkDic = [NSMutableDictionary dictionary];
        [homeworkDic setValue:reading.readingHomeworkID forKey:@"id"];
        
        NSMutableArray *sentenceArr = [NSMutableArray array];
        for (ReadingSentenceObj *sentence in reading.readingHomeworkSentenceObjArray) {
            NSMutableDictionary *sentenceDic = [NSMutableDictionary dictionary];
            [sentenceDic setValue:sentence.readingSentenceID forKey:@"id"];
            [sentenceDic setValue:sentence.readingSentenceContent forKey:@"answerContent"];
            [sentenceDic setValue:[ParseAnswerJsonFileTool getErrorWordContentFromErrorArray:sentence.readingErrorWordArray] forKey:@"answer"];
            
            //李宏亮添加
            NSString *ratioString;
            if (sentence.readingSentenceRatio) {
                float ratio = sentence.readingSentenceRatio.floatValue;
                ratio = ratio <= 1.0 ? ratio * 100. : ratio;
                int intRatio = (int)ratio;
                ratioString = [NSString stringWithFormat:@"%d",intRatio];
            }
            
            [sentenceDic setValue:ratioString forKey:@"ratio"];
            [sentenceArr addObject:sentenceDic];
        }
        [homeworkDic setValue:sentenceArr forKey:@"branch_questions"];
        [homeworkArr addObject:homeworkDic];
    }
    [readingDic setValue:homeworkArr forKey:@"questions"];
    [Utility returnAnswerPathWithDictionary:readingDic andName:@"reading" andDate:dircName];
    if (success) {
        success();
    }
}

//TODO:将读错的单词拼接成字符串
+(NSString*)getErrorWordContentFromErrorArray:(NSArray*)array{
    if (!array || array.count < 1) {
        return @"";
    }
    return [array componentsJoinedByString:@";||;"];
//    NSMutableString *content = [[NSMutableString alloc] init];
//    for (NSString *sentence in array) {
//        [content appendFormat:@"%@;||;",sentence];
//    }
//    if (content.length <= 0) {
//        return @"";
//    }
//    return content;
}

//TODO:从字符串中获取
+(NSMutableArray*)getErrorWordArrayFromString:(NSString*)content{
    if (!content || [content isEqualToString:@""]) {
        return nil;
    }
    return [NSMutableArray arrayWithArray:[content componentsSeparatedByString:@";||;"]];
}

//TODO:判断当前作业是否做完
+(NSString*)getStatusWithReadingHomeworkArray:(NSArray*)homeworkArray{
    NSString *status = @"1";
    for (ReadingHomeworkObj *reading in homeworkArray) {
        if (!reading.isFinished) {
            status = @"0";
            break;
        }
        BOOL isBreak = NO;
        for (ReadingSentenceObj *sentence in reading.readingHomeworkSentenceObjArray) {
            if (!sentence.isFinished) {
                isBreak = YES;
                break;
            }
        }
        if (isBreak) {
            status = @"0";
            break;
        }
    }
    
    return status;
}
@end
