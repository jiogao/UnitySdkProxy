//
//  SDKDataManager.h
//  Unity-iPhone
//

#import <Foundation/Foundation.h>

@interface SdkDataManager : NSObject
+(SdkDataManager *)Instance;

@property(nonatomic, strong) NSString* SdkUserId;

@property(nonatomic, strong) NSString* ServerId;
@property(nonatomic, strong) NSString* ServerName;
@property(nonatomic, strong) NSString* Account;
@property(nonatomic, strong) NSString* RoleId;
@property(nonatomic, strong) NSString* Level;
@property(nonatomic, strong) NSString* RoleName;

@end
