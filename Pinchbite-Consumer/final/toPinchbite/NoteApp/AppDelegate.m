//
//  AppDelegate
//  Pinchbite Inc.
//
//  Created by Joyce Echessa on 6/5/14.
//  Copyright (c) 2014 Pinchbite, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "Stripe.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //[Parse setApplicationId:@"Lz8yKdMoyXQylo9MHMsVZv8LF1ZH5XpFb6iE0jOU"
      //            clientKey:@"R2WYN7SAxbyw9RzzXZAcL01bKzc3eac3CTXcKdib"];
    
    
    if (StripePublishableKey) {
        [Stripe setDefaultPublishableKey:StripePublishableKey];
    }
    if (ParseApplicationId && ParseClientKey) {
        [Parse setApplicationId:ParseApplicationId clientKey:ParseClientKey];
    }
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    // Register for Push Notitications, if running iOS 8
    
    //if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {

        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
        
        
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
