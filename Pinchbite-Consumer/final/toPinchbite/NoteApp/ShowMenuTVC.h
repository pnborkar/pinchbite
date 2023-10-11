//
//  ShowMenuTVC.h
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/19/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import <Parse/Parse.h>

@interface ShowMenuTVC : PFQueryTableViewController <UITableViewDelegate>

@property (nonatomic, weak) PFObject *restaurant; //Restaurant for

@property (nonatomic, strong) NSMutableArray *menudata;

@property (nonatomic) NSMutableDictionary *holdmenudata;

@property (nonatomic) NSMutableDictionary *allmenuitemsdata;
@property (weak, nonatomic) IBOutlet UILabel *r_address;
@property (weak, nonatomic) IBOutlet UILabel *r_type;
@property (weak, nonatomic) IBOutlet UITextView *r_desc;
@property (weak, nonatomic) IBOutlet UIButton *showmenubutton;

@end
