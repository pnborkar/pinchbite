//
//  ShowMenuTVC.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/14/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import "ShowMenuTVC.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ShowCurrentOrder_VC.h"
#import "PinchSwitch.h"


@interface ShowMenuTVC ()

@end

@implementation ShowMenuTVC

@synthesize restaurant;
@synthesize menudata;
@synthesize holdmenudata;
@synthesize allmenuitemsdata;

@synthesize r_address;
@synthesize r_desc;
@synthesize r_type;

// ... initWithCoder....
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Menu"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Menu";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    self.loadingViewEnabled = YES;
    self.view.hidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    menudata = [[NSMutableArray alloc] initWithObjects: nil];
    holdmenudata = [[NSMutableDictionary alloc] init];
    allmenuitemsdata  = [[NSMutableDictionary alloc] init];
    
    //UITextView *restaurantname = (UITextView *)[self.view viewWithTag:89];
    self.r_desc.text = [self.restaurant objectForKey:@"description"];
    self.r_type.text =[self.restaurant objectForKey:@"type"];
    self.r_address.text = [self.restaurant objectForKey:@"Address"];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(gotorestautants:)];
    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:13];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [saveButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    saveButton.enabled = YES;
    self.navigationItem.leftBarButtonItem = saveButton;
    
    CGRect frame = CGRectMake(0, 0, 45, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    //label.font = [UIFont boldSystemFontOfSize:8.0];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:15];
    label.textColor = [UIColor darkGrayColor];
    label.text = [NSString stringWithFormat:@"%@", [self.restaurant objectForKey:@"Name"]];
    self.navigationItem.titleView = label;
    
    
    UIBarButtonItem *donebutton = [[UIBarButtonItem alloc] initWithTitle:@"Checkout" style:UIBarButtonItemStyleDone target:self action:@selector(sendtocurorder:)];
    font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:14];
    attributes = @{NSFontAttributeName: font};
    [donebutton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    donebutton.enabled = NO;
    self.navigationItem.rightBarButtonItem = donebutton;
    
    BOOL getinline = [[self.restaurant objectForKey:@"isGetLine"] boolValue];
    if (getinline) {
        _showmenubutton.enabled = NO;
    }else {
        _showmenubutton.hidden = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"index %d", indexPath.row);
    PinchSwitch *switchs = (PinchSwitch *)[cell viewWithTag:98];
    if ([switchs isOn]) {
        switchs.on = NO;
    }else {
        switchs.on = YES;
    }
    
    NSString *orderid = switchs.orderid;
    
    PFObject *menuobject = [allmenuitemsdata valueForKey:orderid];
    NSLog (@"menuobject : %@", [menuobject objectForKey:@"Name"]);
    if (switchs.on) {
        [holdmenudata setValue:menuobject forKey:[menuobject objectId]];
    }else{
        [holdmenudata removeObjectForKey:[menuobject objectId]];
    }
    if ( holdmenudata.count > 0 ) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(void)sendtocurorder:(id)sender
{
    [self performSegueWithIdentifier:@"showorder" sender:sender];
}


- (IBAction)gotorestautants:(id)sender {
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantsVC"];
    [self.navigationController pushViewController:foundVC animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadObjects];
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
 cell.textLabel.text = @"  ... loading more menu items ...";
 cell.textLabel.font =  [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
 
 return cell;
 }
 

   //*****Pramod .. if the restaurant has lot of menu .. if we load less in the beginning it will give out of bounds exception here ....

  // ... queryForTable...
  // Override to customize what kind of query to perform on the class. The default is to query for
  // all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    //NSArray *restaurants;
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"restaurant"];
    [query addAscendingOrder:@"priority"];
    
    //PFQuery *query2 = [PFQuery queryWithClassName:@"Restaurants"];
    NSLog(@"rest id *** :: >> %@ ", [self.restaurant objectId]);
    //[query2 whereKey:@"objectId" equalTo:[self.restaurant objectId]];
    //[query whereKey:@"restaurant" matchesQuery:query2];
   
    [query whereKey:@"restaurant" equalTo:self.restaurant]; //HMM IT WORKED!!!
    //[query whereKeyExists:@"restaurant"];
    return query;
}

// ...cellforRowAtIndexPath ...
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"MenuCell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //cell.backgroundColor = indexPath.row % 2 ? [UIColor groupTableViewBackgroundColor] : [UIColor clearColor];

  
    NSString *menuitem = [object objectForKey:@"Name"];
    if ( menuitem == nil ) {
        cell.textLabel.text = @"Sorry! No Menus updated !";
    }
  
    UILabel *restlabel = (UILabel *)[cell viewWithTag:91];
    restlabel.text = [object objectForKey:@"Name"];
    
    UILabel *detailslabel = (UILabel *)[cell viewWithTag:92];
    detailslabel.text = [object objectForKey:@"Ingredients"];
    
    //UIImageView *imageview = (UIImageView *)[cell viewWithTag:90];
    UILabel *pricelabel = (UILabel *)[cell viewWithTag:93];
    pricelabel.text = [NSString stringWithFormat:@"%.2f",[[object objectForKey:@"Price"] doubleValue]];

    UILabel *descriptionlabel = (UILabel *)[cell viewWithTag:94];
    descriptionlabel.text = [NSString stringWithFormat:@"%@",[object objectForKey:@"description"]];

    /* NOT SHOWING PHOTO NOW...PFFile  *photo = [object objectForKey:@"image"];
    if (photo)
    {
        imageview.image = [UIImage imageNamed:@"menu"];
        [photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            // Now that the data is fetched, update the cell's image property.
            imageview.image = [UIImage imageWithData:data];
        }];
    }else{
        imageview.image = [UIImage imageNamed:@"menu"];
    } */
    
    //NSLog( @" Restaurant in menu item %@" , [object objectForKey:@"restaurant"] );
    PinchSwitch *switchs = (PinchSwitch *)[cell viewWithTag:98];
    switchs.transform = CGAffineTransformMakeScale(0.71, 0.71);
    UILabel *typelabel = (UILabel *)[cell viewWithTag:97];
    UILabel *colorlabel = (UILabel *)[cell viewWithTag:121];
    
    if ( [[object objectForKey:@"priority"] integerValue] == 1) {
        typelabel.textColor = [UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0];
        colorlabel.backgroundColor = [UIColor colorWithRed:154.0/255.0 green:205.0/255.0 blue:50.0/255.0 alpha:1.0];
    }
    if ( [[object objectForKey:@"priority"] integerValue] == 2) {
        typelabel.textColor = [UIColor colorWithRed:218.0/255.0 green:165.0/255.0 blue:32.0/255.0 alpha:1.0];
        colorlabel.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:165.0/255.0 blue:32.0/255.0 alpha:1.0];
    }
    if ( [[object objectForKey:@"priority"] integerValue] == 3) {
        typelabel.textColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
        colorlabel.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:144.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
    
    if ( [[object objectForKey:@"priority"] integerValue] == 4) {
        typelabel.textColor = [UIColor colorWithRed:139.0/255.0 green:69.0/255.0 blue:19.0/255.0 alpha:1.0];
        colorlabel.backgroundColor = [UIColor colorWithRed:139.0/255.0 green:69.0/255.0 blue:19.0/255.0 alpha:1.0];
    }
    if ( [[object objectForKey:@"priority"] integerValue] == 5) {
        typelabel.textColor = [UIColor colorWithRed:221.0/255.0 green:160.0/255.0 blue:221.0/255.0 alpha:1.0];
        colorlabel.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:160.0/255.0 blue:221.0/255.0 alpha:1.0];
    }
    
    if ( [[object objectForKey:@"priority"] integerValue] == 6) {
        typelabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:128.0/255.0 alpha:1.0];
        colorlabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:128.0/255.0 alpha:1.0];
    }
    
    if ( [[object objectForKey:@"priority"] integerValue] > 6) {
        if ( [[object objectForKey:@"priority"] integerValue] % 2) {
            typelabel.textColor = [UIColor colorWithRed:184.0/255.0 green:134.0/255.0 blue:11.0/255.0 alpha:1.0];
            colorlabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:215.0/255.0 blue:0.0/255.0 alpha:1.0];
        }else {
            typelabel.textColor = [UIColor darkGrayColor];
            colorlabel.backgroundColor = [UIColor darkGrayColor];
        }
    }
    //[typelabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];// -M_PI / 2
    typelabel.text = [object objectForKey:@"type"];
    
    //switchs.tag = indexPath.row; // DO NOT SET row to tag.. messes things up
    [switchs setValue:[object objectId] forKey:@"orderid"];
    [allmenuitemsdata setValue:object forKey:[object objectId]];
    
    if ([holdmenudata valueForKey:[object objectId]]) {
        switchs.on = YES;
        cell.backgroundColor  = [UIColor groupTableViewBackgroundColor];
    }else {
        switchs.on = NO;
        cell.backgroundColor  = [UIColor clearColor];
    }
    
    //.............UIControlEventTouchDown];
    [switchs addTarget:self action:@selector(selectMenu:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}


// ... prepareforSegue ...
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showorder"]) {
        NSLog(@"in segue");
        [menudata removeAllObjects];
        for (PFObject *obj in [holdmenudata allValues]){
            [menudata addObject:obj];
            //NSLog(@" objectid in segue : %d", [obj objectId]);
        }
        //NSLog(@" count in menudata : %d", [menudata count]);
        ShowCurrentOrder_VC *yourorder = (ShowCurrentOrder_VC *)segue.destinationViewController;
        yourorder.restaurant = self.restaurant;
        yourorder.menudata = self.menudata;

        yourorder.menucount = [[holdmenudata allValues] count];
    }
}


-(void)selectMenu:(UISwitch *) sender {
    PinchSwitch *switches = (PinchSwitch *) sender;
    NSString *orderid = switches.orderid;
    
    PFObject *menuobject = [allmenuitemsdata valueForKey:orderid];
    NSLog (@"menuobject : %@", [menuobject objectForKey:@"Name"]);
    if (switches.on) {
        [holdmenudata setValue:menuobject forKey:[menuobject objectId]];
    }else{
        [holdmenudata removeObjectForKey:[menuobject objectId]];
    }
    if ( holdmenudata.count > 0 ) {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    }else {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
}

@end
