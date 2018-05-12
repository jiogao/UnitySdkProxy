//
//  QKSdkProxyUtility.h
//  Unity-iPhone
//
//  Created by wending on 2018/5/4.
//

#import <Foundation/Foundation.h>

@interface QKSdkProxyUtility : NSObject

+ (void)ApplicationQuit;

+ (NSString*)GetVersion;
+ (NSString*)GetBundleVersion;
+ (NSString*)GetIDFA;
+ (NSString*)GetIDFV;
+ (NSString*)GetPrower;

+ (NSDictionary *)Json_StringToDic:(NSString *)string;
+ (NSArray *)Json_StringToArr:(NSString *)string;
+ (NSString *)Json_DicToString:(NSDictionary *)dic;

+ (UIView *)getView;
+ (UIViewController *)getViewController;

@end
