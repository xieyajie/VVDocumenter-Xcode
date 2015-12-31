//
//  DXHeaderCommenter.m
//  VVDocumenter-Xcode
//
//  Created by dhc on 15/12/31.
//  Copyright © 2015年 OneV's Den. All rights reserved.
//

#import "DXHeaderCommenter.h"

@implementation DXHeaderCommenter

-(NSString *) document
{
    NSString *string = @"/*!\n  @header <#filename#>\t\n  @abstract  <#Description#>\t\n  @author  <#author#>\t\n  @version  <#version number#>\t\n*/\n";
    
    return string;
}

@end
