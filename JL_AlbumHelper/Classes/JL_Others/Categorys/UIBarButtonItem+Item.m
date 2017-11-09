//
//  UIBarButtonItem+Item.m
//  Project
//
//  Created by Jason_Mac on 14/9/7.
//  Copyright (c) 2014年 Jason. All rights reserved.
//

#import "UIBarButtonItem+Item.h"

#define K_BUTTON_MARGIN (8.0)

@implementation UIBarButtonItem (Item)

+ (instancetype)barButtonItemWithImage:(UIImage *)image
                      highLightedImage:(UIImage *)highlightedImage
                                target:(id)target
                                action:(SEL)action
{
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [barButton setBackgroundImage:image forState:UIControlStateNormal];
    if (highlightedImage) {
        [barButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [barButton sizeToFit];
    
    return [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

+ (instancetype)barButtonWithTitle:(NSString *)title
                         tintColor:(UIColor *)tintColor
                            target:(id)target
                            action:(SEL)action
{
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [barButton setTitle:title forState:UIControlStateNormal];
    [barButton setTitleColor:tintColor forState:UIControlStateNormal];
    [barButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    [barButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [barButton sizeToFit];
    
    return [[UIBarButtonItem alloc] initWithCustomView:barButton];
}

@end
