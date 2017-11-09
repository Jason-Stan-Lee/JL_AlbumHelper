//
//  JL_MainNavigationController.m
//  SavePhotos
//
//  Created by JasonLee on 2017/10/31.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import "JL_MainNavigationController.h"
#import "UIBarButtonItem+Item.h"

@interface JL_MainNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) id popDelegate;

@end

@implementation JL_MainNavigationController

+ (void)initialize {
    
    if (@available(iOS 9.0, *)) {
        UINavigationBar *navBarAppearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[self]];
        NSDictionary *attrs = @{NSFontAttributeName            : [UIFont systemFontOfSize:20],
                                NSForegroundColorAttributeName : [UIColor whiteColor]};
        
        navBarAppearance.translucent = YES;
        navBarAppearance.titleTextAttributes = attrs;
        navBarAppearance.barTintColor = [UIColor grayColor];
    } else {
        // Fallback on earlier versions
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.popDelegate = self.interactivePopGestureRecognizer.delegate;
    self.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self.viewControllers[0]) {
        self.interactivePopGestureRecognizer.delegate = self.popDelegate;
    } else {
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
        [self setUpBarButtonItemOfViewController:viewController];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)setUpBarButtonItemOfViewController:(UIViewController *)controller {
    controller.navigationItem.leftBarButtonItem =
    [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"navigationbar_back"]
                           highLightedImage:[UIImage imageNamed:@"navigationbar_back"]
                                     target:self
                                     action:@selector(popoverViewController:)];
}

- (void)popoverViewController:(UIBarButtonItem *)item {
    [self popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
