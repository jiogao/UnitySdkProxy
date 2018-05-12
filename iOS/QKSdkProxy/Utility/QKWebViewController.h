//
//  QKWebViewController.h
//  Unity-iPhone
//
//  Created by wending on 2018/5/7.
//

#import <UIKit/UIKit.h>

@interface QKWebViewController : UIViewController

+ (void)showWeb:(NSString*)url;

- (instancetype)initWithUrl:(NSString*)url;

@end
