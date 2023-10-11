//
//  UserProfileVC.h
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/24/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTKView.h"

@interface UserProfileVC : UIViewController <PTKViewDelegate, UITextFieldDelegate>

- (IBAction)logout:(id)sender;
@property IBOutlet PTKView* paymentView;
//@property(weak, nonatomic) PTKView *paymentView;

- (IBAction)savecard:(id)sender;
- (IBAction)deletecard:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetpasswd;
- (IBAction)resetpasswd:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *passwdfield;
@property (weak, nonatomic) IBOutlet UITextField *emailfield;
@property (weak, nonatomic) IBOutlet UITextField *phonefield;

@end
