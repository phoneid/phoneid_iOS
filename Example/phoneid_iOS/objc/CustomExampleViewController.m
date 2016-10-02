//
//  CustomExampleViewController.m
//  phoneid_iOS
//
//  Created by Alyona on 7/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "CustomExampleViewControllerObjc.h"
#import "phoneid_iOS-Swift.h"
#import "DetailsViewControllerObjc.h"

@interface CustomExampleViewControllerObjc ()

@property (strong, nonatomic) PhoneIdLoginWorkflowManager *flowManager;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *customLoginButton;

@property (strong, nonatomic) DetailsViewControllerObjc *details;
@property (strong, nonatomic) NSString *phoneNumberE164;

@end

@implementation CustomExampleViewControllerObjc

- (IBAction)presentFromCustomButton:(id)sender {
    [self.flowManager startLoginFlow: nil // parent controller to present phone.id from
               initialPhoneNumerE164: self.phoneNumberE164
              startAnimatingProgress: ^{
                  [self.activityIndicator startAnimating];
              }
              stopAnimationProgress: ^{
                   [self.activityIndicator startAnimating];
              }];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.flowManager = [[PhoneIdLoginWorkflowManager alloc] init]
    
    [self.details.presetNumber addTarget:self action:@selector(presetNumberChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.details.switchUserPresetNumber addTarget:self action:@selector(presetSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)presetNumberChanged:(UITextField*)sender{
    self.phoneNumberE164 = self.details.switchUserPresetNumber.on ? sender.text : @"";
}

- (void)presetSwitchChanged:(UISwitch*)sender{
    self.phoneNumberE164 = sender.on ? self.details.presetNumber.text : @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"details"]) {
        self.details = segue.destinationViewController;
    }
}



@end
