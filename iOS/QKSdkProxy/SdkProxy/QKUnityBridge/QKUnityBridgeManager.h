//
//  QKUnityBridgeManager.h
//  Unity-iPhone
//
//  Created by wending on 2018/5/4.
//

#import <Foundation/Foundation.h>

typedef void (^QKUnityCallbackFunc)(NSString*);

@interface QKUnityBridgeManager : NSObject

@property(nonatomic, weak) id unityDelegate;

+ (QKUnityBridgeManager *)Instance;

//调用unity函数
- (void)CallUnity:(NSString*)funcName strData:(NSString*)strData;

//接收unity调用
- (void)OnCall:(NSString*)funcName strData:(NSString*)strData;

@end
