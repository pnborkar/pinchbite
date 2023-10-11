//
//  FeedbackController.h
//  Feedback
//
//  Created by Pramod Borkar on 11/5/14.
//  Copyright (c) 2014  Pinchbite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FeedbackController : UIViewController
- (IBAction)sendfeedback:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isMenuIntuitive;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isOrderingEasy;
@property (weak, nonatomic) IBOutlet UISegmentedControl *doPreorder;
@property (weak, nonatomic) IBOutlet UISegmentedControl *doBooktables;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isCoupons;
@property (weak, nonatomic) IBOutlet UISegmentedControl *doDelivery;
@property (weak, nonatomic) IBOutlet UITextView *comments;
- (IBAction)keyboarddone:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *restaurantfield;

@end
