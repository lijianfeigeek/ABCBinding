//
//  ABCViewController.m
//  ABCBinding
//
//  Created by lijianfeigeek on 04/23/2021.
//  Copyright (c) 2021 lijianfeigeek. All rights reserved.
//

#import "ABCViewController.h"

#import "ABCBinding.h"
#import "ABCBindingUtil.h"

@interface ABCViewController ()

@end

@ABCBinding(downloadFile)
+ (void)downloadFile:(NSDictionary *)JSParam Callback:(ABCBindingCallBack *)callback {
    NSLog(@"downloadFile: %@",JSParam);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callback.onSuccess(@{@"success":@"success"});
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callback.onProgress(@{@"progress":@"progress"});
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callback.onFailure(1,@"error");
    });
}

@end

@implementation ABCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSDictionary *dic = @{
        @"key_1":@(YES),
        @"key_2":@(NO),
        @"key_3":@(1),
        @"key_4":@(0)
    };
    
    // mock cocos js 调用
    NSNumber*status =  [ABCBinding executeWithMethodName:@"downloadFile" args:[ABCBindingUtil jsonStringWithDict:dic] callback:@"js_callback"];
    NSLog(@"%@",status);
    
    [ABCBinding callJSFunctionName:@"function" Parma:dic JSCallBack:^(NSDictionary * _Nullable JSCallBackParam) {
        NSLog(@"JSCallBackParam:%@",JSCallBackParam);
    }];
    
    NSMutableDictionary *cacheJSCallBack = ABCBinding.cacheJSCallBack;
    [cacheJSCallBack enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
        NSLog(@"cacheJSCallBack loop: %@",key);
        NSNumber*status_1 =  [ABCBinding executeWithMethodName:key args:[ABCBindingUtil jsonStringWithDict:dic] callback:@"natove_js_callback"];
        NSLog(@"cacheJSCallBack status_1 : %@",status_1);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
