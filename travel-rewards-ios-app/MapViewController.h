//
//  MapViewController.h
//  travel-rewards-ios-app
//
//  Created by Anita Santoso on 6/06/14.
//  Copyright (c) 2014 YML. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import <PebbleKit/PebbleKit.h>

@interface MapViewController : UIViewController<LocationUpdateDelegate, PBPebbleCentralDelegate>

@end
