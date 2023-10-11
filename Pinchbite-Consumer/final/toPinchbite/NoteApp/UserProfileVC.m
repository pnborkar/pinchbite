//
//  UserProfileVC.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/24/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import "UserProfileVC.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "PTKView.h"
#import "Stripe.h"
#import "Constants.h"

@interface UserProfileVC () <PTKViewDelegate>

@end

@implementation UserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *currentUser = [PFUser currentUser];
    
    UILabel *namelabel = (UILabel *)[self.view viewWithTag:71];
    namelabel.text = [NSString stringWithFormat:@"%@ %@", [currentUser objectForKey:@"Firstname"], [currentUser objectForKey:@"Lastname"]];

    //UIView *bgview = (UIView *)[self.view viewWithTag:400];
    //UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"profile3.jpg"] ];
    //bgview.backgroundColor = background;
    
    UILabel *email = (UILabel *)[self.view viewWithTag:72];
    email.text = currentUser.email;
    
    UILabel *phonelabel = (UILabel *)[self.view viewWithTag:73];
    phonelabel.text = [currentUser objectForKey:@"Phone"];

    UILabel *cardlabel = (UILabel *)[self.view viewWithTag:74];
    cardlabel.text = [currentUser objectForKey:@"authcard"];
    NSLog(@"CARD: %@", [currentUser objectForKey:@"authcard"]);
    UIButton *deletecardbutton = (UIButton *)[self.view viewWithTag:76];
    UILabel *cardinfolabel = (UILabel *)[self.view viewWithTag:61];
    UILabel *paymentoptionlabel = (UILabel *)[self.view viewWithTag:62];
    UIButton *savecardbutton = (UIButton *)[self.view viewWithTag:77];
   
    
    
    // Look out for this later!!! Can't find keyplane that supports type 4 for keyboard iPhone-Portrait-NumberPad; using // 3876877096_Portrait_iPhone-Simple-Pad_Default
    if ( [currentUser objectForKey:@"authcard"] == nil || [[currentUser objectForKey:@"authcard"]  isEqual:@""]) {
        self.paymentView = [[PTKView alloc] initWithFrame:CGRectMake(20, 270, 290, 55)];
        
        self.paymentView.delegate = self;
        [self.view addSubview:self.paymentView];
        cardlabel.text = @"Currently there is no payment saved!";
        deletecardbutton.hidden = YES;
        cardinfolabel.hidden = YES;
        paymentoptionlabel.hidden = NO;
        savecardbutton.hidden = NO;
        [self reloadInputViews];
       
    }else{
        paymentoptionlabel.hidden = YES;
        savecardbutton.hidden = YES;
    }
    
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"restauranticon.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(gotorests:)];
    
    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:12];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [back setTitleTextAttributes:attributes forState:UIControlStateNormal];
    back.enabled = YES;
    self.navigationItem.leftBarButtonItem = back;
    
    
    CGRect frame = CGRectMake(0, 0, 50, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:14];
    label.textColor = [UIColor darkGrayColor];
    label.text = @"Profile";
    self.navigationItem.titleView = label;
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(saveprofile:)];
    font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:12];
    attributes = @{NSFontAttributeName: font};
    [save setTitleTextAttributes:attributes forState:UIControlStateNormal];
    save.enabled = YES;
    self.navigationItem.rightBarButtonItem = save;
    
    [_emailfield addTarget:self action:@selector(finishtext:)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
    [_phonefield addTarget:self action:@selector(finishtext:)
          forControlEvents:UIControlEventEditingDidEndOnExit];
    [_passwdfield addTarget:self action:@selector(finishtext:)
          forControlEvents:UIControlEventEditingDidEndOnExit];
    
    _phonefield.delegate = self;

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 10
    
    NSUInteger newLength = [_phonefield.text length] + [string length] - range.length;
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


- (IBAction)saveprofile:(id)sender {
    NSLog(@"Save Profile");
    PFUser *currentUser = [PFUser currentUser];
    
    
    [currentUser setObject:_phonefield.text forKey:@"Phone"];
    [currentUser setObject:_emailfield.text forKey:@"email"];
    if (_passwdfield.enabled) { //take it only if enabled or reset is hit
        currentUser.password = _passwdfield.text;
    }
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The currentUser saved successfully.
        } else {
            // There was an error saving the currentUser.
        }
    }];
    _passwdfield.enabled = NO;
  
}


- (IBAction)gotorests:(id)sender {
    NSLog(@"go to rest");
    
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantsVC"];
    [self.navigationController pushViewController:foundVC animated:YES];
    
}
- (void) paymentView:(PTKView*)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
    self.navigationItem.rightBarButtonItem.enabled = valid;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)savecard:(id)sender {
    if (![self.paymentView isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                          message:@"Please contact PinchBite Administrator. No keys found!"
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    [Stripe createTokenWithCard:card
                     completion:^(STPToken *token, NSError *error) {
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         if (error) {
                             [self hasError:error];
                         } else {
                             [self hasToken:token];
                             NSLog(@"TOKEN::: %@", token);
                         }
                     }];
    
}

- (IBAction)deletecard:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:@"" forKey:@"authcard"];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
        } else {
        }
    }];
    
    NSDictionary *chargeParams = @{
                                   @"customer": [currentUser objectId]
                                   };

    
    [PFCloud callFunctionInBackground:@"deletecardforcustomer"
                       withParameters:chargeParams
                                block:^(id object, NSError *error) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (error) {
                                        [self hasError:error];
                                        return;
                                    }
                                    [self.presentingViewController dismissViewControllerAnimated:NO
                                                                                      completion:^{
                                                                                          [[[UIAlertView alloc] initWithTitle:@"Customer deleted!"
                                                                                   message:nil                        delegate:nil               cancelButtonTitle:nil
                                                                                                            otherButtonTitles:@"OK", nil] show];
                                                                                      }];
                                }];
    
    [self viewDidLoad];
}

- (void)hasError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:@"Card Error: Please check your card"
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


- (void)hasToken:(STPToken *)token {
    PFUser *curuser = [PFUser currentUser];
    NSLog(@"Token:::  %@", token.tokenId);
    NSLog(@"Customer::  %@ %@", [curuser email] , [curuser objectId]);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *chargeParams = @{
                                   @"token": token.tokenId,
                                   @"email": [curuser email],
                                   @"description": [NSString stringWithFormat:@"Pinchbite Customer : %@ %@ (#%@)", [curuser objectForKey:@"Firstname"], [curuser objectForKey:@"Lastname"], [curuser objectForKey:@"Phone"]],
                                   @"id": [curuser objectId]
                                   };
    
    /// WILL REMOVE THIS CODE AND NEED TO SAVE THE TOKEN SOMEWHERE.. SO WE CAN USE THIS LATER.!!!
    
    if (!ParseApplicationId || !ParseClientKey) {
        UIAlertView *message =
        [[UIAlertView alloc] initWithTitle:@"Error!"
                                   message:[NSString stringWithFormat:@"Please contact PinchBite Administrator!\n\nSorry for inconvenience.",
                                            token.tokenId]
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                         otherButtonTitles:nil];
        
        //[message show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
    
    NSLog(@"is User created in Stripe: %@", [curuser objectForKey:@"isStripeCreated"]);
    if ([[curuser objectForKey:@"isStripeCreated"] boolValue]) {
        NSLog(@"Updating  customer data");
        [PFCloud callFunctionInBackground:@"updatecustomer"
                           withParameters:chargeParams
                                    block:^(id object, NSError *error) {
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        if (error) {
                                            NSLog(@"ERROR WHILE UPDATING!!!!");
                                            [self hasError:error];
                                            return;
                                        }else {
                                             NSLog(@"new customer!!!!");
                                             [self updateCustomerInfo:@"ok"];
                                        }
                                        /*
                                        [self.presentingViewController dismissViewControllerAnimated:NO
                                                                                          completion:^{
                                                                                              [[[UIAlertView alloc] initWithTitle:@"Payment Succeeded"
                                                                                                                          message:nil
                                                                                                                         delegate:nil
                                                                                                                cancelButtonTitle:nil
                                                                                                                otherButtonTitles:@"OK", nil] show];
                                                                                          }];*/
                                    }];

    }else {
    NSLog(@"Creating a  new customer ");
    [PFCloud callFunctionInBackground:@"createcustomer"
                       withParameters:chargeParams
                                block:^(id object, NSError *error) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (error) {
                                        [self hasError:error];
                                        return;
                                    }else {
                                        NSLog(@"no error !!!!");
                                        [self updateCustomerInfo:@"ok"];
                                    }
                                    
                                    /*
                                    [self.presentingViewController dismissViewControllerAnimated:NO
                                                                                      completion:^{
                                                                                          [[[UIAlertView alloc] initWithTitle:@"Payment Succeeded"
                                                                                                                      message:nil
                                                                                                                     delegate:nil
                                                                                                            cancelButtonTitle:nil
                                                                                                            otherButtonTitles:@"OK", nil] show];
                                                                                      }];*/
                                }];
        
    
    }
    // Next clean up the view and save the credit card info to User table
    /*
    PFUser *currentUser = [PFUser currentUser];
    NSString *card = self.paymentView.card.number;
    NSString *newcard = [card substringWithRange:NSMakeRange(card.length -4, 4)];
    [currentUser setObject:[NSString stringWithFormat:@"**** **** **** %@" ,newcard] forKey:@"authcard"];

    currentUser[@"isStripeCreated"] = @(YES);
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The currentUser saved successfully.
        } else {
            // There was an error saving the currentUser.
        }
    }];
    
    
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteProfile"];
    [self.navigationController pushViewController:foundVC animated:YES];
    */

}


-(void) updateCustomerInfo: (NSString *) x {
    
    PFUser *currentUser = [PFUser currentUser];
    NSString *card = self.paymentView.card.number;
    NSString *newcard = [card substringWithRange:NSMakeRange(card.length -4, 4)];
    [currentUser setObject:[NSString stringWithFormat:@"**** **** **** %@" ,newcard] forKey:@"authcard"];
    
    currentUser[@"isStripeCreated"] = @(YES);
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The currentUser saved successfully.
        } else {
            // There was an error saving the currentUser.
        }
    }];
    
    
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteProfile"];
    [self.navigationController pushViewController:foundVC animated:YES];
    
}
- (IBAction)logout:(id)sender {
    NSLog(@"Logging out : %@", [PFUser currentUser]);
    [PFUser logOut];
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantsVC"];
    [self.navigationController pushViewController:foundVC animated:YES];
}

- (IBAction)resetpasswd:(id)sender {
    _passwdfield.enabled = YES;
}
@end
