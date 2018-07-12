//
//  SDKDataManager.h
//  Unity-iPhone
//

#import <Foundation/Foundation.h>

@interface SdkDataManager : NSObject
+(SdkDataManager *)Instance;

@property(nonatomic, copy) NSString* SdkUid;

@property(nonatomic, copy) NSString* RoleId;
@property(nonatomic, copy) NSString* RoleName;
@property(nonatomic, copy) NSString* RoleLevel;
@property(nonatomic, copy) NSString* RoleCreateTime;
@property(nonatomic, copy) NSString* RoleVipLevel;
@property(nonatomic, copy) NSString* RoleGold;
@property(nonatomic,copy) NSString* RoleUpdateTime;

@property(nonatomic, copy) NSString* ServerId;
@property(nonatomic, copy) NSString* ServerName;
@property(nonatomic,copy) NSString* loginToken;
@property(nonatomic,copy) NSString* CpuId;

@end
