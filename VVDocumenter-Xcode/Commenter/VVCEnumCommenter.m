//
//  VVCEnumCommenter.m
//  VVDocumenter-Xcode
//
//  Created by dhc on 16/1/8.
//  Copyright © 2016年 OneV's Den. All rights reserved.
//

#import "VVCEnumCommenter.h"

#import "VVDocumenterSetting.h"

@implementation VVCEnumCommenter

- (NSString *)document {
    //Regular comment documentation
    NSString *finalString = [NSString stringWithFormat:@"%@%@%@", [self startComment],
                             [self sinceComment],
                             [self endComment]];
    
    if (![finalString hasSuffix:@"\n"]) {
        finalString = [finalString stringByAppendingString:@"\n"];
    }
    
    // Grab everything from the start of the line to the opening brace, which
    // may be on a different line.
    NSString *enumDefinePattern = @"^\\s*(typedef\\s+)?enum\\s*\\w*\\{";
    NSRegularExpression *enumDefineExpression = [NSRegularExpression regularExpressionWithPattern:enumDefinePattern options:0 error:nil];
    NSTextCheckingResult *enumDefineResult = [enumDefineExpression firstMatchInString:self.code options:0 range:NSMakeRange(0, self.code.length)];
    
    finalString = [finalString stringByAppendingString:[self.code substringWithRange:[enumDefineResult rangeAtIndex:0]]];
    finalString = [finalString substringToIndex:finalString.length - 1];
    finalString = [finalString stringByAppendingString:@" {\n"];
    
    NSString *endPattern = @"\\}\\s*\\w*\\s*;";
    NSRegularExpression *endPatternExpression = [NSRegularExpression regularExpressionWithPattern:endPattern options:0 error:nil];
    NSTextCheckingResult *endPatternResult = [endPatternExpression firstMatchInString:self.code options:0 range:NSMakeRange(0, self.code.length)];
    NSString *endString = [self.code substringWithRange:[endPatternResult rangeAtIndex:0]];
    
    NSString *enumPartsString = [[self.code vv_stringByReplacingRegexPattern:enumDefinePattern withString:@""]
                                 vv_stringByReplacingRegexPattern:endPattern        withString:@""];
    NSArray *enumParts = [enumPartsString componentsSeparatedByString:@","];
    NSMutableArray *enumArguments = [[NSMutableArray alloc] init];
    NSUInteger longestPartLength = 0;
    for (NSString *part in enumParts) {
        NSString *trimmedPart = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedPart.length != 0) {
            [enumArguments addObject:trimmedPart];
            longestPartLength = trimmedPart.length > longestPartLength ? trimmedPart.length : longestPartLength;
        }
    }
    longestPartLength += 1;
    
    if ([enumArguments count] > 0) {
        BOOL useSpace = [[VVDocumenterSetting defaultSetting] useSpaces];
        NSString *indentString = useSpace ? @" " : @"\t";
        NSString *startString = [[VVDocumenterSetting defaultSetting] useHeaderDoc] ? @"/*!" : @"/**";
        
        for (int i = 0; i < [enumArguments count]; i++) {
            NSString *part = [enumArguments objectAtIndex:i];
            NSString *trimmedPart = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmedPart.length == 0) {
                continue;
            }
            
            trimmedPart = [trimmedPart stringByAppendingString:@","];
            
            if ([[VVDocumenterSetting defaultSetting] alignArgumentComments]) {
                if (useSpace) {
                    trimmedPart = [trimmedPart stringByPaddingToLength:longestPartLength withString:@" " startingAtIndex:0];
                } else {
                    NSInteger tabSpaceRateCount = [[VVDocumenterSetting defaultSetting] spaceCount];
                    NSInteger neededTabCount = (longestPartLength + tabSpaceRateCount - trimmedPart.length) / tabSpaceRateCount - 1;
                    trimmedPart = [trimmedPart stringByPaddingToLength:(trimmedPart.length + neededTabCount) withString:@"\t" startingAtIndex:0];
                }
            }
            
            trimmedPart = [trimmedPart stringByAppendingFormat:@"%@%@ <#Description#> */\n", indentString, startString];
            
            finalString = [finalString stringByAppendingFormat:@"%@%@", indentString, trimmedPart];
        }
    }
    
    
    return [finalString stringByAppendingString:endString];
}

@end
