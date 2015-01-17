//
//  MapViewController.m
//  Scht
//
//  Created by Brian Wang on 1/17/15.
//  Copyright (c) 2015 Scht. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    GMSMapView *_mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startMap];
    [_placeShitButton addTarget:self action:@selector(placeShit) forControlEvents:UIControlEventTouchUpInside];
}
-(void)startMap {
    //---- For getting current gps location

    if ([CLLocationManager locationServicesEnabled]) {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.distanceFilter = kCLDistanceFilterNone;
            _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }
        [_locationManager startUpdatingLocation];
    }
    NSLog([NSString stringWithFormat:@"%f, %f", _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude]);
    //------
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: _locationManager.location.coordinate.latitude
                                                            longitude: _locationManager.location.coordinate.longitude
                                                                 zoom:12];
    _mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    _mapView.delegate = self;
    _mapView.padding = UIEdgeInsetsMake(0, 0, 49, 0);
    _mapView.settings.compassButton = YES;
    _mapView.myLocationEnabled = YES;
    [_locationManager stopUpdatingLocation];
    
    [self.view insertSubview: _mapView atIndex: 0];
    
}

-(void)placeShit {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
