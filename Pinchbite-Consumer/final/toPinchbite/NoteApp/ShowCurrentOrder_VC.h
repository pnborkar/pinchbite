//
//  ShowCurrentOrder_VC.h
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/19/14.
//  Copyright (c) 2014 PinchBite, Inc All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ShowCurrentOrder_VC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *orderview;

@property (nonatomic, weak) NSMutableArray *menudata; // Array of Menu objects
@property (nonatomic, weak) PFObject *restaurant; // Restaurant order is placed
@property (nonatomic, weak) PFObject *user; //User who is ordering
@property (nonatomic) NSInteger *menucount; //User who is ordering
@property (weak, nonatomic) IBOutlet UILabel *serviceoption;
@property (weak, nonatomic) IBOutlet UILabel *totalamtlabel;
@property (weak, nonatomic) IBOutlet UILabel *taxamtlabel;
@property (weak, nonatomic) IBOutlet UIView *deliveryoptionview;

@property (nonatomic) NSMutableArray *menuitems; //Holds menutimes (menuname:$:#)
@property (nonatomic) double tax_percent; // tax that needs to be applied . as per restaurant
@property (weak, nonatomic) IBOutlet UIDatePicker *arrivaltime;
@property (nonatomic) NSMutableDictionary *holdmenuitems;
@property (nonatomic) NSMutableDictionary *holdmenudata;
- (IBAction)sendOrder:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *numpeople;
@property (weak, nonatomic) IBOutlet UIButton *canceldelivery;
@property (weak, nonatomic) IBOutlet UIStepper *setpeople;
- (IBAction)peopleaction:(id)sender;
- (IBAction)keyboarddone:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *subtotalamtlabel;
@property (weak, nonatomic) IBOutlet UITextField *deliveryaddress2;
- (IBAction)canceldeliveryaddress:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *instructionsview;
- (IBAction)takeaddress:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *deliveryaddress1;

@property (nonatomic) NSString *smsmenu ;
@end
