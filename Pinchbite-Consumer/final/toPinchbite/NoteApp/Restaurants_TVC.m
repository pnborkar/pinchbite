//
//  Restaurants_TVC.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/5/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import "Restaurants_TVC.h"
#import "PinchbiteLogin_VC.h"
#import "ShowMenuTVC.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

@interface Restaurants_TVC ()

@end

@implementation Restaurants_TVC 
//@synthesize restaurantdata;
@synthesize locationManager;
@synthesize geocoder;
@synthesize placemark;
@synthesize dateFormatter;
@synthesize currenttime;
@synthesize currentLocation;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithClassName:@"Restaurants"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // The className to query on
        self.parseClassName = @"Restaurants";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // get current date/time
    NSDate *today = [NSDate date];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    _dayoftheweek = [dateFormatter stringFromDate:today] ;
    [dateFormatter setDateFormat:@"HH:mm"]; // 24 hrs
    currenttime = [dateFormatter stringFromDate:today];
    NSLog(@"User's current time in their preference format:%@",currenttime);
    

    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile.png"] style:UIBarButtonItemStyleDone target:self action:@selector(gotoLogin:)];
    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:11];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [saveButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    saveButton.enabled = YES;
    self.navigationItem.leftBarButtonItem = saveButton;

    
    CGRect frame = CGRectMake(0, 0, 70, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:13];
    label.textColor = [UIColor darkGrayColor];
    label.text = @"Restaurants";
    self.navigationItem.titleView = label;
    
    [_milesfield addTarget:self action:@selector(getCurrentlocation:)
           forControlEvents:UIControlEventEditingDidEndOnExit];
    
    _milesfield.delegate = self;

   
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    #define NUMBERS_ONLY @"1234567890"
    #define CHARACTER_LIMIT 3
    
    NSUInteger newLength = [_milesfield.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    while (newLength < CHARACTER_LIMIT) {
        return [string isEqualToString:filtered];
    }
    /* Limits the no of characters to be enter in text field */
    return (newLength  > CHARACTER_LIMIT ) ? NO : YES;
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
    cell.textLabel.text = @"  ... loading more restaurants ...";
    cell.textLabel.font =  [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField //resign first responder for textfield
{
    //[_milesfield resignFirstResponder]; - This does not work (need to check!!)
    return YES;
}

- (IBAction)finishtext:(id)sender {
    NSLog(@"done with miles");
    //[_milesfield resignFirstResponder];
    
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

- (IBAction)getCurrentlocation:(id)sender {
  
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //[self.locationManager requestWhenInUseAuthorization];
    //[self.locationManager requestAlwaysAuthorization];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didUpdateToLocation");    
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"in locationmgr");
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSString *longitute = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *latitute = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        NSString * curloc = [NSString stringWithFormat:@"%@ , %@",  latitute , longitute];
        NSLog (@"***curloc : %@", curloc);
        _curgeoPoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
        //PFGeoPoint *curgeopoint = (PFGeoPoint *)geoPointWithLatitude:(double)latitute (double)longitute;
       
    }
    [locationManager stopUpdatingLocation];
    //[self.tableView reloadData];
    [self loadObjects];
    
    // Reverse Geocoding
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self loadObjects];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
}

- (IBAction)gotoLogin:(id)sender {
    NSLog(@"goto login %@", sender);
    PFUser *currentUser = [PFUser currentUser];

    if (currentUser) {
        UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteProfile"];
        [self.navigationController pushViewController:foundVC animated:YES];

    }else{
        UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteLogin"];
        [self.navigationController pushViewController:foundVC animated:YES];
    }
}

#pragma mark - PFQueryTableViewController

// ...cellForRowAtIndexPath...
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UILabel *restlabel = (UILabel *)[cell viewWithTag:81];
    restlabel.text = [object objectForKey:@"Name"];

    UILabel *detailslabel = (UILabel *)[cell viewWithTag:82];
    detailslabel.text = [object objectForKey:@"Address"];
    
    UILabel *typelabel = (UILabel *)[cell viewWithTag:92];
    typelabel.text = [object objectForKey:@"type"];
    
    UILabel *r_timelabel = (UILabel *)[cell viewWithTag:86];
    
    //BOOL gohead = YES;
    
    if ([_dayoftheweek  isEqual: @"Monday"]) {
        NSString *yesno = [self isRestaurantOpen:[object objectForKey:@"mon_time"]];
        if ([yesno isEqual:@"Open"]) {
            r_timelabel.text = @"Open Now";
            [r_timelabel setTextColor:[UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }else{
            r_timelabel.text = @"Closed";
            [r_timelabel setTextColor:[UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }
    }
    
    if ([_dayoftheweek  isEqual: @"Tuesday"]) {
        NSString *yesno = [self isRestaurantOpen:[object objectForKey:@"tue_time"]];
        if ([yesno isEqual:@"Open"]) {
            r_timelabel.text = @"Open Now";
            [r_timelabel setTextColor:[UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }else{
            r_timelabel.text = @"Closed";
            [r_timelabel setTextColor:[UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }
    }
    if ([_dayoftheweek  isEqual: @"Wednesday"]) {
        NSString *yesno = [self isRestaurantOpen:[object objectForKey:@"wed_time"]];
        if ([yesno isEqual:@"Open"]) {
            r_timelabel.text = @"Open Now";
            [r_timelabel setTextColor:[UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }else{
            r_timelabel.text = @"Closed";
            [r_timelabel setTextColor:[UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }
    }
    
    if ([_dayoftheweek  isEqual: @"Thursday"]) {
        NSString *yesno = [self isRestaurantOpen:[object objectForKey:@"thu_time"]];
        if ([yesno isEqual:@"Open"]) {
            r_timelabel.text = @"Open Now";
            [r_timelabel setTextColor:[UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }else{
            r_timelabel.text = @"Closed";
            [r_timelabel setTextColor:[UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }
    }
    if ([_dayoftheweek  isEqual: @"Friday"]) {
        NSString *yesno = [self isRestaurantOpen:[object objectForKey:@"fri_time"]];
        if ([yesno isEqual:@"Open"]) {
            r_timelabel.text = @"Open Now";
            [r_timelabel setTextColor:[UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }else{
            r_timelabel.text = @"Closed";
            [r_timelabel setTextColor:[UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }
    }
    if ([_dayoftheweek  isEqual: @"Saturday"]) {
        NSString *yesno = [self isRestaurantOpen:[object objectForKey:@"sat_time"]];
        if ([yesno isEqual:@"Open"]) {
            r_timelabel.text = @"Open Now";
            [r_timelabel setTextColor:[UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }else{
            r_timelabel.text = @"Closed";
            [r_timelabel setTextColor:[UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }
    }
    if ([_dayoftheweek  isEqual: @"Sunday"]) {
        NSString *yesno = [self isRestaurantOpen:[object objectForKey:@"sun_time"]];
        if ([yesno isEqual:@"Open"]) {
            r_timelabel.text = @"Open Now";
            [r_timelabel setTextColor:[UIColor colorWithRed:34.0/255.0 green:139.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }else{
            r_timelabel.text = @"Closed";
            [r_timelabel setTextColor:[UIColor colorWithRed:178.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0]];
        }
    }
    
    
    UILabel *phonelabel = (UILabel *)[cell viewWithTag:84];
    phonelabel.text = [object objectForKey:@"Phone"];
   
    UILabel *servicelabel = (UILabel *)[cell viewWithTag:87];
    servicelabel.text = [object objectForKey:@"service"];
    UIImageView *imageview = (UIImageView *)[cell viewWithTag:80];
    UIButton *getinlinebutton = (UIButton *)[cell viewWithTag:310];
    BOOL getinline = [[object objectForKey:@"isGetLine"] boolValue];
    if (getinline) {
        getinlinebutton.enabled = NO;
    }else {
        getinlinebutton.hidden = YES;
    }
    
    PFFile  *photo = [object objectForKey:@"image"];
    NSLog(@"phoot %@", photo );
    if (photo && ![photo isEqual:[NSNull null]]) {
    
        imageview.image = [UIImage imageNamed:@"restaurant1.png"];
        
        [photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            // Now that the data is fetched, update the cell's image property.
            if (!error) {
                imageview.image = [UIImage imageWithData:data];
                
            }
        }];
        
    }else{
        imageview.image = [UIImage imageNamed:@"restaurant1.png"];
        imageview.alpha = 0.5;
    }
    
    
    PFGeoPoint *r_geopoint = [object objectForKey:@"location"];
    NSString * r_latitude = [NSString stringWithFormat:@"%.6f",r_geopoint.latitude];
    //NSLog(@"long late: %@ =  %.6f , %.6f",[object objectForKey:@"Name"], r_geopoint.latitude, r_geopoint.longitude);
    double distanceDouble  = [_curgeoPoint distanceInMilesTo:r_geopoint];
    //NSLog(@"Distance: %.1f",distanceDouble); //
    UILabel *mileslabel = (UILabel *)[cell viewWithTag:77];
    UIImageView *milesimage = (UIImageView *)[cell viewWithTag:76];
    
    if ( _curgeoPoint == nil || [r_latitude isEqual:@"0.000000"] ) {
        milesimage.hidden = YES;
        mileslabel.hidden = YES;
    }else {
        milesimage.hidden = NO;
        mileslabel.hidden = NO;
        mileslabel.text = [NSString stringWithFormat:@"%.2f mi", distanceDouble];
    }
    
    return cell;
}

-(NSString *) isRestaurantOpen:(NSArray *) time_arr {
    NSDate *today = [NSDate date];
    currenttime = [dateFormatter stringFromDate:today];
    NSInteger count = [time_arr count];
    for (int i = 0; i < count; i++) {
        NSString *time_str = [time_arr objectAtIndex:i];
        
        if ([time_str isEqual:@"Closed"]) { return @"Closed"; }
        
        NSRange start = [time_str rangeOfString:@"-"];
        NSRange needleRange = NSMakeRange(0, start.location);
        NSString *starttime = [time_str substringWithRange:needleRange];
        needleRange = NSMakeRange(start.location+1, time_str.length - start.location-1);
        NSString *endtime = [time_str substringWithRange:needleRange];
        
        NSDate *opentime = [dateFormatter dateFromString:starttime];
        NSDate *closedtime = [dateFormatter dateFromString:endtime];
        NSDate *curtime = [dateFormatter dateFromString:currenttime];
        //NSLog(@" ::: %@ / %@ // %@", curtime, opentime, closedtime);
        NSComparisonResult openresult = [curtime compare:opentime];
        NSComparisonResult closedresult = [closedtime compare:curtime];
        if(openresult == NSOrderedDescending) { // current is later than opentime
            
            if(closedresult == NSOrderedDescending) { // closed time is later than current
                NSLog(@"open slot: ");
                return  @"Open";
            }else{
                if ( i == count -1) {
                    NSLog(@"closed slot **: LAST COUNT ");
                    return @"Closed";
                }else{
                    NSLog(@"go next");
                    continue;
                }
            }
        } else {
            NSLog(@"closed slot !!!!!: ");
            return @"Closed";
        }
    }
    return @"Closed";
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    
    // Create a query
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"isReady" equalTo:@(YES)];
    if ( _curgeoPoint) {
        NSLog(@"location query ");
        double miles = [_milesfield.text doubleValue];
        [query whereKey:@"location" nearGeoPoint:_curgeoPoint withinMiles:miles];
    }
    NSLog(@"coming to query!");
    // Follow relationship
    
    
    NSLog(@"end to query %@!", query);
    return query;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"showMenu"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        ShowMenuTVC *showmenu = (ShowMenuTVC *)segue.destinationViewController;
        showmenu.restaurant = object;
        NSString *temp = [object objectId];
        NSLog(@"restaurant in segue %@", temp );
    }
}


- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}


@end
