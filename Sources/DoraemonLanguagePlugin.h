//
//  DoraemonLanguagePlugin.h
//  DoraemonPlugins
//
//  Created by carefree on 2023/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonLanguagePlugin : NSObject

+ (void)installWithTitle:(NSString *)title icon:(id)imageOrString desc:(NSString *)desc atModule:(NSString *)moduleName handle:(void(^ _Nullable)(NSString *env, NSString *data))handleBlock;

+ (void)addDefaultLanguage:(NSString *)title withCode:(NSString *)languageCode;

@end

NS_ASSUME_NONNULL_END
