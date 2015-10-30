//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "phoneid_iOS-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // configure phone.id
    [[PhoneIdService sharedInstance] configureClient:@"TestPhoneId" autorefresh:YES];
    
    // UI theming
    // [PhoneIdService sharedInstance].componentFactory = [self customComponentFactory];
    
    return YES;
}

- (id<ComponentFactory>)customComponentFactory{

    id<ComponentFactory> factory = [[DefaultComponentFactory alloc] init];
    
    ColorScheme* colorScheme = [[ColorScheme alloc] init];
    colorScheme.mainAccent = [[UIColor alloc] initWithHex:0xAABB44];
    colorScheme.extraAccent = [[UIColor alloc] initWithHex:0x886655];
    colorScheme.success = [[UIColor alloc] initWithHex:0x91C1CC];
    colorScheme.fail = [[UIColor alloc] initWithHex:0xD4556A];
    
    colorScheme.inputBackground = [[[UIColor alloc] initWithHex:0xEEEEDD] colorWithAlphaComponent:0.6];
    [colorScheme applyCommonColors];
    
    colorScheme.buttonHighlightedImage = [[UIColor alloc] initWithHex: 0x778230];
    colorScheme.buttonHighlightedText = [[UIColor alloc] initWithHex: 0x778230];
    colorScheme.buttonHighlightedBackground = [[UIColor alloc] initWithHex: 0xBBC86A];
    factory.defaultBackgroundImage = [UIImage imageNamed:@"background"];
    factory.colorScheme = colorScheme;
    
    return factory;
}

@end
