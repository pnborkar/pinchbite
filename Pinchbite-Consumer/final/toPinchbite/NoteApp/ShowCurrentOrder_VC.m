//
//  ShowCurrentOrder_VC.m
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/19/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//
#import "MBProgressHUD.h"
#import "ShowCurrentOrder_VC.h" //<UIPickerViewDataSource, UIPickerViewDelegate>
#import "PBButton.h"

@interface ShowCurrentOrder_VC ()


@end

@implementation ShowCurrentOrder_VC
@synthesize tableView;
@synthesize orderview;
@synthesize menudata;
@synthesize user;
@synthesize menuitems;
@synthesize tax_percent;
@synthesize arrivaltime;
@synthesize holdmenuitems;
@synthesize holdmenudata;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser)  {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Please Login to Send Order!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

    UIToolbar *sendtoolbar = (UIToolbar *)[self.view viewWithTag:222];
    sendtoolbar.hidden = NO;
    
    tax_percent = [[self.restaurant objectForKey:@"tax_percent"] doubleValue] /100;
    // ... service type segmented control ordertypecontrol
    UISegmentedControl *ordertypecontrol = (UISegmentedControl *)[self.view viewWithTag:202];
    [ordertypecontrol setTransform:CGAffineTransformMakeScale(0.70, 0.70)];
    [ordertypecontrol setTintColor:[UIColor darkGrayColor]];
    if ( [[self.restaurant objectForKey:@"doDelivery"] boolValue ]) {
        [ordertypecontrol setEnabled:YES forSegmentAtIndex:0];
        _serviceoption.hidden = YES;
    }else {
        [ordertypecontrol setEnabled:NO forSegmentAtIndex:0];
            _serviceoption.hidden = NO;
    }
    
    if ( [[self.restaurant objectForKey:@"doPreorder"] boolValue ]) {
        [ordertypecontrol insertSegmentWithTitle:@"PreOrder" atIndex:2 animated:YES];
    }else {
       // [ordertypelabel setEnabled:NO forSegmentAtIndex:2]; //There is no index 2
    }
    
    [ordertypecontrol addTarget:self action:@selector(checkordertype:) forControlEvents:UIControlEventValueChanged];

    
    UILabel *restaurantname = (UILabel *)[self.view viewWithTag:100];
    restaurantname.text = [self.restaurant objectForKey:@"Name"];
    UILabel *address = (UILabel *)[self.view viewWithTag:109];
    address.text = [self.restaurant objectForKey:@"Address"];
    
    menuitems = [[NSMutableArray alloc] initWithObjects:nil];
    holdmenuitems = [[NSMutableDictionary alloc] init];
    holdmenudata = [[NSMutableDictionary alloc] init];
    // Commented on 1107 * menuitems.removeAllObjects; // ** Pramod , check this menthod
    UIDatePicker *datepicker = (UIDatePicker *)[orderview  viewWithTag:201];
    NSLog(@"datepicket %@ ", datepicker.date);
    datepicker.transform = CGAffineTransformMakeScale(0.55, 0.60);
    
    UIStepper *stepper = (UIStepper *)[self.view  viewWithTag:219];
    NSLog(@"stepper %@ ", stepper);
    stepper.transform = CGAffineTransformMakeScale(0.60, 0.60);

    /* No lines needed... made that as label
     
     UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 255, self.view.bounds.size.width-40, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView];
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(20, 313, self.view.bounds.size.width-40, 1)];
    lineView2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView2];*/
    
    UILabel *totalprice = (UILabel *)[self.view viewWithTag:132];
    UILabel *tax = (UILabel *)[self.view viewWithTag:131];
    UILabel *subtotal = (UILabel *)[self.view viewWithTag:130];
    
    NSNumber *result = @(0.00);
   
    for ( PFObject *menu in self.menudata) {
        result  = @([result doubleValue] + [[menu objectForKey:@"Price"] doubleValue]);
        NSString *items = [NSString stringWithFormat:@"%@:%@:$%.2f:#%@", [menu objectId], [menu objectForKey:@"Name"], [[menu objectForKey:@"Price"] doubleValue], @"1"];
        [menuitems addObject:items];
        
        [holdmenuitems setValue:items forKey:[menu objectId]];
        [holdmenudata setValue:menu forKey:[menu objectId]];

    }
    NSLog ( @"all values in hold %@", [holdmenuitems allValues]);
    
    if ( menudata.count == 0) {
        // 1107 ** menuitems.removeAllObjects;
        totalprice.text = @"0.00";
        tax.text = @"0.00";
        subtotal.text = @"0.00";
    }
    
    //NSLog(@"MENU COUNT  :: %d", self.menucount);
    subtotal.text = [NSString stringWithFormat:@"%.2f", [result doubleValue]];
    NSNumber *t = @([result doubleValue] * tax_percent);
    tax.text = [NSString stringWithFormat:@"%.2f", [t doubleValue]];
    result  = @([result doubleValue] + [t doubleValue]);
    totalprice.text = [NSString stringWithFormat:@"%.2f", [result doubleValue]];
    
    
    CGRect frame = CGRectMake(0, 0, 50, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:14];
    label.textColor = [UIColor darkGrayColor];
    label.text = @"Current Order";
    self.navigationItem.titleView = label;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleDone target:self action:@selector(gobacktomenu:)];
    UIFont * font = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:13];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    [saveButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    saveButton.enabled = YES;
    

    UIBarButtonItem *login = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"login.png"] style:UIBarButtonItemStyleDone target:self action:@selector(gotologin:)];
    login.enabled = YES;
    
    if (currentUser) {
        self.navigationItem.leftBarButtonItem = saveButton;
    }else {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: login,saveButton, nil]; // Or for fancy @[ rightA, rightB ];
    }
    
    UIBarButtonItem *feedbackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"feedback3.png"] style:UIBarButtonItemStyleDone target:self action:@selector(gotofeedback:)];
    feedbackButton.enabled = YES;
    
    UIBarButtonItem *sendbutton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"send.png"] style:UIBarButtonItemStyleDone target:self action:@selector(sendOrder:)];
    sendbutton.enabled = YES;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: sendbutton,  feedbackButton, nil];
    
    
    UIImageView *imageview = (UIImageView *)[self.view viewWithTag:12];
    PFFile  *photo = [self.restaurant objectForKey:@"image"];
    if (photo)
    {
        imageview.image = [UIImage imageNamed:@"restaurant"];
        [photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            // Now that the data is fetched, update the cell's image property.
            imageview.image = [UIImage imageWithData:data];
        }];
    }
    
    [_deliveryaddress1 addTarget:self action:@selector(finishtext:)
                  forControlEvents:UIControlEventEditingDidEndOnExit];
    [_deliveryaddress2 addTarget:self action:@selector(finishtext:)
                forControlEvents:UIControlEventEditingDidEndOnExit];
   
}

- (IBAction)finishtext:(id)sender {
}

- (void)checkordertype:(id)sender {
    UISegmentedControl *ordertypecontrol = (UISegmentedControl*) sender;
    //NSLog(@"selected control  : %ld",(long)ordertypecontrol.selectedSegmentIndex);
    
    if ( ordertypecontrol.selectedSegmentIndex == 0 ) { //Delivery option selected
        _deliveryoptionview.hidden = NO;
        
    }else  {
        _deliveryoptionview.hidden = YES;
    }
    
    /*UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor greenColor];
    self.view = contentView;
    
    UIView *centerView = [[UIView alloc] init];
    [centerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    centerView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:centerView];*/

    
    
}

-(void)gobacktomenu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gotofeedback:(id)sender {
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackScreen"];
    [self.navigationController pushViewController:foundVC animated:YES];
}

- (IBAction)gotomenu:(id)sender {
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteMenu"];
    [self.navigationController pushViewController:foundVC animated:YES];
    
}

- (IBAction)gotologin:(id)sender {
    UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteLogin"];
    [self.navigationController pushViewController:foundVC animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.menudata count];
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)routePicker
{
    return 1;
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
    
    PFObject *menuo = [self.menudata objectAtIndex:[indexPath row]];
    // Commented on 1107 - *
    // NSString *menu = [menuitems objectAtIndex:[indexPath row]];
    // Get menu from hold menu item not from index ..bad idea
    
    NSString *menu = [holdmenuitems valueForKey:[menuo objectId]];
    NSLog(@"menu %@", menu);
    
    NSRange start = [menu rangeOfString:@":"];
    NSRange end = [menu rangeOfString:@":$"];
    //NSRange needleRange = NSMakeRange(start.location+1, end.location - start.location -1);

    //[[cell textLabel] setText:[menu objectForKey:@"Name"]];
    UILabel *menulabel = (UILabel *)[cell viewWithTag:101];
    //UILabel *menudetails = (UILabel *)[cell viewWithTag:102];
    // ** menulabel.text = [menu objectForKey:@"Name"];
    menulabel.text = [menu substringWithRange:NSMakeRange(start.location+1, end.location - start.location -1)];
    //menudetails.text = [menu objectForKey:@"Ingredients"];
    UILabel *pricelabel = (UILabel *)[cell viewWithTag:103];
    start = [menu rangeOfString:@":$"];
    end = [menu rangeOfString:@":#"];
    pricelabel.text = [menu substringWithRange:NSMakeRange(start.location+1, end.location - start.location -1)];
    //totalamount = [NSNumber numberWithFloat:(totalamount + [menu objectForKey:@"Price"])];
    
    PBButton *plus = (PBButton *)[cell viewWithTag:107];
    [plus setValue:[menuo objectId] forKey:@"orderid"];

    //plus.tag = indexPath.row;
    //.............UIControlEventTouchDown];
    [plus addTarget:self action:@selector(plusMenu:) forControlEvents:UIControlEventTouchUpInside];

    PBButton *minus = (PBButton *)[cell viewWithTag:108];
    ///minus.tag = indexPath.row;
    [minus setValue:[menuo objectId] forKey:@"orderid"];
    //.............UIControlEventTouchDown];
    [minus addTarget:self action:@selector(minusMenu:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

-(void)plusMenu:(UIButton *) sender {
    
    PBButton *btn = (PBButton *) sender;
    PFObject *menu = [holdmenudata valueForKey:btn.orderid];
    
    NSString *curitem = [holdmenuitems valueForKey:btn.orderid];
    
    NSRange start = [curitem rangeOfString:@":#"];
    //NSRange end = [curitem rangeOfString:@":$"];
    //NSRange needleRange = NSMakeRange(start.location, end.length);
    NSInteger countofmenu = [[curitem substringFromIndex:start.location+2] intValue] + 1;
            
    NSNumber *price  = @([[menu objectForKey:@"Price"] doubleValue] * (double)countofmenu);
    NSString *price_str = [NSString stringWithFormat:@"%.2f", [price doubleValue]];
    NSString *newitem = [NSString stringWithFormat:@"%@:%@ (x%d):$%@:#%d", [menu objectId], [menu objectForKey:@"Name"],countofmenu, price_str, countofmenu];

            
            //[menuitems replaceObjectAtIndex:j withObject:newitem];
    [holdmenuitems setValue:newitem forKey:btn.orderid];
    //UILabel *subtotallabel = (UILabel *)[self.view viewWithTag:130];
    //UILabel *taxlabel = (UILabel *)[self.view viewWithTag:131];
    //UILabel *totallabel = (UILabel *)[self.view viewWithTag:132];
    
    price = @([[menu objectForKey:@"Price"] doubleValue] + [_subtotalamtlabel.text doubleValue]);
    _subtotalamtlabel.text = [NSString stringWithFormat:@"%.2f", [price doubleValue]];
    NSNumber *taxtotal = @([price doubleValue] * tax_percent);
    NSNumber *totalamt = @([price doubleValue] + [taxtotal doubleValue]);
    _taxamtlabel.text  = [NSString stringWithFormat:@"%.2f", [taxtotal doubleValue]];
    _totalamtlabel.text  = [NSString stringWithFormat:@"%.2f", [totalamt doubleValue]];
    
    
    [tableView reloadData];
    //sender.tag will be equal to indexPath.row
}

-(void)minusMenu:(UIButton *) sender {
    
    PBButton *btn = (PBButton *) sender;
    PFObject *menu = [holdmenudata valueForKey:btn.orderid];
    
    NSString *curitem = [holdmenuitems valueForKey:btn.orderid];
    
    //NSArray *tempitems = [curitem componentsSeparatedByString:@":"];
            
    NSRange start = [curitem rangeOfString:@":#"];
    NSRange end = [curitem rangeOfString:@":$"];
    NSInteger countofmenu = [[curitem substringFromIndex:start.location+2] intValue] - 1;
    if (countofmenu < 1) { return;} // Dont do anything if user keeps hitting - v
            
    NSNumber *price  = @([[menu objectForKey:@"Price"] doubleValue] * (double)countofmenu);
    NSString *price_str = [NSString stringWithFormat:@"%.2f", [price doubleValue]];

    NSString *newitem = [NSString stringWithFormat:@"%@:%@ (x%d):$%@:#%d", [menu objectId], [menu objectForKey:@"Name"],countofmenu, price_str, countofmenu];
            
    [holdmenuitems setValue:newitem forKey:btn.orderid];
    
    price = @([_subtotalamtlabel.text doubleValue] - [[menu objectForKey:@"Price"] doubleValue]);
    _subtotalamtlabel.text = [NSString stringWithFormat:@"%.2f", [price doubleValue]];
    NSNumber *taxtotal = @([price doubleValue] * tax_percent);
    NSNumber *totalamt = @([price doubleValue] + [taxtotal doubleValue]);
    _taxamtlabel.text  = [NSString stringWithFormat:@"%.2f", [taxtotal doubleValue]];
    _totalamtlabel.text  = [NSString stringWithFormat:@"%.2f", [totalamt doubleValue]];
    
    [tableView reloadData];
    
}

- (IBAction)sendOrder:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser){
        
        UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteLogin"];
        [self.navigationController pushViewController:foundVC animated:NO];
        
        return;
    }
    if ( [currentUser objectForKey:@"authcard"] == nil || [[currentUser objectForKey:@"authcard"]  isEqual:@""]) {
        
        UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteProfile"];
        [self.navigationController modalPresentationCapturesStatusBarAppearance];
        [self.navigationController pushViewController:foundVC animated:YES];
        return;
    }
  
   
    if ([menudata count] == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"No menu items selected!"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
        
    } else {
        
        UISegmentedControl *ordertypelabel = (UISegmentedControl *)[self.view viewWithTag:202];
        if (ordertypelabel.selectedSegmentIndex == 0 ) {
            
            // Check for delivery address if Delivery is chosen
            if ( [_deliveryaddress1.text isEqual:@""] || [_deliveryaddress2.text isEqual:@"" ]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"Delivery address cannot be empty!"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
        }
        NSDate *chosen_date = self.arrivaltime.date;
        
        if ([[NSDate date] compare:chosen_date] == NSOrderedDescending) {
           
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Arrival time should be later than current!"
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        NSLog(@"arrival time: %@", self.arrivaltime.date);
        
        NSString *yesno = [self isRestaurantOpen:@"ok"];
        NSLog(@"yesno: %@", yesno);
        NSString *msg = @"";
        if ( [yesno isEqualToString:@"Open"]) {
            
        }else {
            msg = [NSString stringWithFormat:@"\n\n%@",yesno];
        }
        
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@""
                                                         message:[NSString stringWithFormat:@"You are about to send your order to %@  %@ \n\nFYI: If you want to cancel the order,  contact restaurant before they confirm your order.", [self.restaurant objectForKey:@"Name"], msg]
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles: nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        
        return;
    }
}


- (void)hasError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


-(NSString *) isRestaurantOpen:(NSString *) x {
    
    NSArray *time_arr = [[NSArray alloc] initWithObjects: nil];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
     [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayoftheweek = [dateFormatter stringFromDate:arrivaltime.date];
    [dateFormatter setDateFormat:@"HH:mm"]; //Important to be later.. bcoz we are calculating time later
    NSString *currenttime = [dateFormatter stringFromDate:arrivaltime.date];
    if ([dayoftheweek isEqualToString:@"Monday"]) { time_arr = [self.restaurant objectForKey:@"mon_time"]; }
    if ([dayoftheweek isEqualToString:@"Tuesday"]) { time_arr = [self.restaurant objectForKey:@"tue_time"]; }
    if ([dayoftheweek isEqualToString:@"Wednesday"]) { time_arr = [self.restaurant objectForKey:@"wed_time"]; }
    if ([dayoftheweek isEqualToString:@"Thursday"]) { time_arr = [self.restaurant objectForKey:@"thu_time"]; }
    if ([dayoftheweek isEqualToString:@"Friday"]) { time_arr = [self.restaurant objectForKey:@"fri_time"]; }
    if ([dayoftheweek isEqualToString:@"Saturday"]) { time_arr = [self.restaurant objectForKey:@"sat_time"]; }
    if ([dayoftheweek isEqualToString:@"Sunday"]) { time_arr = [self.restaurant objectForKey:@"sun_time"]; }
    
    NSInteger count = [time_arr count];
    NSLog(@"day of the week %@ // currenttime %@", dayoftheweek, currenttime);
    NSLog(@"time_arr %@", time_arr);
    NSString *message = [NSString stringWithFormat:@"Warning: Closed at arrival time. Open timing: %@" , [time_arr componentsJoinedByString:@" ; "]];
    for (int i = 0; i < count; i++) {
        NSString *time_str = [time_arr objectAtIndex:i];
        
        if ([time_str isEqual:@"Closed"]) {
            return @"Warning: Closed at this time";
        }
        
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
                    return message;
                }else{
                    NSLog(@"go next");
                    continue;
                }
            }
        } else {
            NSLog(@"closed slot !!!!!: ");
             return message;
        }
    }
    
    return @"Warning: Closed at this time";
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
PFUser *currentUser = [PFUser currentUser];
 if( 0 == buttonIndex ){ //cancel button
     
     [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
     
 } else if ( 1 == buttonIndex )  {
     NSLog(@"Clicked on OK");
     //NSMutableArray *menuitem = [[NSMutableArray alloc] initWithObjects:nil];
     PFObject *newOrder = [PFObject objectWithClassName:@"Orders"];
     // *********** DEBUG MORE ************
     UISegmentedControl *ordertypelabel = (UISegmentedControl *)[self.view viewWithTag:202];
     newOrder[@"restaurant"] = self.restaurant;
     newOrder[@"restaurantname"] = [self.restaurant objectForKey:@"Name"];
     newOrder[@"user"] = [PFUser currentUser];
     newOrder[@"userid"] = [[PFUser currentUser] objectId]; // ** Pramod
     newOrder[@"numPeople"] = @([_numpeople.text integerValue]);
     newOrder[@"isTakenCare"] = @NO;
     newOrder[@"isCharged"] = @NO;
     newOrder[@"Status"] = @"Pending";
     newOrder[@"restaurantid"] = [self.restaurant objectId];
     NSString *userdisplayname = [NSString stringWithFormat:@"%@ %@", [currentUser objectForKey:@"Firstname"], [currentUser objectForKey:@"Lastname"]];
     newOrder[@"userdisplayname"] = userdisplayname;
     
     
     // ****** Userid is added to order just to make the query faster!!!
     // Same thing with restaurantid .. hmm!!
     
     // Get Special instrusctons
     UITextView *textView = (UITextView *)[self.view viewWithTag:106];
     NSArray *lines = [textView.text componentsSeparatedByString:@"\n"];
     NSString *instructions = [[lines valueForKey:@"description"] componentsJoinedByString:@""];
     
     
     if (ordertypelabel.selectedSegmentIndex == 0 ) {
         newOrder[@"ordertype"] = @"Delivery";
         newOrder[@"deliveryaddress"] = [NSString stringWithFormat:@"%@, %@", _deliveryaddress1.text , _deliveryaddress2.text];
         if ( [_deliveryaddress1.text isEqual:@""] || [_deliveryaddress2.text isEqual:@"" ]) {
             
         }
     }else if (ordertypelabel.selectedSegmentIndex == 1 )  {
         newOrder[@"ordertype"] = @"Pickup";
     }else  if (ordertypelabel.selectedSegmentIndex == 2 ) {
         newOrder[@"ordertype"] = @"PreOrder";
     }
     
     newOrder[@"Instructions"] = instructions;
     
     //Get the amount
     UILabel *totalprice = (UILabel *)[self.view viewWithTag:132];
     newOrder[@"totalAmt"] = totalprice.text;
     UILabel *taxAmt = (UILabel *)[self.view viewWithTag:131];
     newOrder[@"taxAmt"] = taxAmt.text;
     
     NSDate *arr_date = self.arrivaltime.date;
     [arr_date descriptionWithLocale:[NSLocale systemLocale]];
     
     NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
     NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
     
     NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:arr_date];
     NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:arr_date];
     NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
     NSDate* dest_date = [[NSDate alloc] initWithTimeInterval:interval sinceDate:arr_date];
     
     newOrder[@"arrivalTime"] = dest_date;
    
     //Get Menu data
     PFRelation *relation = [newOrder relationForKey:@"menu"];
     for (PFObject *obj in self.menudata) {
         [relation addObject:obj];
         //[menuitem addObject:[NSString stringWithFormat:@"%@:%@",[obj objectId], @"2"]];
     }
     
     newOrder[@"menuitems"] = [holdmenuitems allValues];
     [newOrder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         if (succeeded) {
             NSString *neworderid = [newOrder objectId];
             //Send email if turned on
             if ( [[self.restaurant objectForKey:@"doSendemail"] boolValue] ) {
                 //First format the menuitems
                 NSMutableArray *newmenuitems = [[NSMutableArray alloc] init];
                 for (NSString *str in [holdmenuitems allValues]) {
                     
                     NSRange start = [str rangeOfString:@":"];
                     NSRange end = [str rangeOfString:@":$"];
                     NSRange needleRange = NSMakeRange(start.location+1, end.location - start.location -1);
                     NSString *menu = [str substringWithRange:needleRange];
                     [newmenuitems addObject:[NSString stringWithFormat:@"%@", menu]];
                 }
                 NSString *emailmenu = [newmenuitems componentsJoinedByString:@"<br>\n"];
                 _smsmenu = [newmenuitems componentsJoinedByString:@"\n"];
                 
                 
                 NSDateFormatter * inputFormatter =  [ [ NSDateFormatter alloc ] init ]  ;
                 NSDateFormatter * outputFormatter =  [ [ NSDateFormatter alloc ] init ]  ;
                 [ inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss '+0000'" ];
                 [ outputFormatter setDateFormat:@"MMM d, EEE -    h:mm a" ];
                 
                 NSString * inputString = [NSString stringWithFormat:@"%@", [newOrder objectForKey:@"arrivalTime"]];
                 NSDate * inputDate = [ inputFormatter dateFromString:inputString ];
                 NSString * outputString = [ outputFormatter stringFromDate:inputDate ];

                 NSString *deliverymsg = [[newOrder objectForKey:@"ordertype"] isEqual:@"Delivery"] ? [newOrder objectForKey:@"deliveryaddress"] : @"N/A";
                 NSString *emailmsg = [NSString stringWithFormat:@"<html><body>You have recieved order from Pinchbite with following details: <br><br> PinchBite Order ID: <b>%@</b> <br>Order Type :<b> %@ </b><br>Customer Name: <b>%@</b> <br>Delivery Address: <b>%@ </b><br>Arrival Time: <b>%@</b><br><br><u><b>Menu selected</u></b>:<br>\n%@<br><br><b><u>Instructions:</u></b><br> %@ <br><br><hr><br>TOTAL AMOUNT:     <b>$%@</b><br><br><br><a href='http://pinchbite.com/orders.php?oid=%@'>Please acknowledge that you have received the customer order and will notify the customer. <br><br></a><hr></body></html>" , [newOrder objectId], [newOrder objectForKey:@"ordertype"], userdisplayname, deliverymsg, outputString, emailmenu,instructions ,_totalamtlabel.text, neworderid];
                 NSDictionary *params = @{
                                          @"contact": [self.restaurant objectForKey:@"email"],
                                          @"subject": [NSString stringWithFormat:@"Your order from Pinchbite for: %@", userdisplayname],
                                          @"message": emailmsg
                                          };
                 
                 [PFCloud callFunction:@"sendemailtorestaurant" withParameters:params];
                 
             }
             
             
             //Send SMS if restaurant wants it!!
             if ( [[self.restaurant objectForKey:@"doSendSMS"] boolValue]) {
                 
                  NSString *smsmsg = [NSString stringWithFormat:@"\nORDER from Pinchbite: ($%@) \n\nhttp://pinchbite.com/orders.php?oid=%@" , totalprice.text, neworderid];
                 
                 NSDictionary *smsparams = @{
                                                @"phone": [self.restaurant objectForKey:@"Phone"],
                                                @"message": smsmsg
                                             };
                 

                 [PFCloud callFunction:@"sendsmsmsg" withParameters:smsparams];
             }
             if ( [[self.restaurant objectForKey:@"doSendfax"] boolValue]) {
                 
                 NSString *smsmsg = [NSString stringWithFormat:@"\nSEND FAX - to %@: ($%@) \n\nhttp://pinchbite.com/orders.php?oid=%@" ,[self.restaurant objectForKey:@"faxnumber"], totalprice.text, neworderid];
                 
                 NSDictionary *smsparams = @{
                                             @"phone": @"5105206107",
                                             @"message": smsmsg
                                             };
                 
                 [PFCloud callFunction:@"sendsmsmsg" withParameters:smsparams];
                 
                  NSDictionary *smsparams1 = @{
                                             @"phone": @"2563949315",
                                             @"message": smsmsg
                                             };
                 
                 [PFCloud callFunction:@"sendsmsmsg" withParameters:smsparams1];
             }

             UIViewController *foundVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PinchbiteOrders"];
             [self.navigationController pushViewController:foundVC animated:YES];
             
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

//delete menu item
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //[self.dataArray removeObjectAtIndex:indexPath.row];
        PFObject *c_menu = [self.menudata objectAtIndex:[indexPath row]];
        //NSLog(@" in delete method %d ... %@", [indexPath row] , c_menu);
        
        NSString *curitem = [holdmenuitems valueForKey:[c_menu objectId]];
        NSLog(@"in del method : curitem : %@", curitem);
        NSRange start = [curitem rangeOfString:@":#"];
        NSInteger countofmenu = [[curitem substringFromIndex:start.location+2] intValue];
        
        NSNumber *price  = @([[c_menu objectForKey:@"Price"] doubleValue] * (double)countofmenu);
        //NSLog(@"in del method : #menu || price ||  %d  || %@", countofmenu,  price);
        price = @([_subtotalamtlabel.text doubleValue] - [price doubleValue]);
        _subtotalamtlabel.text = [NSString stringWithFormat:@"%.2f", [price doubleValue]];
        NSNumber *taxtotal = @([price doubleValue] * tax_percent);
        NSNumber *totalamt = @([price doubleValue] + [taxtotal doubleValue]);
        _taxamtlabel.text  = [NSString stringWithFormat:@"%.2f", [taxtotal doubleValue]];
        _totalamtlabel.text  = [NSString stringWithFormat:@"%.2f", [totalamt doubleValue]];
        
        [holdmenudata removeObjectForKey:[c_menu objectId]];
        [holdmenuitems removeObjectForKey:[c_menu objectId]];
        [menudata removeObjectAtIndex:indexPath.row];
        
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//
- (IBAction)peopleaction:(id)sender {
    
    _numpeople.text = [NSString stringWithFormat:@"%.f",_setpeople.value];
}

//.. for Done
- (IBAction)keyboarddone:(id)sender {
    [_instructionsview resignFirstResponder];
}

- (IBAction)takeaddress:(id)sender {
    
    _deliveryoptionview.hidden = YES;
}
- (IBAction)canceldeliveryaddress:(id)sender {
     _deliveryoptionview.hidden = YES;
}
@end
