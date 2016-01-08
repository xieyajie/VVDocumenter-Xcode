//
//  VVDocumenter.m
//  VVDocumenter-Xcode
//
//  Created by 王 巍 on 13-7-17.
//
//  Copyright (c) 2015 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "VVDocumenter.h"
#import "NSString+VVSyntax.h"
#import "VVCommenter.h"

@interface VVDocumenter()

@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) BOOL isCEnum;
@property (nonatomic, assign) BOOL isObjCEnum;
@property (nonatomic, assign) BOOL isSwiftEnum;
@property (nonatomic, assign) BOOL isHeader;

@end

@implementation VVDocumenter

-(instancetype) initWithCode:(NSString *)code
{
    self = [super init];
    if (self) {
        _isHeader = NO;
        
        NSString *trimmed = [[code vv_stringByReplacingRegexPattern:@"\\s*(\\(.*\?\\))\\s*" withString:@"$1"]
                             vv_stringByReplacingRegexPattern:@"\\s*\n\\s*"           withString:@" "];
        _isSwiftEnum = [trimmed vv_isSwiftEnum];
        if (!_isSwiftEnum) {
            _isObjCEnum = [trimmed vv_isObjCEnum];
            if (!_isObjCEnum) {
                _isCEnum = [trimmed vv_isCEnum];
            }
        }
        
        if (_isObjCEnum || _isSwiftEnum) {
            _code = code;
        } else {
            //Trim the space around the braces
            //Then trim the new line character
            _code = trimmed;
        }
    }
    return self;
}

- (instancetype) initHeader
{
    self = [super init];
    if (self) {
        _isHeader = YES;
        _isCEnum = NO;
        _isObjCEnum = NO;
        _isSwiftEnum = NO;
        _code = nil;
    }
    
    return self;
}

-(NSString *) baseIndentation
{
    NSArray *matchedSpaces = [self.code vv_stringsByExtractingGroupsUsingRegexPattern:@"^(\\s*)"];
    if (matchedSpaces.count > 0) {
        return matchedSpaces[0];
    } else {
        return @"";
    }
}

-(NSString *) document
{
    NSString *trimCode = [self.code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *baseIndent = [self baseIndentation];
    
    VVBaseCommenter *commenter = nil;
    
    if (self.isHeader) {
        commenter = [[DXHeaderCommenter alloc] initWithIndentString:baseIndent codeString:nil];
    } else if (self.isObjCEnum) {
        commenter = [[VVObjCEnumCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if (self.isSwiftEnum) {
        commenter = [[VVSwiftEnumCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isProperty]) {
        commenter = [[VVPropertyCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isCFunction]) {
        commenter = [[VVFunctionCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isMacro]) {
        commenter = [[VVMacroCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isStruct]) {
        commenter = [[VVStructCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isUnion]) {
        commenter = [[VVStructCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isObjCMethod]) {
        commenter = [[VVMethodCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isSwiftFunction]) {
        commenter = [[VVSwiftFunctionCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isSwiftProperty]) {
        commenter = [[VVSwiftPropertyCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else if ([trimCode vv_isSwiftExtension]) {
        commenter = [[VVSwiftExtensionCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    } else {
        commenter = [[VVVariableCommenter alloc] initWithIndentString:baseIndent codeString:trimCode];
    }

    if ([commenter shouldComment]) {
        return [commenter document];
    } else {
        return nil;
    }
}



@end
