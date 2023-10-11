//
//  ShowOrderTableVC.h
//  NoteApp
//
//  Created by Pramod Borkar on 10/14/14.
//  Copyright (c) 2014 Joyce Echessa. All rights reserved.
//

#import <Parse/Parse.h>

@interface ShowOrderTableVC : UIViewController

@property (nonatomic, weak) NSMutableArray *menudata; // Array of Menu objects
@property (nonatomic, weak) PFObject *restaurant; // Restaurant order is placed
@property (nonatomic, weak) PFObject *user; //User who is ordering
@property (nonatomic) NSInteger *menucount; //User who is ordering

@property (strong, nonatomic) UILabel *scoreLabel;
- (IBAction)sendOrder:(id)sender;

@end
