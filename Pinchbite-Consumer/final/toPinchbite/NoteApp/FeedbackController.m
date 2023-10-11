//
//  FeedbackController.m
//  Feedback
//
//  Created by Pramod Borkar on 11/5/14.
//  Copyright (c) 2014 Pinchbite. All rights reserved.
//

#import "FeedbackController.h"
#import <Parse/Parse.h>

@interface FeedbackController ()

@end

@implementation FeedbackController
@synthesize isCoupons;
@synthesize isMenuIntuitive;
@synthesize isOrderingEasy;
@synthesize doBooktables;
@synthesize doDelivery;
@synthesize doPreorder;
@synthesize comments;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_restaurantfield addTarget:self action:@selector(finishtext:)
           forControlEvents:UIControlEventEditingDidEndOnExit];
}


- (IBAction)finishtext:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendfeedback:(id)sender {
    PFObject *newfeedback = [PFObject objectWithClassName:@"Feedback"];
    newfeedback[@"isOrderEasy"] = self.isOrderingEasy.selectedSegmentIndex == 0 ? @(YES) : @(NO);
    newfeedback[@"isMenuIntuitive"] = self.isMenuIntuitive.selectedSegmentIndex == 0 ? @(YES) : @(NO);
    newfeedback[@"isCoupons"] = self.isCoupons.selectedSegmentIndex == 0 ? @(YES) : @(NO);
    newfeedback[@"doPreorder"] = self.doPreorder.selectedSegmentIndex == 0 ? @(YES) : @(NO);
    newfeedback[@"doBooktables"] = self.doBooktables.selectedSegmentIndex == 0 ? @(YES) : @(NO);
    newfeedback[@"doDelivery"] = self.doDelivery.selectedSegmentIndex == 0 ? @(YES) : @(NO);
    newfeedback[@"comments"] = self.comments.text;
    newfeedback[@"restaurantName"] = _restaurantfield.text;
    PFUser *currentUser = [PFUser currentUser];

    newfeedback[@"user"] = currentUser;
    [newfeedback saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    }];
    
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteProfile"];
    [self.navigationController pushViewController:foundVC animated:YES];

}

- (IBAction)keyboarddone:(id)sender {
    
    [comments resignFirstResponder];
}
@end
