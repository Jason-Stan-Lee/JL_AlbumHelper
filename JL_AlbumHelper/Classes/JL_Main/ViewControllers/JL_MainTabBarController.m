//
//  JL_MainTabBarController.m
//  SavePhotos
//
//  Created by JasonLee on 2017/10/31.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import "JL_MainTabBarController.h"

@interface JL_MainTabBarController ()

@end

@implementation JL_MainTabBarController

+ (void)initialize {
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = [UIColor lightGrayColor];

    NSMutableDictionary *attrSelected = [NSMutableDictionary dictionary];
    attrSelected[NSForegroundColorAttributeName] = [UIColor grayColor];

    if (@available(iOS 9.0, *)) {
        UITabBarItem *item = [UITabBarItem appearanceWhenContainedInInstancesOfClasses:@[self]];
        
        [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
        [item setTitleTextAttributes:attrSelected forState:UIControlStateSelected];
    } else {
        // Fallback on earlier versions
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
