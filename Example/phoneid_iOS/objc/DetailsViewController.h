//
//  DetailsViewController.h
//  phoneid_iOS
//
//  Created by Alyona on 7/3/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *tokensView;
@property (weak, nonatomic) IBOutlet UITextField *tokenText;
@property (weak, nonatomic) IBOutlet UITextField *refreshTokenText;
@property (weak, nonatomic) IBOutlet UITextField *presetNumber;
@property (weak, nonatomic) IBOutlet UISwitch *switchUserPresetNumber;
@property (weak, nonatomic) IBOutlet UISwitch *switchDebugContactsUpload;


@end
