//
//  MapViewController.m
//  travel-rewards-ios-app
//
//  Created by Anita Santoso on 6/06/14.
//  Copyright (c) 2014 YML. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

#define kLocationUpdateNotification @"updateNotification"

@interface MapViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) PBWatch *watch;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [LocationManager sharedInstance].delegate = self;
    [[LocationManager sharedInstance] startUpdatingLocation];
    
    // pebble
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    self.watch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    if(self.watch) {
        [self showDummyNotification];
    }
}

#pragma mark - location update delegate

- (void)locationMovedTo:(CLLocation*)location {
    
    self.lastLocation = location;
}

- (void)didFindBeacon:(CLBeacon*)beacon {
    // show popup
    [self showDummyNotification];
}

#pragma mark - pebble delegate
- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Pebble connected: %@", [watch name]);
    self.watch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    
    NSLog(0);
//    self.watch appMessagesLaunch:<#^(PBWatch *watch, NSError *error)onSent#> withUUID:<#(NSData *)#>
//    self.watch appMessagesPushUpdate:<#(NSDictionary *)#> onSent:<#^(PBWatch *watch, NSDictionary *update, NSError *error)onSent#>
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    
}

- (void)showDummyNotification {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = @"Notification from AirPoint!";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

@end
