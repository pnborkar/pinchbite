//
//  PinchbiteOrders_TVC.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/24/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

//// http://blog.parse.com/2012/05/17/new-many-to-many/

#import "PinchbiteOrders_TVC.h"
#import <Parse/Parse.h>

@interface PinchbiteOrders_TVC ()

@end

@implementation PinchbiteOrders_TVC

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
        self.objectsPerPage = 5;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"restauranticon.png"]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(gotorests:)];
    
    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:11];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [back setTitleTextAttributes:attributes forState:UIControlStateNormal];
    back.enabled = YES;
    self.navigationItem.leftBarButtonItem = back;
    
    CGRect frame = CGRectMake(0, 0, 60, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:13];
    label.textColor = [UIColor darkGrayColor];
    label.text = @"Your Orders";
    self.navigationItem.titleView = label;
}

- (IBAction)gotorests:(id)sender {
    NSLog(@"go to rest");
    
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantsVC"];
    [self.navigationController pushViewController:foundVC animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == self.objects.count)
    {
        if ([tableView.indexPathsForVisibleRows containsObject:indexPath])
        {
            double delayInSeconds = 0.3; dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self loadNextPage]; });
        }
    }
    
}



// Override to customize the look of the cell that allows the user to load the next page of objects.
// The default implementation is a UITableViewCellStyleDefault cell with simple labels.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"  ... loading more orders ...";
    cell.textLabel.font =  [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
    
    return cell;
}

- (PFQuery *)queryForTable {
    PFUser *curuser = [PFUser currentUser];
    // Create a query
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"userid" equalTo:[curuser objectId]];
    [query orderByDescending:@"updatedAt"];
  
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"OrderedCell";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    UILabel *totalamt = (UILabel *)[cell viewWithTag:33];
    totalamt.text = [object objectForKey:@"totalAmt"];
    
    UITextView *menulabel = (UITextView *)[cell viewWithTag:32];
    NSMutableArray *menuitems = [[NSMutableArray alloc] init];
    
    for (NSString *str in [object objectForKey:@"menuitems"]) {
        
        NSRange start = [str rangeOfString:@":"];
        NSRange end = [str rangeOfString:@":$"];
        NSRange needleRange = NSMakeRange(start.location+1, end.location - start.location -1);
        NSString *menu = [str substringWithRange:needleRange];
        
        [menuitems addObject:[NSString stringWithFormat:@"%@", menu]];
        
    }
 
    menulabel.text =  [menuitems componentsJoinedByString:@"\n"];
    
    UILabel *numpeople = (UILabel *)[cell viewWithTag:37];
    numpeople.text = [NSString stringWithFormat:@"%d", [[object objectForKey:@"numPeople"] intValue]];
    
    UILabel *ordertype = (UILabel *)[cell viewWithTag:34];
    ordertype.text = [object objectForKey:@"ordertype"];
    
  
    UILabel *status = (UILabel *)[cell viewWithTag:35];
    status.text = [object objectForKey:@"Status"];

    if ([status.text isEqual:@"Pending"]) {
        status.textColor =  [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
    if ([status.text isEqual:@"Cancelled"]) {
        status.textColor =  [UIColor colorWithRed:178.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    }
    if ([status.text isEqual:@"Confirmed"]) {
        status.textColor =  [UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0];
    }
    

    UILabel *restname = (UILabel *)[cell viewWithTag:31];
    restname.text = [object objectForKey:@"restaurantname"];

   // UILabel *totalamt = (UILabel *)[cell viewWithTag:34];
   //totalamt.text = [object objectForKey:@"totalAmt"];

    return cell;
}

@end
