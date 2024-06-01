//
//  ABCDemoCallJSServices.m
//  ABCBinding_Example
//
//  Created by ezli on 2021/5/8.
//  Copyright © 2021 lijianfeigeek. All rights reserved.
//

#import "ABCDemoCallJSServices.h"

@implementation ABCDemoCallJSServices

+ (BOOL)callJavaScriptFunc:(NSString *)script{
    NSLog(@"%@",script);
    return YES;
}

@end
