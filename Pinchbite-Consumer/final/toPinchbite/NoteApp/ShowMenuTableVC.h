//
//  ShowMenuTableVC.h
//  NoteApp
//
//  Created by Pramod Borkar on 10/13/14.
//  Copyright (c) 2014 Joyce Echessa. All rights reserved.
//

#import <Parse/Parse.h>

@interface ShowMenuTableVC : PFQueryTableViewController

@property (nonatomic, strong) PFObject *restaurant;
@property (nonatomic, strong) NSMutableArray *menudata;

@end
