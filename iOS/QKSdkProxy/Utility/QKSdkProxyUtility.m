//
//  QKSdkProxyUtility.m
//  Unity-iPhone
//
//  Created by wending on 2018/5/4.
//

#import "QKSdkProxyUtility.h"

#import <AdSupport/AdSupport.h>

@implementation QKSdkProxyUtility

+ (void)ApplicationQuit
{
    exit(EXIT_SUCCESS);
}

+ (NSString*)GetVersion
{
    return [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString*)GetBundleVersion
{
    return [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
}

+ (NSString*)GetIDFA
{
    NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//    if([adId isEqual:[NSNull null]]) adId = @"";
    return adId;
}

+ (NSString*)GetIDFV
{
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return idfv;
}

+ (NSString*)GetPrower
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    NSNumber *num = [NSNumber numberWithDouble:deviceLevel];
    return [num stringValue];
}

+ (NSDictionary *)Json_StringToDic:(NSString *)string
{
    //json字符串转字典
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    return dic;
}

+ (NSArray *)Json_StringToArr:(NSString *)string
{
    //json字符串转数组
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return arr;
}

+ (NSString *)Json_DicToString:(NSDictionary *)dic
{
    //字典转json
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return string;
}

+ (UIView *)getView
{
    return [[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0];
}

+ (UIViewController *)getViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
    {
        result = nextResponder;
    }
    else
    {
        result = window.rootViewController;
    }
    return result;
}

@end
