//
//  DXHeaderCommenter.m
//  VVDocumenter-Xcode
//
//  Created by dhc on 15/12/31.
//  Copyright © 2015年 OneV's Den. All rights reserved.
//

#import "DXHeaderCommenter.h"

#import "VVArgument.h"
#import "VVDocumenterSetting.h"

@implementation DXHeaderCommenter

#pragma mark - super

-(NSString *) startComment
{
    return @"/*!\t";
}

-(NSString *) argumentsComment
{
    if (self.arguments.count == 0)
        return @"";
    
    // start off with an empty line
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"\n"];
    
    int longestNameLength = [[self.arguments valueForKeyPath:@"@max.name.length"] intValue];
    BOOL useSpace = [[VVDocumenterSetting defaultSetting] useSpaces];
    
    for (VVArgument *arg in self.arguments) {
        NSString *name = arg.name;
        
        if ([[VVDocumenterSetting defaultSetting] alignArgumentComments]) {
            if (useSpace) {
                name = [name stringByPaddingToLength:longestNameLength withString:@" " startingAtIndex:0];
            } else {
                NSInteger tabSpaceRateCount = [[VVDocumenterSetting defaultSetting] spaceCount];
                NSInteger neededTabCount = (longestNameLength + tabSpaceRateCount - name.length) / tabSpaceRateCount - 1;
                name = [name stringByPaddingToLength:(name.length + neededTabCount) withString:@"\t" startingAtIndex:0];
            }
        }
        
        NSString *indentString = useSpace ? @" " : @"\t";
        [result appendFormat:@"%@@%@%@<#%@ description#>\n", self.prefixString, name, indentString, arg.name];
        
    }
    return result;
}

-(NSString *) document
{
    [self argumentsForHeaderDoc];
    //    NSString *string = @"/*!\n  @header <#filename#>\t\n  @abstract  <#Description#>\t\n  @author  <#author#>\t\n  @version  <#version number#>\t\n*/\n";
    
    return [super documentForC];
}

#pragma mark - private
- (void)argumentsForHeaderDoc
{
    NSArray *names = @[@"header", @"abstract", @"author", @"version"];
    for (int i = 0; i < (int)names.count; i++) {
        VVArgument *arg = [[VVArgument alloc] init];
        arg.name = [names objectAtIndex:i];
        [self.arguments addObject:arg];
    }
}

@end
