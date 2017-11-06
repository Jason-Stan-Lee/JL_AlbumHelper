//
//  JL_MacroUtils.h
//  JL_AlbumHelper
//
//  Created by JasonLee on 2017/11/6.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#ifndef JL_MacroUtils_h
#define JL_MacroUtils_h
#import <AdSupport/AdSupport.h>

//----------------------------------------------------------

/* SystemVersion */

#define systemVersion() [[UIDevice currentDevice] systemVersion]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([systemVersion() compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([systemVersion() compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([systemVersion() compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([systemVersion() compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([systemVersion() compare:v options:NSNumericSearch] != NSOrderedDescending)

#define GreaterThanIOS8System SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0.0")
#define GreaterThanIOS7System SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")

#define IS_SUPPORT_ARC  __has_feature(objc_arc)

/* Device UID */

#define CurrentDeviceAdUID() [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]

/* App */

#define mainBundle()        [NSBundle mainBundle]
#define MY_BUNDLE_ID        mainBundle().bundleIdentifier
#define MY_INFO_DICTIONDRY  [mainBundle() infoDictionary]
#define CURRENT_APP_NAME    [MY_INFO_DICTIONDRY objectForKey:@"CFBundleDisplayName"]
#define CURRENT_APP_VERSION [MY_INFO_DICTIONDRY objectForKey:@"CFBundleShortVersionString"]
#define APP_KEY             @""

/* File Path */

#define documentPath() NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
#define libraryPath() NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject
#define cachePath() NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject

#define defaultNotificationCenter() [NSNotificationCenter defaultCenter]
#define fileManager() [NSFileManager defaultManager]
#define userDefault() [NSUserDefaults standardUserDefaults]
#define application() [UIApplication sharedApplication]

/* DEBUG Log */

#ifdef DEBUG
    #define debugMethod() NSLog(@"%s", __func__)
    #define NSLog(format, ...) printf("\n[%s] %s [第%d行]: %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
    #define NSLog(...)
    #define debugMethod()
#endif

/* UI */

#define screenWidth()  [UIScreen mainScreen].bounds.size.width
#define screenHeight() [UIScreen mainScreen].bounds.size.height
#define screenSize()   [UIScreen mainScreen].bounds.size
#define adaptWidth(_float) (_float * screenWidth() / 375.f)
#define adaptHeight(_float) (_float * screenHeight() / 667.f)
#define adaptFontSize(_float) (_float)

#define StatusBarHeight         (20.f)
#define StatusBarHoldHeight     StatusBarHeight
#define NavigationBarHeight     (44.f)
#define TabBarHeight            (49.f)
#define AspectScaleLenght(_x)  ceilf((_x) * screenWidthScaleFactor())

//屏幕宽缩放比例
static inline CGFloat screenWidthScaleFactor(){
    return screenSize().width / 320.f;
}

/* selector */

#define ifRespondsSelector(_obj,_sel)  if (_obj&&[(NSObject *)_obj respondsToSelector:_sel])

/* Assert */

#ifdef DEBUG
    #define JSAssert(_condition, _desc) NSAssert(_condition, _desc)
#else
    #define JSAssert(_condition, _desc)
#endif

/* safe access */

#define isNULL(_obj) (_obj == nil || [_obj isEqual:[NSNull null]])

#endif /* JL_MacroUtils_h */
