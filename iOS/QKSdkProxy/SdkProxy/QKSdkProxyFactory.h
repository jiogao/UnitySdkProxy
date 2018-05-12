//
//  QKSdkProxyManager.h
//  Unity-iPhone
//
//  Created by wending on 2018/5/4.
//

#import <Foundation/Foundation.h>

#import "QKBaseSdkProxy.h"

// 接入sdk步骤:
// 1.新增子类，继承 QKBaseSdkProxy
// 2.把子类类型通过宏设置为当前的 QKBaseSdkProxy 子类型:
//    IMPL_QKSDK_SUPPORT_SUBCLASS(SubSDKSupportClass)
// 3.根据sdk需求重写 -- AppController 生命周期 -- 中的方法
// 4.重写 -- sdk action -- 下的方法，完成初始化，登录，支付等操作
// 5.在初始化，登录，支付等事件完成时调用 SDKUnityApi 中的相应接口通知unity

#define IMPL_QKSDK_PROXY_SUBCLASS(ClassName)    \
@interface ClassName(OverrideAppDelegate)       \
{                                               \
}                                               \
+(void)load;                                    \
@end                                            \
@implementation ClassName(OverrideAppDelegate)  \
+(void)load                                     \
{                                               \
    extern const char* QKSdkProxyClassName;     \
    QKSdkProxyClassName = #ClassName;           \
}                                               \
@end                                            \

@interface QKSdkProxyFactory : NSObject

+ (QKBaseSdkProxy *)SdkProxy;

@end
