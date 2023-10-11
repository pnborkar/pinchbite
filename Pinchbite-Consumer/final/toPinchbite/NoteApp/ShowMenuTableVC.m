//
//  ShowMenuTableVC.m
//  NoteApp
//
//  Created by Pramod Borkar on 10/13/14.
//  Copyright (c) 2014 Joyce Echessa. All rights reserved.
//

#import "ShowMenuTableVC.h"
#import "Restaurants_TVC.h"

#import <Parse/Parse.h>

@interface ShowMenuTableVC ()

@end

@implementation ShowMenuTableVC
@synthesize restaurant;
//@synthesize menudata;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Menu"];
    //self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Menu";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 7;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Restaurant id >> %@", [self.restaurant objectId]); // not reading bcoz Post is added to segue)
    
    _menudata = [[NSMutableArray alloc] initWithObjects: nil];
    /*PFQuery *query = [PFQuery queryWithClassName:@"Menu"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         
         if (!error) {
             // The find succeeded.
             //NSLog(@"Successfully retrieved Restaurants records. >>> %d", objects.count);
             for (PFObject *object in objects){
                 NSLog(@"Name of the rest: %@", [object objectForKey:@"Name"]);
                 [_menudata addObject:object];
                 
             }
             
         } else {
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
     }];
    */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//hmm ok
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    NSArray *restaurants;
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"restaurant"];

    PFQuery *query2 = [PFQuery queryWithClassName:@"Restaurants"];
    [query2 includeKey:@"objectId"];

    
    //NSArray *restaurants = [NSArray arrayWithObjects:@"Q9CjFB4ALc",nil];
    [query whereKey:@"restaurant" matchesKey:@"objectId" inQuery:query2];
     //[query whereKey:@"restaurant" equalTo:[NSString stringWithFormat:@"<Restaurants:Q9CjFB4ALc>"]];
    

    //[query whereKey:@"objectId" equalTo:@"o8wzwmNi8R"];
    //[query whereKeyExists:@"restaurant"];
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSLog(@"in menu method");
    static NSString *CellIdentifier = @"Cell";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewRowActionStyleNormal reuseIdentifier:CellIdentifier];
    }
    
    /*PFObject *menu = [_menudata objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[menu objectForKey:@"Name"]];
    NSLog(@"in menu cell %@ ",[menu objectForKey:@"Name"]);
    NSLog(@"in menu cell %@ ",[menu objectForKey:@"Ingredients"]);
    [[cell detailTextLabel] setText:[menu objectForKey:@"Ingredients"]];
    */
    NSLog(@" menu item %@", object);
    cell.textLabel.text = [object objectForKey:@"Name"];
    cell.detailTextLabel.text = [object objectForKey:@"Ingredients"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    NSLog  (@"select menu");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
