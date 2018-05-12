//
//  QKSdkProxy_OKWan.h
//  Unity-iPhone
//
//  Created by wending on 2018/4/18.
//

#import <Foundation/Foundation.h>

#import "QKSdkProxyFactory.h"

@interface QKSdkProxy_OKWan : QKBaseSdkProxy

//分销接口
- (void)TBLoginDistributionDidSuccess:(NSString*)strData;
//提现接口
- (void)TBwithdrawalWithRoleName:(NSString*)strData;

@end
