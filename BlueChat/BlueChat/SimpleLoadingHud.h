//
//  SimpleLoadingHud.h
//  BlueChat
//
//  Simplified version of https://github.com/jdg/MBProgressHUD :)
//
//  Created by Max Zou on 12/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleLoadingHud : UIView

+ (SimpleLoadingHud *)showHudInView:(UIView *)view;

+ (void)hidHudInView:(UIView *)view;

+ (SimpleLoadingHud *)findHudInView:(UIView *)view;

@end
