//
//  ABCBindingCocosEvalStringProtocol.h
//  demo_attribute
//
//  Created by ezli on 2021/5/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ABCBindingCocosEvalStringProtocol <NSObject>

/// 避免 ABCBinding 与 cocos 混合
/// 业务实现 cocos 提供的 evalString 方法
/// 返回值 YES:调用成功 NO:调用失败 ⚠️ 业务这里自行处理日志
/// @param script js string
@required
+ (BOOL)callJavaScriptFunc:(NSString *)script;

/**
 like this
 + (BOOL)callJavaScriptFunc:(NSString *)script {
     if (script == nil) {
         // log
         return NO;
     }
     string scriptC = [script UTF8String];
     if (![NSThread isMainThread]) {
         __block bool ret = false;
         dispatch_sync(dispatch_get_main_queue(), ^{
             se::ScriptEngine *scriptEngine = se::ScriptEngine::getInstance();
             if (scriptEngine->isValid()) {
                 ret = scriptEngine->evalString(scriptC.c_str());
             }
         });

         if (ret == false) {
            // log
         }

         return ret;
     } else {
         se::ScriptEngine *scriptEngine = se::ScriptEngine::getInstance();
         bool ret = false;
         if (scriptEngine->isValid()) {
             ret = scriptEngine->evalString(scriptC.c_str());
         }
         if (ret == false) {
            // log
         }
         return ret;
     }
 }
 
 */

@end

NS_ASSUME_NONNULL_END
