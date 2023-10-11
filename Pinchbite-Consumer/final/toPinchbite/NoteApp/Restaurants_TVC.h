//
//  Restaurants_TVC.h
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/21/2014
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>


@interface Restaurants_TVC : PFQueryTableViewController   <CLLocationManagerDelegate, UITableViewDelegate, UITextFieldDelegate>
- (IBAction)getCurrentlocation:(id)sender;

- (IBAction)logout:(id)sender;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, weak) CLPlacemark *placemark;

@property (nonatomic, strong) NSMutableArray *restaurantdata;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSString *currenttime;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) PFGeoPoint *curgeoPoint;
@property (nonatomic) NSString *dayoftheweek;
@property (weak, nonatomic) IBOutlet UILabel *miles;
@property (weak, nonatomic) IBOutlet UITextField *milesfield;

@end
