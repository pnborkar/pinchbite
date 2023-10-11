//
//  ShowOrderTableVC.m
//  NoteApp
//
//  Created by Pramod Borkar on 10/14/14.
//  Copyright (c) 2014 Joyce Echessa. All rights reserved.
//


/* Code help links::
 // http://blog.parse.com/2012/05/17/new-many-to-many/ //PFRelation
 // https://www.parse.com/questions/pftableviewcell-with-imageview-with-storyboards // for images ?
 // https://parse.com/tutorials/saving-images // for images
*/

#import "ShowOrderTableVC.h"

#import <Parse/Parse.h>

@interface ShowOrderTableVC ()

@end

@implementation ShowOrderTableVC

@synthesize restaurant;
@synthesize menudata;
@synthesize user;

/*
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Orders"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Orders";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 7;
    }
    return self;
}*/



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"In Order viewdidload >> %@", [self.restaurant objectId]);
    NSLog(@"In Order viewdidload >> %@", self.menudata );
    // **IMP .. self.menudate.count is erroring out because its not init alloc ???
    // Do any additional setup after loading the view.
  /*
    // Set the label..
    _scoreLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(15, 0.0, self.view.bounds.size.width, 43.0) ];
    _scoreLabel.textAlignment =  UIViewAutoresizingNone;
    _scoreLabel.textColor = [UIColor colorWithRed:131/255.0 green:76/255.0 blue:53/255.0 alpha:1.0];
    _scoreLabel.backgroundColor = [UIColor whiteColor];
    _scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:(14.0)];
    [self.view addSubview:_scoreLabel];
    _scoreLabel.text = [NSString stringWithFormat: @"%@' Order", [self.restaurant objectForKey:@"Name"]];
  */
    
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.menucount;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"OrderCell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //NSLog(@"order ? %@ ", object);
    
    cell.textLabel.text = [object objectForKey:@"Instructions"];;
    //NSLog( @" Restaurant in menu item %@" , [object objectForKey:@"restaurant"] );
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    
    /*
   PFObject *menu = [menudata objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[menu objectForKey:@"Name"]];
    [[cell detailTextLabel] setText:[menu objectForKey:@"Ingredients"]];
    */
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    recipeImageView.image = [UIImage imageNamed:@"menu"];
    
    PFObject *menu = [menudata objectAtIndex:[indexPath row]];
    NSLog ( @"menu :: %@", menu);
    //[[cell textLabel] setText:[menu objectForKey:@"Name"]];
    UILabel *menulabel = (UILabel *)[cell viewWithTag:101];
    UILabel *menudetails = (UILabel *)[cell viewWithTag:102];
    menulabel.text = [menu objectForKey:@"Name"];
    menudetails.text = [menu objectForKey:@"Ingredients"];
    UILabel *pricelabel = (UILabel *)[cell viewWithTag:103];
    pricelabel.text = [menu objectForKey:@"Price"];
    
    return cell;
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 //   [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//}


- (IBAction)sendOrder:(id)sender {
    
    if ([menudata count] == 0){
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hmmm!"
                                                        message:@"Choose the menu!"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    } else {
    NSMutableArray *menuitem = [[NSMutableArray alloc] initWithObjects:nil];
    PFObject *newOrder = [PFObject objectWithClassName:@"Orders"];
    newOrder[@"restaurant"] = self.restaurant;
    newOrder[@"user"] = [PFUser currentUser];
    newOrder[@"numPeople"] = @2;
    newOrder[@"isTakenCare"] = @NO;
    newOrder[@"Status"] = @"New";
    newOrder[@"Instructions"] = @"2 cokes pls. when we come in";
    
    PFRelation *relation = [newOrder relationForKey:@"menu"];
    for (PFObject *obj in self.menudata) {
        [relation addObject:obj];
        [menuitem addObject:[NSString stringWithFormat:@"%@:%@",[obj objectId], @"2"]];
    }
    
    newOrder[@"menuitems"] = menuitem;
    [newOrder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Your Order sent !");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Your Order sent!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            //[self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                                message:[error.userInfo objectForKey:@"error"]
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
    }
}
@end
