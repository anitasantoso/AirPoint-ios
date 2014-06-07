//
//  LocationManager.m
//  IICaptain
//
//  Created by Anita Santoso on 24/01/13.
//  Copyright (c) 2013 SEW. All rights reserved.
//

#import "LocationManager.h"

#define kDistanceFilter 1

@interface LocationManager()

@property (nonatomic, strong) NSTimer *locUpdateTimer;
@property (nonatomic, strong) NSArray *beaconRegions;
@end

@implementation LocationManager
JTSYNTHESIZE_SINGLETON_FOR_CLASS(LocationManager)

- (id)init {
    if(self = [super init]) {
        self.locMgr = [[CLLocationManager alloc]init];
        self.locMgr.delegate = self;
        self.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
        self.locMgr.distanceFilter = kDistanceFilter;
    }
    return self;
}

- (void)monitorBeaconRegions {
    NSMutableArray *regions = [NSMutableArray new];
    for(NSString *uuid in @[@"FD7B7966-9C0F-471A-83A2-46D995AE85A1", @"114A4DD8-5B2F-4800-A079-BDCB21392BE9"]) {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:@"estimote"];
        region.notifyEntryStateOnDisplay = YES;
        [regions addObject:region];
        [self.locMgr stopMonitoringForRegion:region];
        [self.locMgr stopRangingBeaconsInRegion:region];
        
        [self.locMgr startMonitoringForRegion:region];
        [self.locMgr startRangingBeaconsInRegion:region];
//        [self.locMgr requestStateForRegion:region];
    }
    self.beaconRegions = regions;
}

- (void)startUpdatingLocation {
    [self.locMgr startUpdatingLocation];
    [self checkLocation];
    
    // poll every 2 seconds
    [self.locUpdateTimer invalidate];
    self.locUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkLocation) userInfo:nil repeats:YES];
    
    [self monitorBeaconRegions];
}

- (void) handleNewLocation:(CLLocation *)location {
    // NSLog(@"New location: (%f, %f) - accuracy: %f", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    if (![self isNewLocation:location])	{
        return;
    }
    // store new location
    self.currentLocation = location;
    if(self.delegate) {
        [self.delegate locationMovedTo:self.currentLocation];
    }
}

- (void) checkLocation {
	CLLocation *location = [self.locMgr location];
	if (!location) {
		return;
	}
    [self handleNewLocation:location];
}

#pragma mark - cl location stuff

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
}

- (BOOL)isNewLocation:(CLLocation*)location
{
    [self checkAccuracy:location];
    
    // invalid location
    if(location.horizontalAccuracy < 0) {
        return NO;
    }
    
    // compare with previous location
    if(self.currentLocation) {
        
        // same location do not update
        if([location.timestamp timeIntervalSinceDate:self.currentLocation.timestamp] <= 0) {
            return NO;
        }
        
        // same location do not update
        if(self.currentLocation.coordinate.latitude == location.coordinate.latitude && self.currentLocation.coordinate.longitude == location.coordinate.longitude) {
            return NO;
        }
        
        // 160 seems to be the ideal number before we're getting random location updates
        if(location.horizontalAccuracy > 160) {
            NSLog(@"Location accuracy is larger than 160m radius, discarding");
            return NO;
        }
    }
    return YES;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"ERROR: Location manager failed");
}

- (void)checkAccuracy:(CLLocation*)location {
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    self.authorisationStatus = status;
    if(status != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Authorisation status did change");
    }
}

#pragma mark - beacon stuff
- (NSString*)proximityString:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityImmediate:
            return @"Immediate";
        case CLProximityNear:
            return @"Near";
        case CLProximityFar:
            return @"Far";
        case CLProximityUnknown:
        default:
            return @"Unknown";
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLBeaconRegion *)region {
//    [self addStatus:SF(@"Entered Region %@",region.identifier)];
    [manager startRangingBeaconsInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLBeaconRegion *)region
{
//    [self addStatus:SF(@"Left Region %@",region.identifier)];
//    [manager stopRangingBeaconsInRegion:region];
}

// Note: this is not being called
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {

    //add back what we have now
    for (CLBeacon *beacon in beacons){
        if(beacon.proximity == CLProximityFar) {
            [self.delegate didFindBeacon:beacon];
        }
        NSLog(@"Proximity %@", [self proximityString:beacon.proximity]);
        NSLog(@"%@", beacon);
    }
    
//    [self checkClosestBeacon];
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
//    [self addStatus:SF(@"error Ranging Beacons in Region %@: %@",region.identifier, error)];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)regionState forRegion:(CLBeaconRegion *)region {
}

@end
