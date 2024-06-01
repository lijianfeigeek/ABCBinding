//
//  ABCBindingCocosEvalStirng.m
//  ABCBinding
//
//  Created by 李剑飞 on 2021/6/10.
//

#import "ABCBindingCocosEvalStirng.h"
#import <objc/runtime.h>

@implementation ABCBindingCocosEvalStirng

static NSString * cacheClassName = nil;

+ (NSString *)getProtocolClassName {
    if (cacheClassName) {
        return cacheClassName;
    }
    Protocol *protocol = objc_getProtocol("ABCBindingCocosEvalStringProtocol");
    // 必须register（只要有Class遵循这个Protocol，就算register）的Protocol才能通过objc_getProtocol找到
    if (protocol) {
        // 得到遵循这个协议的类
        int numberOfClasses = objc_getClassList(NULL, 0);
        Class *classList = (Class *)malloc(numberOfClasses * sizeof(Class));
        numberOfClasses = objc_getClassList(classList, numberOfClasses);
        for (int idx = 0; idx < numberOfClasses; idx++)
        {
            Class class = classList[idx];
            if (class_getClassMethod(class, @selector(conformsToProtocol:)) && [class conformsToProtocol:protocol])
            {
                cacheClassName = NSStringFromClass(class);
                break;//找到一个符合的类，退出
            }
        }
        free(classList);
    }else {
        // 执行断言
        NSCAssert(NO, @"请实现 ABCBindingCocosEvalStringProtocol 协议");
    }
    return cacheClassName;
}

@end
