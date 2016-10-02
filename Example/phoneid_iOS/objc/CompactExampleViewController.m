//
//  CompactExampleViewController.m
//  phoneid_iOS
//
//  Created by Alyona on 7/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import "phoneid_iOS-Swift.h"
#import "CompactExampleViewController.h"
#import "DetailsViewController.h"

@interface CompactExampleViewController ()
@property (weak, nonatomic) IBOutlet CompactPhoneIdLoginButton *compactPhoneIdButton;
@property (strong, nonatomic) DetailsViewController *details;

@end

@implementation CompactExampleViewController

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.details.presetNumber addTarget:self action:@selector(presetNumberChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.details.switchUserPresetNumber addTarget:self action:@selector(presetSwitchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)presetNumberChanged:(UITextField*)sender{
    self.compactPhoneIdButton.phoneNumberE164 = self.details.switchUserPresetNumber.on ? sender.text : @"";
}

- (void)presetSwitchChanged:(UISwitch*)sender{
    self.compactPhoneIdButton.phoneNumberE164 = sender.on ? self.details.presetNumber.text : @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"details"]) {
        self.details = segue.destinationViewController;
    }
}


@end
