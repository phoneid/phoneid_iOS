//
//  DetailsViewController.m
//  phoneid_iOS
//
//  Created by Alyona on 7/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "DetailsViewControllerObjc.h"
#import "phoneid_iOS-Swift.h"

@interface DetailsViewControllerObjc ()
@property (strong, nonatomic) PhoneIdService *phoneId;
@end

@implementation DetailsViewControllerObjc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneId = [PhoneIdService sharedInstance];
    
    __weak typeof(self) weakSelf = self;

    // Handle authentication success
    self.phoneId.phoneIdAuthenticationSucceed = ^(TokenInfo* token){
        [weakSelf updateTokenInfoView];
    };
    
    // Track changes of country code
    self.phoneId.phoneIdWorkflowCountryCodeSelected = ^(NSString* countryCode){
        NSLog(@"country code changed to %@", countryCode);
    };
    
    // Notifies number input completed and will be sent to phone.id server
    self.phoneId.phoneIdWorkflowNumberInputCompleted = ^(NumberInfo* numberInfo){
        NSString* number = numberInfo.e164Format;
        NSLog(@"phone number input completed %@", number);
    };
    
    // Notifies that verification code input completed and will be sent to phone.id server
    self.phoneId.phoneIdWorkflowVerificationCodeInputCompleted = ^(NSString* code){
        NSLog(@"verification input completed %@", code);
    };
    
    // SDK calls this block whenever error happened
    self.phoneId.phoneIdWorkflowErrorHappened = ^(NSError* error){
        NSLog(@"%@", error.localizedDescription);
    };
    
    // SDK calls this block when user taps close button
    self.phoneId.phoneIdAuthenticationCancelled = ^{
        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:@"phone.id authentication has been cancelled" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    };
    
    // SDK calls this block every time when token refreshed
    self.phoneId.phoneIdAuthenticationRefreshed = ^(TokenInfo* token){
        [weakSelf updateTokenInfoView];
    };
    
    // SDK calls this block on logout
    self.phoneId.phoneIdDidLogout = ^{
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



@end
