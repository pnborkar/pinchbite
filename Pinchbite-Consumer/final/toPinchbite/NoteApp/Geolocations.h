//
//  Geolocations.h
//  NoteApp
//
//  Created by Pramod Borkar on 11/4/14.
//  Copyright (c) 2014 PinchBite. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Geolocations : UIViewController 
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
- (IBAction)getCurrentLocation:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end
