//
//  LocationManager.h
//

#import <Foundation/Foundation.h>
#import "JTSingleton.h"
#import <CoreMotion/CMMotionManager.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationUpdateDelegate
- (void)locationMovedTo:(CLLocation*)location;
- (void)didFindBeacon:(CLBeacon*)beacon;
@end

@interface LocationManager : NSObject<CLLocationManagerDelegate>

+ (LocationManager*)sharedInstance;
@property (nonatomic, strong) CLLocationManager *locMgr;
@property (nonatomic, strong) CLLocation *currentLocation;
@property id<LocationUpdateDelegate> delegate;
- (void)startUpdatingLocation;
- (void)monitorBeaconRegions;
@property CLAuthorizationStatus authorisationStatus;
@end
