//
//  ABCBinding.m
//  ABCBinding
//
//  Created by ezli on 2021/5/13.
//

#import "ABCBinding.h"
#import "ABCBindingCocosEvalStirng.h"

#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>

#ifdef __LP64__
typedef uint64_t ABCBindingExportValue;
typedef struct section_64 ABCBindingExportSection;
#define ABCBindingGetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t ABCBindingExportValue;
typedef struct section ABCBindingExportSection;
#define ABCBindingGetSectByNameFromHeader getsectbynamefromheader
#endif

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)

#define ABCSignsJSCallBack @"@"

typedef NS_ENUM(NSInteger, EXECUTE_RESULT)
{
    EXECUTE_RESULT_ERROR_CODE_PARAMS_ERROR = -2, // //参数转换失败
    EXECUTE_RESULT_ERROR_CODE_METHOD_NOT_DEFINED = -1, //没有定义此方法
    EXECUTE_RESULT_SUCCESS = 0,
};

@interface ABCBindingLaunchModel : NSObject
@property (nonatomic, assign) IMP imp;
@end

@implementation ABCBindingLaunchModel
@end

@implementation ABCBinding
static NSMutableArray<ABCBindingLaunchModel *> * modulesInDyld() {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
    NSString *fullAppName = [NSString stringWithFormat:@"/%@.app/", appName];
    char *fullAppNameC = (char *)[fullAppName UTF8String];
    
    NSMutableArray<ABCBindingLaunchModel *> * result = [[NSMutableArray alloc] init];

    int num = _dyld_image_count();
    for (int i = 0; i < num; i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, fullAppNameC) == NULL) {
            continue;
        }
        
        #if __LP64__
        const struct mach_header_64 *header = (struct mach_header_64 *)_dyld_get_image_header(i);
        #else
        const struct mach_header *header = _dyld_get_image_header(i);
        #endif
        
        //        printf("%d name: %s\n", i, name);
        Dl_info info;
        dladdr(header, &info);
        
        const ABCBindingExportValue dliFbase = (ABCBindingExportValue)info.dli_fbase;
        const ABCBindingExportSection *section = ABCBindingGetSectByNameFromHeader(header, "__DATA", "__ABCBinding");
        if (section == NULL) continue;
        int addrOffset = sizeof(struct ABCBinding_Function);
        for (ABCBindingExportValue addr = section->offset;
             addr < section->offset + section->size;
             addr += addrOffset)
        {
            
            struct ABCBinding_Function entry = *(struct ABCBinding_Function *)(dliFbase + addr);
            ABCBindingLaunchModel *model = [[ABCBindingLaunchModel alloc] init];
            model.imp = entry.function;
            [result addObject:model];
        }
    }
    return result;
}

__attribute__((constructor))
void premain() {
    NSMutableArray<ABCBindingLaunchModel *> *arrayModule = modulesInDyld();
    for (ABCBindingLaunchModel *item in arrayModule) {
        IMP imp = item.imp;
        void (*func)(void) = (void *)imp;
        func();
    }
}
#pragma mark - 类属性
static NSMutableDictionary <NSString*,NSString*> *_moduleClasses;
static dispatch_queue_t _moduleClassesSyncQueue;
static NSMutableDictionary <NSString*,JSCallBack> * _cacheJSCallBack;

+ (void)setCacheJSBack:(NSMutableDictionary <NSString*,JSCallBack> *)cacheJSCallBack {
    _cacheJSCallBack = cacheJSCallBack;
}

+ (NSMutableDictionary <NSString*,JSCallBack> *)cacheJSCallBack {
    if (!_cacheJSCallBack) {
        [self setCacheJSBack:[[NSMutableDictionary alloc]init]];
    }
    return _cacheJSCallBack;
}

+ (void)setModuleClasses:(NSMutableDictionary <NSString*,NSString*> *)moduleClasses {
    _moduleClasses = moduleClasses;
}

+ (NSMutableDictionary <NSString*,NSString*> *)moduleClasses{
    // 懒加载
    if (!_moduleClasses) {
        [self setModuleClasses:[[NSMutableDictionary alloc]init]];
    }
    return _moduleClasses;
}

+ (void)setModuleClassesSyncQueue:(dispatch_queue_t)moduleClassesSyncQueue{
    _moduleClassesSyncQueue = moduleClassesSyncQueue;
}

+ (dispatch_queue_t)moduleClassesSyncQueue {
    // 懒加载
    if (!_moduleClassesSyncQueue) {
        [self setModuleClassesSyncQueue:dispatch_queue_create("com.Tencent.ABCBinding.ModuleClassesSyncQueue", DISPATCH_QUEUE_CONCURRENT)];
    }
    return _moduleClassesSyncQueue;
}
#pragma mark -
#pragma mark - public 函数
+ (NSNumber*)executeWithMethodName:(NSString*)methodName
                            args:(NSString*)args
                        callback:(NSString *)callback {
    // 判断参数格式是否正常
    NSError *error = nil;
    NSDictionary *dicArgs = [ABCBindingUtil dictWithJsonString:args error:error];
    if (error) {
        return @(EXECUTE_RESULT_ERROR_CODE_PARAMS_ERROR);
    }
    // 判断是否是JS回调Native
    if ([methodName hasPrefix:ABCSignsJSCallBack]) {
        NSMutableDictionary *cacheJSCallBack = [self cacheJSCallBack];
        JSCallBack jscallback = cacheJSCallBack[methodName];
        if (jscallback) {
            jscallback(dicArgs);
            [cacheJSCallBack removeObjectForKey:methodName];
            return @(EXECUTE_RESULT_SUCCESS);
        }
        return @(EXECUTE_RESULT_ERROR_CODE_METHOD_NOT_DEFINED);
    }
    
    // 拿到需要反射的字符串
    NSString *method = [NSString stringWithFormat:@"%@:Callback:",methodName];
    NSString* className = nil;
    if (_moduleClasses) {
        className = [_moduleClasses objectForKey:method];
    }
    if (!className) {
        return @(EXECUTE_RESULT_ERROR_CODE_METHOD_NOT_DEFINED);
    }
    
    // 反射得到运行时class和方法选择子
    SEL sel = NSSelectorFromString(method);
    Class cls = NSClassFromString(className);
    
    if (![cls respondsToSelector:sel]) {
        return @(EXECUTE_RESULT_ERROR_CODE_METHOD_NOT_DEFINED);
    }
    
    
    
    ABCBindingCallBack *bindingCallback = [[ABCBindingCallBack alloc] init];
    bindingCallback.JSCallBackName = callback;
    // 执行函数
    SuppressPerformSelectorLeakWarning(
        [cls performSelector:sel withObject:dicArgs withObject:bindingCallback];
    );
    
    return @(EXECUTE_RESULT_SUCCESS);
}

+ (void)callJSFunctionName:(NSString*)JSFunctionName
                     Parma:(NSDictionary *)param
                JSCallBack:(JSCallBack)JSCallBack {
    Class<ABCBindingCocosEvalStringProtocol> cls = NSClassFromString([ABCBindingCocosEvalStirng getProtocolClassName]);
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if (JSCallBack) {
        // 生成 UUID
        NSString *uuid = [self uuidString];
        [dic setValue:uuid forKey:@"@nativeCallbackName"];
        // 缓存 JSCallBack UUID
        NSMutableDictionary *cacheJSCallBack = [self cacheJSCallBack];
        [cacheJSCallBack setObject:JSCallBack forKey:uuid];
    }
    if (param) {
        [dic setObject:param forKey:@"data"];
    }
    NSString *jsonParam = [ABCBindingUtil jsonStringWithDict:dic];
    NSString *jsFunc = [NSString stringWithFormat:@"window.abcbinding_router_%@(%@);",JSFunctionName,jsonParam];
    dispatch_main_async_safe(^{
        [cls callJavaScriptFunc:jsFunc];
    });
}
#pragma mark -
#pragma mark - privte 函数
// uuid  消息的唯一标识
+ (NSString *)uuidString {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [NSString stringWithFormat:@"%@%@-%ld",ABCSignsJSCallBack,[uuid lowercaseString],(long)[[NSDate date] timeIntervalSince1970]*1000];
}
@end
