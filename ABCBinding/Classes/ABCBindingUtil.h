//
//  ABCBingdingUtil.h
//  demo_attribute
//
//  Created by ezli on 2021/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ABCBindingUtil : NSObject

/// JSON转字典
/// @param json JOSN
/// @param error error
+ (NSDictionary *)dictWithJsonString:(NSString *)json error:(NSError *)error;

/// 字典转JSON
/// @param dict 字典
+ (NSString *)jsonStringWithDict:(NSDictionary *)dict;

/// JSON转字典
/// @param json JOSN
+ (NSDictionary *)dictWithJsonString:(NSString *)json;

@end

NS_ASSUME_NONNULL_END
