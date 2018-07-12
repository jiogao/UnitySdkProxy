//
//  QKUnityBridgeManager.m
//  Unity-iPhone
//
//  Created by wending on 2018/5/4.
//

#import "QKUnityBridgeManager.h"
#import "QKSdkProxyUtility.h"

#define BRIDGE_OBJ_NAME "QKNativeBridgeManager"

@implementation QKUnityBridgeManager

+ (QKUnityBridgeManager*)Instance
{
    static __strong QKUnityBridgeManager* _Instance = nil;
    if(_Instance == NULL)
    {
        _Instance = [[QKUnityBridgeManager alloc] init];
    }
    return _Instance;
}

//调用unity函数
- (void)CallUnity:(const NSString*)funcName strData:(const NSString*)strData
{
    NSDictionary* data = @{@"funcName":funcName, @"strData":strData};
    
    UnitySendMessage(BRIDGE_OBJ_NAME,
                     [@"OnNativeCall" UTF8String],
                     [[QKSdkProxyUtility Json_DicToString:data] UTF8String]);
}

//接收unity调用
- (void)OnCall:(const NSString*)funcName strData:(NSString*)strData
{
    if (self.unityDelegate != nil && funcName != nil && [funcName length] > 0) {
        //尝试无回调的函数
        NSString* ocFuncName = [funcName stringByAppendingString:@":"];
        SEL sel = NSSelectorFromString(ocFuncName);
        IMP imp = nil;
        
        if ([self.unityDelegate respondsToSelector:sel]) {
            
            imp = [self.unityDelegate methodForSelector:sel];
            void(*func)(id, SEL, NSString*) = (void(*)(id, SEL, NSString*))imp;
            
            func(self.unityDelegate, sel, strData);
            //[self.unityDelegate performSelector:sel withObject:strData];
        } else {
            //尝试有回调的函数
            ocFuncName = [funcName stringByAppendingString:@":callback:"];
            sel = NSSelectorFromString(ocFuncName);
            if ([self.unityDelegate respondsToSelector:sel]) {
                
                imp = [self.unityDelegate methodForSelector:sel];
                void(*func)(id, SEL, NSString*, QKUnityCallbackFunc) = (void(*)(id, SEL, NSString*, QKUnityCallbackFunc))imp;
                
                NSString* callbackFuncName = [NSString stringWithFormat:@"%@", funcName];
                
                // 传入一个回调block，方便回调
                QKUnityCallbackFunc callbackFunc = ^(NSString* retData)
                {
                    [self CallUnity:callbackFuncName strData:retData];
                };
                
                func(self.unityDelegate, sel, strData, callbackFunc);
            }
        }
    }
}

@end

extern "C"
{
    void QKNative_Call(const char* funcName, const char* strData)
    {
        if (funcName == NULL || strlen(funcName) <= 0) {
            return;
        }
        NSString* t_funcName = [NSString stringWithUTF8String:funcName];
        NSString* t_strData = nil;
        if (strData != NULL && strlen(strData) > 0) {
            t_strData = [NSString stringWithUTF8String:strData];
        } else {
            t_strData = @"";
        }
        [[QKUnityBridgeManager Instance] OnCall:t_funcName strData:t_strData];
    }
}
