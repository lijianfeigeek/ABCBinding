//
//  ABCBinding.h
//  ABCBinding
//
//  Created by ezli on 2021/5/13.
//

#import <Foundation/Foundation.h>
#import "ABCBindingCallBack.h"
#import "ABCBindingUtil.h"
#import "ABCBindingCocosEvalStringProtocol.h"

struct ABCBinding_Function {
    void (* _Nonnull function)(void);
};

#define JSFunc_name(JSFunc) NSClassFromString(@#JSFunc)

#define ABCBinding(JSFunc)\
protocol ABCBinding##JSFunc##Protocol <NSObject> \
@required\
+ (void)JSFunc:(NSDictionary*)JSParam Callback:(ABCBindingCallBack*)callback;\
@end\
@interface ABCBinding##JSFunc : NSObject<ABCBinding##JSFunc##Protocol> @end\
@implementation ABCBinding##JSFunc\
- (void)dealloc{}\
static void _ABCBinding##JSFunc##load(void); \
__attribute__((used, section("__DATA,__ABCBinding"))) \
static const struct ABCBinding_Function __FABCBinding##JSFunc = (struct ABCBinding_Function){(void *)(&_ABCBinding##JSFunc##load)}; \
static void _ABCBinding##JSFunc##load(){ \
    dispatch_barrier_async(ABCBinding.moduleClassesSyncQueue, ^{\
        [ABCBinding.moduleClasses setObject:NSStringFromClass(JSFunc_name(ABCBinding##JSFunc)) forKey:NSStringFromSelector(@selector(JSFunc:Callback:))];\
    });\
}

typedef void(^JSCallBack)(NSDictionary * _Nullable JSCallBackParam);

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
@interface ABCBinding : NSObject

@property(class,nonatomic,strong,readonly)NSMutableDictionary <NSString*,NSString*> *moduleClasses;
@property(class,nonatomic,strong,readonly)dispatch_queue_t moduleClassesSyncQueue;
@property(class,nonatomic,strong,readonly)NSMutableDictionary <NSString*,JSCallBack> *cacheJSCallBack;

/// Cocos 接口
/// @param methodName 方法名
/// @param args JS JSON String 参数
/// @param callback JS 函数回调名称
+ (NSNumber*)executeWithMethodName:(NSString*)methodName
                            args:(NSString*)args
                        callback:(NSString *)callback;





/// native 接口
/// @param JSFunctionName JS 函数名称
/// @param param 调用 JS 传递的参数
/// @param JSCallBack JS 函数回调
+ (void)callJSFunctionName:(NSString*)JSFunctionName
                     Parma:(NSDictionary *)param
                JSCallBack:(JSCallBack)JSCallBack;
@end

NS_ASSUME_NONNULL_END
