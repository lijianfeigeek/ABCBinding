#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ABCBinding.h"
#import "ABCBindingCallBack.h"
#import "ABCBindingCocosEvalStirng.h"
#import "ABCBindingCocosEvalStringProtocol.h"
#import "ABCBindingUtil.h"

FOUNDATION_EXPORT double ABCBindingVersionNumber;
FOUNDATION_EXPORT const unsigned char ABCBindingVersionString[];

