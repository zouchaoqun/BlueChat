//
//  ViewController.m
//  BlueChat
//
//  Created by Max Zou on 8/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "ViewController.h"
#import <BlueChatLib/BlueChatLib.h>

@interface ViewController () <BCChatServerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[BCChatServer sharedInstance] startChatServerWithName:@"abcdefgh12345678" delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



#pragma mark - BCChatServerDelegate

- (void)chatServerDidStart {
    NSLog(@"chat server started");
}

- (void)chatServerDidFailToStart:(NSString *)errorMessage {
    NSLog(@"chat server failed to start %@", errorMessage);
}

@end
