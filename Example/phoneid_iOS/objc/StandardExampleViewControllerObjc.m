//
//  StandardExampleViewController.m
//  phoneid_iOS
//
//  Created by Alyona on 7/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "phoneid_iOS-Swift.h"
#import "DetailsViewControllerObjc.h"
#import "StandardExampleViewControllerObjc.h"


@interface StandardExampleViewControllerObjc ()
@property (weak, nonatomic) IBOutlet PhoneIdLoginButton *phoneIdButton;
@property (strong, nonatomic) DetailsViewControllerObjc *details;

@end

@implementation StandardExampleViewControllerObjc

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.details.presetNumber addTarget:self action:@selector(presetNumberChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.details.switchUserPresetNumber addTarget:self action:@selector(presetSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)presetNumberChanged:(UITextField*)sender{
    self.phoneIdButton.phoneNumberE164 = self.details.switchUserPresetNumber.on ? sender.text : @"";
}

- (void)presetSwitchChanged:(UISwitch*)sender{
    self.phoneIdButton.phoneNumberE164 = sender.on ? self.details.presetNumber.text : @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"details"]) {
        self.details = segue.destinationViewController;
    }
}


@end
