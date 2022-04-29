//
//  DoraemonJavaScriptPlugin.h
//  DoraemonPluginsDemo
//
//  Created by carefree on 2022/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonJavaScriptPlugin : NSObject

+ (void)installWithTitle:(NSString *)title icon:(id)imageOrString desc:(NSString *)desc atModule:(NSString *)moduleName handle:(void(^ _Nullable)(id _Nullable result, NSError * _Nullable error))handleBlock;

+ (void)evalJavaScript:(NSString *)script;

@end

NS_ASSUME_NONNULL_END
