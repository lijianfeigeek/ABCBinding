//
//  ABCTransferData.m
//  demo_attribute
//
//  Created by ezli on 2021/4/27.
//

#import "ABCBindingCallBack.h"
#import "ABCBinding.h"
#import "ABCBindingCocosEvalStirng.h"

typedef NS_ENUM(NSInteger, ABCBINGDING_STATUS)
{
    ABCBINGDING_STATUS_ERROR    = -1,   //失败
    ABCBINGDING_STATUS_SUCCESS  = 0     //成功
};

@interface ABCBindingCallBackBase ()
@property(nonatomic,strong) NSString*JSCallBack;
@property(nonatomic,strong) NSString*JSCallBack_Progrss;
@end

@implementation ABCBindingCallBackBase
- (void)setJSCallBackName:(NSString*)name {
    self.JSCallBack = name;
    self.JSCallBack_Progrss = [NSString stringWithFormat:@"%@_p",name];
}
@end

@interface ABCBindingCallBack ()
@property(nonatomic,strong,readwrite) onSuccess   onSuccess;
@property(nonatomic,strong,readwrite) onProgress  onProgress;
@property(nonatomic,strong,readwrite) onFailure   onFailure;
@end

@implementation ABCBindingCallBack

-(instancetype)init{
    self = [super init];
    if (self) {
        [self actionCallback];
    }
    return self;
}

- (void)actionCallback {
    __weak __typeof(self)weakSelf = self;
    Class<ABCBindingCocosEvalStringProtocol> cls = NSClassFromString([ABCBindingCocosEvalStirng getProtocolClassName]);
    self.onSuccess = ^(NSDictionary * _Nonnull success) {
        NSString *jsonParam = [ABCBindingUtil jsonStringWithDict:@{
            @"code":@(ABCBINGDING_STATUS_SUCCESS),
            @"data":success
        }];
        NSString *jsFunc = [NSString stringWithFormat:@"window && window.%@ && window.%@(%@);",weakSelf.JSCallBack,weakSelf.JSCallBack,jsonParam];
        dispatch_main_async_safe(^{
            [cls callJavaScriptFunc:jsFunc];
        });
    };
    
    self.onProgress = ^(NSDictionary * _Nonnull progress) {
        NSString *jsonParam = [ABCBindingUtil jsonStringWithDict:@{
            @"code":@(ABCBINGDING_STATUS_SUCCESS),
            @"data":progress
         }];
        NSString *jsFunc = [NSString stringWithFormat:@"window && window.%@ && window.%@(%@);",weakSelf.JSCallBack_Progrss,weakSelf.JSCallBack_Progrss,jsonParam];
        dispatch_main_async_safe(^{
            [cls callJavaScriptFunc:jsFunc];
        });
    };
    
    self.onFailure = ^(NSInteger errorCode,NSString *msg) {
        NSString *jsonParam = [ABCBindingUtil jsonStringWithDict:@{
            @"code":@(ABCBINGDING_STATUS_ERROR),
            @"eCode":@(errorCode),
            @"msg":msg
         }];
        NSString *jsFunc = [NSString stringWithFormat:@"window && window.%@ && window.%@(%@);",weakSelf.JSCallBack,weakSelf.JSCallBack,jsonParam];
        dispatch_main_async_safe(^{
            [cls callJavaScriptFunc:jsFunc];
        });
    };
}


@end
