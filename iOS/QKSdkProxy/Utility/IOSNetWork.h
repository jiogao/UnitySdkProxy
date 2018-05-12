//
//  IOSNetWork.h
//  Unity-iPhone
//
//  Created by weitiancheng on 16/7/18.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "QKUnityBridgeManager.h"

@interface IOSNetWork : NSObject
{
    Reachability  *hostReach;
}
+(IOSNetWork *)Instance;
-(void)reachabilityChanged:(NSNotification *)note;
-(void)startNotifier:(QKUnityCallbackFunc)callback;
@end
