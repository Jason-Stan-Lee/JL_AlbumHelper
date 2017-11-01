//
//  JL_MainViewControllerManager.h
//  SavePhotos
//
//  Created by JasonLee on 2017/11/1.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_MainViewControllers.h"

@interface JL_MainViewControllerManager : NSObject

// 配置主视图控制器
+ (void)setRootViewControllerForMainWindow:(UIWindow *)mainWindow;

@end
