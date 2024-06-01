//
//  ABCBingdingUtil.m
//  demo_attribute
//
//  Created by ezli on 2021/4/30.
//

#import "ABCBindingUtil.h"

@implementation ABCBindingUtil

+ (NSDictionary *)dictWithJsonString:(NSString *)json error:(NSError *)error {
    if (!json)
        return nil;

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    return dict;
}

+ (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    if (dict == nil)
        return nil;

    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if (error == nil) {
            NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return json;
        } else {
            NSLog(@"generate json error:%@", error);
            return nil;
        }
    } else {
        return nil;
    }
}

+ (NSDictionary *)dictWithJsonString:(NSString *)json {
    if (!json)
        return nil;

    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    if (!dict) {
        NSLog(@"parse json dict error:%@", error);
    }

    return dict;
}

@end
