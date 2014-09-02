//
//  DRSentenceSpellMatch.m
//  cjzyb_ios
//
//  Created by david on 14-3-7.
//  Copyright (c) 2014年 david. All rights reserved.
//

#import "DRSentenceSpellMatch.h"
#import "SpellMatchObj.h"

@implementation DRSentenceSpellMatch
+(void)checkSentence:(NSString*)sentence withSpellMatchSentence:(NSString*)spellSentence andSpellMatchAttributeString:(void(^)(NSMutableAttributedString *spellAttriString,float matchScore,NSArray *errorWordArray,NSArray *rightWordArray))success orSpellMatchFailure:(void(^)(NSError *error))failure{
    
    if (!sentence || !spellSentence) {
        if (failure) {
            failure([NSError errorWithDomain:@"" code:10010 userInfo:@{@"msg": @"未检测到语句,请重新朗读"}]);
        }
        return;
    }
    NSString *senStr = [sentence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *spellStr = [spellSentence stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([senStr isEqualToString:@""] || [spellStr isEqualToString:@""]) {
        if (failure) {
            failure([NSError errorWithDomain:@"" code:10010 userInfo:@{@"msg": @"未检测到语句,请重新朗读"}]);
        }
        return;
    }
    
    if (!success) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [Utility shared].isOrg = NO;
        [Utility shared].orgArray  = [Utility handleTheString:senStr];  //原句
        [Utility shared].metaphoneArray = [Utility metaphoneArray:[Utility shared].orgArray];
        NSArray *spellMatchRangeArr = [DRSentenceSpellMatch spellMatchWord:spellStr];
        
        NSMutableAttributedString *spellAttribute = [[NSMutableAttributedString alloc] initWithString:senStr];
        [spellAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:35] range:NSMakeRange(0, spellAttribute.length)];
        
        //默认全部染红
        [spellAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.941 green:0.525 blue:0.161 alpha:1.000] range:NSMakeRange(0, spellAttribute.length)];
        //除字母之外全部染黑
        NSRange leftRange = NSMakeRange(0, spellAttribute.length);
        while (YES) {
            NSRange findRange = [senStr rangeOfCharacterFromSet:[[NSCharacterSet letterCharacterSet] invertedSet] options:NSLiteralSearch range:leftRange];
            if (findRange.length > 0) {  //找到目标
                if (findRange.location + findRange.length <= spellAttribute.length) {
                    [spellAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:findRange];
                }
                leftRange = NSMakeRange(findRange.length + findRange.location, spellAttribute.length - (findRange.length + findRange.location));
            }else{
                break;
            }
        }
        int unMatch = 0;
        int matched = 0;
        NSMutableArray *errorWordArr = [NSMutableArray array];
        NSMutableArray *rightWordArr = [NSMutableArray array];
        for (SpellMatchObj *obj in spellMatchRangeArr) {
            if (obj.range.location + obj.range.length > spellAttribute.length) {
                continue;
            }
            if (obj.spellLevel == 1 || obj.spellLevel == 0.5) {
                matched ++;
                [rightWordArr addObject:[senStr substringWithRange:obj.range]];
                [spellAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:53/255.0 green:207/255.0 blue:143/255.0 alpha:1] range:obj.range];
            }else{
                unMatch++;
                [errorWordArr addObject:[senStr substringWithRange:obj.range]];
                [spellAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.941 green:0.525 blue:0.161 alpha:1.000] range:obj.range];
            }
        }
        float score = (float)matched/(float)[Utility shared].orgArray.count;
        dispatch_async(dispatch_get_main_queue(), ^{
            success(spellAttribute,score,errorWordArr.count>0 ?errorWordArr:nil,rightWordArr);
        });
    });
}


///把读出的string拆分成metaphone数组,并与单例中的原句数组作比较
+(NSArray*)spellMatchWord:(NSString*)spellString{
    NSMutableArray *spellsArr = [NSMutableArray array];
    [Utility shared].isOrg = YES;
    NSString *text = spellString;
    text =   [text stringByReplacingOccurrencesOfString:@"[_]|[\n]+|[ ]{2,}" withString:@" " options:NSRegularExpressionSearch  range:NSMakeRange(0, text.length)];
    NSArray *array = [Utility handleTheString:text];
    NSArray *array2 = [Utility metaphoneArray:array];
    [Utility shared].sureArray = [[NSMutableArray alloc]init];
    [Utility shared].correctArray = [[NSMutableArray alloc]init];
    [Utility shared].noticeArray = [[NSMutableArray alloc]init];
    [Utility shared].greenArray = [[NSMutableArray alloc]init];
    [Utility shared].yellowArray = [[NSMutableArray alloc]init];
    [Utility shared].spaceLineArray = [[NSMutableArray alloc]init];
    [Utility shared].wrongArray = [[NSMutableArray alloc]init];
    [Utility shared].firstpoint = 0;
    NSDictionary *dic = [Utility compareWithArray:[Utility shared].orgArray andArray:[Utility shared].metaphoneArray WithArray:array andArray:array2  WithRange:[Utility shared].rangeArray];
    
    NSMutableArray *unUsedIndexOfOriginRangeArray = [NSMutableArray array];   //原range array中未被匹配的对象编号,每匹配一个项,就删除一个index
    for (int i = 0; i < [Utility shared].rangeArray.count; i ++) {
        [unUsedIndexOfOriginRangeArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    NSMutableArray *range_array = [[NSMutableArray alloc]init];  //原句中非单词的range array (有序)
    for (int i=0; i<[Utility shared].orgArray.count; i++) {
        NSString *string = [[Utility shared].orgArray objectAtIndex:i];
        NSString *string2 = [string stringByTrimmingCharactersInSet: [NSCharacterSet decimalDigitCharacterSet]];
        if ([string2 stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]].length >0) {
            
        }else{
            [range_array addObject:[[Utility shared].rangeArray objectAtIndex:i]];
            [unUsedIndexOfOriginRangeArray removeObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    //notice
//    if (![[dic objectForKey:@"notice"] isKindOfClass:[NSNull class]] && [dic objectForKey:@"notice"] != nil) {
 //       NSMutableArray *notice_array = [dic objectForKey:@"notice"];
 //       for (id obj in notice_array){
  //          NSTextCheckingResult *rst = (NSTextCheckingResult *)obj;
 //           NSRange range = [rst rangeAtIndex:0];
//        }
  //  }
    
    //绿色
    if (![[dic objectForKey:@"green"]isKindOfClass:[NSNull class]] && [dic objectForKey:@"green"]!=nil) {
        NSMutableArray *green_array = [NSMutableArray arrayWithArray:[dic objectForKey:@"green"]];
        [green_array addObjectsFromArray:range_array];  //非单词的物体全部算green

        for (int i=0; i<green_array.count; i++) {
            SpellMatchObj *spell = [[SpellMatchObj alloc] init];
            NSTextCheckingResult *math = (NSTextCheckingResult *)[green_array objectAtIndex:i];
            NSRange range = [math rangeAtIndex:0];
            spell.range = range;
            spell.color = [UIColor colorWithRed:53/255.0 green:207/255.0 blue:143/255.0 alpha:1];
            spell.spellLevel = 1;
            [spellsArr addObject:spell];
            
            //对green项 去除未匹配编号
            for (int j = 0; j < [Utility shared].rangeArray.count; j ++) {
                NSTextCheckingResult *resultInArray = [Utility shared].rangeArray[j];
                NSRange rangeInArray = [resultInArray rangeAtIndex:0];
                if (rangeInArray.length == range.length && rangeInArray.location == range.location) {
                    [unUsedIndexOfOriginRangeArray removeObject:[NSString stringWithFormat:@"%d",j]];
                }
            }
        }
    }
    //黄色
    if (![[dic objectForKey:@"yellow"]isKindOfClass:[NSNull class]] && [dic objectForKey:@"yellow"]!=nil) {
        NSMutableArray *yellow_array = [dic objectForKey:@"yellow"];
        for (int i=0; i<yellow_array.count; i++) {
            SpellMatchObj *spell = [[SpellMatchObj alloc] init];
            NSTextCheckingResult *math = (NSTextCheckingResult *)[yellow_array objectAtIndex:i];
            NSRange range = [math rangeAtIndex:0];
            spell.range = range;
            spell.color = [UIColor yellowColor];
            spell.spellLevel = 0.5;
            [spellsArr addObject:spell];
            
            //对yellow项 去除未匹配编号
            for (int j = 0; j < [Utility shared].rangeArray.count; j ++) {
                NSTextCheckingResult *resultInArray = [Utility shared].rangeArray[j];
                NSRange rangeInArray = [resultInArray rangeAtIndex:0];
                if (rangeInArray.length == range.length && rangeInArray.location == range.location) {
                    [unUsedIndexOfOriginRangeArray removeObject:[NSString stringWithFormat:@"%d",j]];
                }
            }
        }
    }
    //错误
    if (![[dic objectForKey:@"wrong"]isKindOfClass:[NSNull class]] && [dic objectForKey:@"wrong"]!=nil) {
        NSMutableArray *wrong_array = [NSMutableArray arrayWithArray:[dic objectForKey:@"wrong"]];
        for (int i=0; i<wrong_array.count; i++) {
            NSTextCheckingResult *math = (NSTextCheckingResult *)[wrong_array objectAtIndex:i];
            NSRange range = [math rangeAtIndex:0];
            
            if (range_array.count>0) {
                for (NSTextCheckingResult *math2 in range_array){
                    NSRange range2 = [math2 rangeAtIndex:0];
                    if (range.location==range2.location && range.length==range2.length) {
                        
                    }else {
                        SpellMatchObj *spell = [[SpellMatchObj alloc] init];
                        spell.range = range;
                        spell.spellLevel = 0;
                        spell.color = [UIColor colorWithRed:0/255.0 green:5/255.0 blue:28/255.0 alpha:1];
                        [spellsArr addObject:spell];
                    }
                }
            }else {
                SpellMatchObj *spell = [[SpellMatchObj alloc] init];
                spell.range = range;
                spell.spellLevel = 0;
                spell.color = [UIColor colorWithRed:0/255.0 green:5/255.0 blue:28/255.0 alpha:1];
                [spellsArr addObject:spell];
            }
        }
    }
    
    //使用未匹配项补充spellArr
    for (int i = 0; i < unUsedIndexOfOriginRangeArray.count; i ++) {
        NSString *indexString = unUsedIndexOfOriginRangeArray[i];
        NSTextCheckingResult *unUsed = [[Utility shared].rangeArray objectAtIndex:indexString.intValue];
        NSRange unUsedRange = [unUsed rangeAtIndex:0];
        BOOL shouldUse = YES;
        for (SpellMatchObj *obj in spellsArr){
            if (obj.range.length == unUsedRange.length && obj.range.location == unUsedRange.location) {
                shouldUse = NO;
            }
        }
        if (shouldUse) {
            SpellMatchObj *spell = [[SpellMatchObj alloc] init];
            spell.range = unUsedRange;
            spell.spellLevel = 0;
            spell.color = [UIColor colorWithRed:0/255.0 green:5/255.0 blue:28/255.0 alpha:1];
            [spellsArr addObject:spell];
        }
    }
    
    [spellsArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        SpellMatchObj *s1 = obj1;
        SpellMatchObj *s2 = obj2;
        if (s1.range.location > s2.range.location) {
            return NSOrderedDescending;
        }else
            if (s1.range.location < s2.range.location) {
                return NSOrderedAscending;
            }else{
                return NSOrderedSame;
            }
    }];
    return spellsArr;
}

@end
