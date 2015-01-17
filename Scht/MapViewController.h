//
//  MapViewController.h
//  Scht
//
//  Created by Brian Wang on 1/17/15.
//  Copyright (c) 2015 Scht. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface MapViewController : UIViewController<CLLocationManagerDelegate,GMSMapViewDelegate>
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UIView *viewForMap;
@end
