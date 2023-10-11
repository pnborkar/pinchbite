//
//  PinchbiteLogin_VC.h
//  Pinchbite Inc.
//
//  Created by Praod Borkar on 10/6/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinchbiteLogin_VC : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)finishtext:(id)sender;

- (IBAction)login:(id)sender;

@end
