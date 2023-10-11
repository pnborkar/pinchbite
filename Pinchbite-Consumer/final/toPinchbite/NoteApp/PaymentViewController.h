//
//  PaymentViewController.h
//  Pinchbite Inc.
//
//  Created by Pramod Borkar on 10/22/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTKView.h"

@interface PaymentViewController : UIViewController <PTKViewDelegate>

@property IBOutlet PTKView* paymentView;
@end
