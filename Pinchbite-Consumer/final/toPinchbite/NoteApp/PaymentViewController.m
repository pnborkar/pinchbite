//
//  PaymentViewController.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/22/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import "PaymentViewController.h"
#import "Stripe.h"
#import "MBProgressHUD.h"
#import "PTKView.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface PaymentViewController () <PTKViewDelegate>

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    // Do any additional setup after loading the view.
   
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"Charge Card";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    saveButton.enabled = YES;
    self.navigationItem.rightBarButtonItem = saveButton;
    self.paymentView = [[PTKView alloc] initWithFrame:CGRectMake(15, 65, 290, 45)];
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) paymentView:(PTKView*)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
    self.navigationItem.rightBarButtonItem.enabled = valid;
    
    
}

- (IBAction)save:(id)sender {
    if (![self.paymentView isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
                                                          message:@"Please specify a Stripe Publishable Key in Constants.m"
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
                             //[self hasError:error];
                         } else {
                             //[self hasToken:token];
                             NSLog(@"TOKEN::: %@", token);
                         }
                     }];
}


- (void)hasError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


- (void)hasToken:(STPToken *)token {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *chargeParams = @{
                                   @"token": token.tokenId,
                                   @"currency": @"usd",
                                   @"amount": @"100", // this is in cents (i.e. $10)
                                   };
    
    /// WILL REMOVE THIS CODE AND NEED TO SAVE THE TOKEN SOMEWHERE.. SO WE CAN USE THIS LATER.!!!
    
    if (!ParseApplicationId || !ParseClientKey) {
        UIAlertView *message =
        [[UIAlertView alloc] initWithTitle:@"Todo: Submit this token to your backend"
                                   message:[NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                            @"instructions in the README to set up Parse as an example backend, or use this "
                                            @"token to manually create charges at dashboard.stripe.com .",
                                            token.tokenId]
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                         otherButtonTitles:nil];
        
        [message show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your account's
    [PFCloud callFunctionInBackground:@"charge"
                       withParameters:chargeParams
                                block:^(id object, NSError *error) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (error) {
                                        [self hasError:error];
                                        return;
                                    }
                                    [self.presentingViewController dismissViewControllerAnimated:NO
                                                                                      completion:^{
                                                                                          [[[UIAlertView alloc] initWithTitle:@"Payment Succeeded"
                                                                                                                      message:nil
                                                                                                                     delegate:nil
                                                                                                            cancelButtonTitle:nil
                                                                                                            otherButtonTitles:@"OK", nil] show];
                                                                                      }];
                                }];
}



@end
