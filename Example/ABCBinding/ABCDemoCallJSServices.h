//
//  ABCDemoCallJSServices.h
//  ABCBinding_Example
//
//  Created by ezli on 2021/5/8.
//  Copyright © 2021 lijianfeigeek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABCBindingCocosEvalStringProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface ABCDemoCallJSServices : NSObject<ABCBindingCocosEvalStringProtocol>

+ (BOOL)callJavaScriptFunc:(NSString *)script;

@end

NS_ASSUME_NONNULL_END
