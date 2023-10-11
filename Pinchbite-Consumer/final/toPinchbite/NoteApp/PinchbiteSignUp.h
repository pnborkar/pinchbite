//
//  PinchbiteSignUp.h
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/6/14
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PinchbiteSignUp : UIViewController < UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstnamefield;
@property (weak, nonatomic) IBOutlet UITextField *lastnamefield;
@property (weak, nonatomic) IBOutlet UITextField *phonefield;

@property (nonatomic) NSMutableString  *authToken;


- (IBAction)signup:(id)sender;

@end
