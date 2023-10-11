//
//  PinchbiteSignUp.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/6/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import "PinchbiteSignUp.h"
#import <Parse/Parse.h>

#import "Stripe.h"
#import "MBProgressHUD.h"
#import "PTKView.h"
#import "Constants.h"


@interface PinchbiteSignUp ()

@end


@implementation PinchbiteSignUp

@synthesize authToken;

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = CGRectMake(0, 0, 50, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:13];
    label.textColor = [UIColor darkGrayColor];
    label.text = @"Sign Up";
    self.navigationItem.titleView = label;
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"< Login" style:UIBarButtonItemStyleDone target:self action:@selector(gotoLogin:)];
    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:11];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [saveButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    saveButton.enabled = YES;
    self.navigationItem.leftBarButtonItem = saveButton;
    
    [self.phonefield addTarget:self action:@selector(finishtext:)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.lastnamefield addTarget:self action:@selector(finishtext:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.emailTextField addTarget:self action:@selector(finishtext:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(finishtext:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.usernameTextField addTarget:self action:@selector(finishtext:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.firstnamefield addTarget:self action:@selector(finishtext:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    _phonefield.delegate = self;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 10
    
    NSUInteger newLength = [self.phonefield.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    while (newLength < CHARACTER_LIMIT) {
        return [string isEqualToString:filtered];
    }
    /* Limits the no of characters to be enter in text field */
    return (newLength  > CHARACTER_LIMIT ) ? NO : YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField //resign first responder for textfield
{
    return YES;
}

- (IBAction)finishtext:(id)sender {
}

- (IBAction)gotoLogin:(id)sender {
  
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteLogin"];
    [self.navigationController pushViewController:foundVC animated:YES];
  
}

- (IBAction)signup:(id)sender {
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *firstname = [self.firstnamefield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastname = [self.lastnamefield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phone = [self.phonefield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    

    if (![Stripe defaultPublishableKey]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
                                                          message:@"Please specify a Stripe Publishable Key in Constants.m"
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
   
    
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0 || [firstname length] == 0 || [lastname length] == 0 || [phone length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"All fields are must!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        newUser[@"Firstname"] = firstname;
        newUser[@"Lastname"] = lastname;
        newUser[@"Phone"] = phone;
                
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                PFInstallation *installation = [PFInstallation currentInstallation];
                installation[@"userid"] = [newUser objectId];
                [installation saveInBackground];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}


@end
