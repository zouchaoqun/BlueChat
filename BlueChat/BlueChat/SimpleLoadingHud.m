//
//  SimpleLoadingHud.m
//  BlueChat
//
//  Created by Max Zou on 12/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "SimpleLoadingHud.h"

@implementation SimpleLoadingHud

+ (SimpleLoadingHud *)showHudInView:(UIView *)view {
    
    SimpleLoadingHud *hud = [[self alloc] initWithFrame:view.frame];
    
    [view addSubview:hud];
    
    [NSLayoutConstraint constraintWithItem:hud attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    [NSLayoutConstraint constraintWithItem:hud attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [NSLayoutConstraint constraintWithItem:hud attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [NSLayoutConstraint constraintWithItem:hud attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    return hud;
}

+ (void)hidHudInView:(UIView *)view {
    
    SimpleLoadingHud *hud = [self findHudInView:view];
    if (hud) {
        [hud removeFromSuperview];
    }
}

+ (SimpleLoadingHud *)findHudInView:(UIView *)view {
    
    NSEnumerator *subViewEnumerator = [view.subviews reverseObjectEnumerator];
    for (UIView *subView in subViewEnumerator) {
        if ([subView isKindOfClass:[SimpleLoadingHud class]]) {
            return (SimpleLoadingHud *)subView;
        }
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.color = [UIColor blackColor];
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:activityIndicator];
        
        [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0].active = YES;
        [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0].active = YES;
        
        [activityIndicator startAnimating];
    }
    return self;
}

@end
