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


@property(nonatomic, copy) NSString* ConsumCoin;
@property(nonatomic, copy) NSString* RemainCoin;
@property(nonatomic, copy) NSString* ConsumeBind;
@property(nonatomic, copy) NSString* RemainBind;
@property(nonatomic, copy) NSString* ItemName;
@property(nonatomic, copy) NSString* ItemCount;
@property(nonatomic,copy) NSString* ItemDes;

@end
