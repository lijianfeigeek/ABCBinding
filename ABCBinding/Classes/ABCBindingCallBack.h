//
//  ABCTransferData.h
//  demo_attribute
//
//  Created by ezli on 2021/4/27.
//

#import <Foundation/Foundation.h>

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

NS_ASSUME_NONNULL_BEGIN
typedef void(^onSuccess)(NSDictionary *success);
typedef void(^onProgress)(NSDictionary *progress);
typedef void(^onFailure)(NSInteger errorCode,NSString *msg);

// ABCBinding内部调用
@interface ABCBindingCallBackBase : NSObject
- (void)setJSCallBackName:(NSString*)name;
@end

// 业务调用
@interface ABCBindingCallBack : ABCBindingCallBackBase
@property(nonatomic,strong,readonly)onSuccess   onSuccess;
@property(nonatomic,strong,readonly)onProgress  onProgress;
@property(nonatomic,strong,readonly)onFailure   onFailure;
@end
NS_ASSUME_NONNULL_END
