//
//  ChatViewController.m
//  BlueChat
//
//  Created by Max Zou on 10/06/2016.
//  Copyright © 2016 Max Zou. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *messageTableView;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@property (weak, nonatomic) IBOutlet UILabel *messageLengthLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;

@property (nonatomic) CGFloat originalBottomSpace;

@end

@implementation ChatViewController

static NSString *const MessageTableViewCellReuseIdentifier = @"ChatTableViewCell";

static const NSInteger ViewTagIncomingLabelInCell = 100;
static const NSInteger ViewTagOutgoingLabelInCell = 200;

static const NSInteger MaxMessageLength = 140;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // clean up the data left from last session
    [[BCMessageManager sharedManager] removeAllMessages];
    [self.messageTableView reloadData];
    self.messageTextView.text = @"";
    
    self.originalBottomSpace = self.bottomSpaceConstraint.constant;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)sendMessage:(id)sender {
    
    NSString *message = self.messageTextView.text;
    if (message.length > 0) {
    
        BCMessage *bcMessage = [[BCMessageManager sharedManager] addMessage:message direction:BCMessageDirectionOutgoing];
        [self reloadMessages];
        
        [self.chatManager sendMessage:bcMessage];
    }
}

- (IBAction)viewTapped:(id)sender {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
 
    NSValue *rectValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    if (rectValue) {
        CGRect rect = rectValue.CGRectValue;
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomSpaceConstraint.constant = rect.size.height + self.originalBottomSpace;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomSpaceConstraint.constant = self.originalBottomSpace;
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // allow delete
    if (text.length == 0) {
        return YES;
    }
    
    NSInteger newLength = textView.text.length + range.length + text.length;
    return newLength <= MaxMessageLength;
}

- (void)textViewDidChange:(UITextView *)textView {
    self.messageLengthLabel.text = [NSString stringWithFormat:@"%lu", MaxMessageLength - textView.text.length];
}

#pragma mark - Helpers
- (void)reloadMessages {
    
    [self.messageTableView reloadData];
    [self scrollToBottom];
}

- (void)scrollToBottom {
    
    CGRect rect = CGRectMake(0, self.messageTableView.contentSize.height - self.messageTableView.bounds.size.height, self.messageTableView.bounds.size.width, self.messageTableView.bounds.size.height);
    
    [self.messageTableView scrollRectToVisible:rect animated:YES];
}

#pragma mark - BCChatManagerDelegate
- (void)newMessageDidCome {
    
    [self reloadMessages];
}

- (void)chatRoomDidClose {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MessageTableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[BCMessageManager sharedManager] numberOfMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageTableViewCellReuseIdentifier];
    BCMessage *bcMessage = [[BCMessageManager sharedManager] messageAtIndex:indexPath.row];
    if (bcMessage) {
        
        NSInteger labelTag = (bcMessage.direction == BCMessageDirectionIncoming) ? ViewTagIncomingLabelInCell : ViewTagOutgoingLabelInCell;
        UILabel *label = [cell viewWithTag:labelTag];
        NSAssert(label, @"Can't find label in message table view cell");
        label.text = bcMessage.message;
        label.hidden = NO;
        
        NSInteger otherLabelTag = (bcMessage.direction == BCMessageDirectionIncoming) ? ViewTagOutgoingLabelInCell : ViewTagIncomingLabelInCell;
        UILabel *otherLabel = [cell viewWithTag:otherLabelTag];
        NSAssert(otherLabel, @"Can't find label in message table view cell");
        otherLabel.hidden = YES;
    }
    return cell;
}

@end
