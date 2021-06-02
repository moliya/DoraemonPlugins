//
//  DoraemonEnvPlugin.h
//  DoraemonPluginsDemo
//
//  Created by carefree on 2021/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonEnvPlugin : NSObject

+ (void)installWithTitle:(NSString *)title icon:(id)imageOrString desc:(NSString *)desc atModule:(NSString *)moduleName handle:(void(^ _Nullable)(NSString *env, NSString *data))handleBlock;

+ (void)addDefaultEnv:(NSString *)env withData:(NSString *)data;

+ (void)manualUpdateEnv:(NSString *)env withData:(NSString *)data;

@end

NS_ASSUME_NONNULL_END
