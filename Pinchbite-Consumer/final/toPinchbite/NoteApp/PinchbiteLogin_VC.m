//
//  PinchbiteLogin_VC.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/16/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import "PinchbiteLogin_VC.h"
#import <Parse/Parse.h>

@interface PinchbiteLogin_VC ()

@end

@implementation PinchbiteLogin_VC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"restauranticon.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(gotorests:)];
    
    [self.usernameTextField addTarget:self
                       action:@selector(finishtext:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(finishtext:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    
    UIView *bgview = (UIView *)[self.view viewWithTag:400];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"profile_bg.jpg"]];
    bgview.backgroundColor = background;
    
    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:11];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [back setTitleTextAttributes:attributes forState:UIControlStateNormal];
    back.enabled = YES;
    self.navigationItem.leftBarButtonItem = back;
    
    
    CGRect frame = CGRectMake(0, 0, 50, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:13];
    label.textColor = [UIColor darkGrayColor];
    label.text = @"Login";
    self.navigationItem.titleView = label;
    
}

- (IBAction)gotorests:(id)sender {
    NSLog(@"go to rest");
    
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantsVC"];
    [self.navigationController pushViewController:foundVC animated:YES];
    
}


- (IBAction)finishtext:(id)sender {
}

- (IBAction)login:(id)sender {
    NSString *username = [[self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"You have to enter a username and password"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                    message:[error.userInfo objectForKey:@"error"]
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                //Update userid so we can push notifications
                PFInstallation *installation = [PFInstallation currentInstallation];
                installation[@"userid"] = [[PFUser currentUser] objectId];
                [installation saveInBackground];
                
                //[self dismissViewControllerAnimated:YES completion:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                

            }
        }];
    }
}

@end
