//
//  ViewController.m
//  phoneid_iOS
//
//  Copyright 2015 phone.id - 73 knots, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "ViewController.h"
#import "phoneid_iOS-Swift.h"

@interface ViewController ()
@property PhoneIdService* phoneId;
@property (weak, nonatomic) IBOutlet UIView *tokensView;
@property (weak, nonatomic) IBOutlet UITextField *tokenText;
@property (weak, nonatomic) IBOutlet UITextField *refreshTokenText;
@property (weak, nonatomic) IBOutlet UITextField *presetNumber;
@property (weak, nonatomic) IBOutlet UISwitch *switchDebugContactsUpload;

@property (weak, nonatomic) IBOutlet PhoneIdLoginButton *phoneIdButton;
@property (weak, nonatomic) IBOutlet CompactPhoneIdLoginButton *compactPhoneIdButton;

@property BOOL usePresetNumber;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneId = [PhoneIdService sharedInstance];
    
    [self updateTokenInfoView];
    
    __weak typeof(self) weakSelf = self;
    
    // Handle authentication success
    [PhoneIdService sharedInstance].phoneIdAuthenticationSucceed = ^(TokenInfo* token){
        [weakSelf updateTokenInfoView];
    };
    
    // SDK calls this block whenever error happened
    [PhoneIdService sharedInstance].phoneIdWorkflowErrorHappened = ^(NSError* error){
        NSLog(@"%@", error.localizedDescription);
    };
    
    // SDK calls this block when user taps close button
    [PhoneIdService sharedInstance].phoneIdAuthenticationCancelled = ^{
        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:@"phone.id authentication has been cancelled" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    };
    
    // SDK calls this block every time when token refreshed
    [PhoneIdService sharedInstance].phoneIdAuthenticationRefreshed = ^(TokenInfo* token){
        [weakSelf updateTokenInfoView];
    };
    
    // SDK calls this block on logout
    [PhoneIdService sharedInstance].phoneIdDidLogout = ^{
        [weakSelf updateTokenInfoView];
    };
    
}

-(void) updateTokenInfoView{
    self.tokensView.hidden = !self.phoneId.isLoggedIn;
    
    TokenInfo* token = self.phoneId.token;
    if (token) {
        self.tokenText.text = token.accessToken;
        self.refreshTokenText.text = token.refreshToken;
    }
}

- (IBAction)uploadContactsTapped:(id)sender {
    BOOL uploadInDebugMode = self.switchDebugContactsUpload.isOn;
    [self.phoneId uploadContactsWithDebugMode:uploadInDebugMode completion:^(NSInteger numberOfContacts, NSError * error) {
       
       UIAlertController* alertController;
       if(error){
           alertController = [UIAlertController alertControllerWithTitle:[error localizedDescription] message:[error localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
       }else{
           alertController = [UIAlertController alertControllerWithTitle:@"Number of updated contacts" message:@(numberOfContacts).stringValue preferredStyle:UIAlertControllerStyleAlert];
       }
       [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
       [self presentViewController:alertController animated:YES completion:nil];
       
   }];
    
}

- (IBAction)editProfileTapped:(id)sender {
    [self.phoneId loadMyProfile: ^(UserInfo* userInfo, NSError* e){
        
        if (userInfo){
            UIViewController* profileController = [self.phoneId.componentFactory editProfileViewController: userInfo];
            [self presentViewController:profileController animated:YES completion:nil];
        }
        
    }];
}

- (IBAction)switchCompactMode:(UISwitch *)sender {
    self.phoneIdButton.hidden = sender.on;
    self.phoneIdButton.userInteractionEnabled = !self.phoneIdButton.hidden;
    self.compactPhoneIdButton.hidden = !sender.on;
    self.compactPhoneIdButton.userInteractionEnabled = !self.compactPhoneIdButton.hidden;
}

- (IBAction)switchPresetNumber:(UISwitch *)sender {
    if(sender.on){
        self.phoneIdButton.phoneNumberE164 = self.presetNumber.text;
        self.compactPhoneIdButton.phoneNumberE164 = self.presetNumber.text;
    }else{
        self.phoneIdButton.phoneNumberE164 = nil;
        self.compactPhoneIdButton.phoneNumberE164 = nil;
    }
}


@end
