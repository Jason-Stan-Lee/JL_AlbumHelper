//
//  JL_MainViewControllerManager.m
//  SavePhotos
//
//  Created by JasonLee on 2017/11/1.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import "JL_MainViewControllerManager.h"
#import "JL_PhotosSelectViewController.h"

@implementation JL_MainViewControllerManager

+ (void)setRootViewControllerForMainWindow:(UIWindow *)mainWindow {
    
    JL_PhotosSelectViewController *photoSelectViewController = [JL_PhotosSelectViewController new];
    JL_MainNavigationController *photoSelectNavigationViewController = [[JL_MainNavigationController alloc] initWithRootViewController:photoSelectViewController];
    mainWindow.rootViewController = photoSelectNavigationViewController;
}

@end
