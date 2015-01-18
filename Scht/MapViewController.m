//
//  MapViewController.m
//  Scht
//
//  Created by Brian Wang on 1/17/15.
//  Copyright (c) 2015 Scht. All rights reserved.
//

#import "MapViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface MapViewController ()

@end

@implementation MapViewController {
    GMSMapView *_mapView;
    NSUserDefaults *_defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startMap];
    
    [_placeShitButton addTarget:self action:@selector(placeShit) forControlEvents:UIControlEventTouchUpInside];
    [_shareButton addTarget: self action: @selector(facebookShare) forControlEvents:UIControlEventTouchUpInside];
    [_resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    
    _resetButton.enabled = FALSE;
    _shareButton.enabled = FALSE;
    
    _nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _nameField.delegate = self;
    _defaults = [NSUserDefaults standardUserDefaults];
    _nameField.text = [_defaults objectForKey:@"name"];
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
                                                                 zoom:14];
    _mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    _mapView.delegate = self;
    _mapView.padding = UIEdgeInsetsMake(0, 0, 49, 0);
    _mapView.settings.compassButton = YES;
    _mapView.myLocationEnabled = YES;
    [_locationManager stopUpdatingLocation];
    
    Firebase *rootRef = [[Firebase alloc] initWithUrl:@"https://schtapp.firebaseio.com/"];
    
    Firebase *shits = [rootRef childByAppendingPath: @"Shits"];
    
    [self.view insertSubview: _mapView atIndex: 0];
    
    [[shits queryOrderedByKey] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString *name = snapshot.key;
        for (FDataSnapshot *locationEvent in snapshot.children) {
        
            CGPoint point = [self convertToLocation: locationEvent];
            NSLog([NSString stringWithFormat:@"%f, %f", point.x, point.y]);
            
            NSString *date = locationEvent.value[@"date"];
            GMSMarker *marker = [[GMSMarker alloc] init];
            if ([name isEqualToString: _nameField.text]) {
                marker.icon = [self resizeImage:[UIImage imageNamed:@"MainTurdIcon"]];
            } else {
                marker.icon = [self resizeImage:[UIImage imageNamed:@"DarkTurdIcon"]];

            }
            marker.position = CLLocationCoordinate2DMake(point.x, point.y);
            marker.title = [NSString stringWithFormat:@"%@, %@", name, date ];
            
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = _mapView;
        }
    }];
}
-(void)placeShit {
    if (_nameField.text.length == 0) {
        _nameField.backgroundColor = [UIColor redColor];
        _nameField.textColor = [UIColor whiteColor];
        return;
    }
    [_defaults setObject:_nameField.text forKey:@"name"];
    [_defaults synchronize];
    
    
    _nameField.backgroundColor = [UIColor whiteColor];
    _nameField.textColor = [UIColor blackColor];
    
    Firebase *rootRef = [[Firebase alloc] initWithUrl:@"https://schtapp.firebaseio.com/"];
    
    Firebase *shits = [rootRef childByAppendingPath: @"Shits"];
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd/MM/YYYY"];
    NSString *date_String=[dateformate stringFromDate:[NSDate date]];
    
    Firebase *newPersonRef = [shits childByAppendingPath: _nameField.text];
    
    NSDictionary *person = @{
                            @"latitude": [NSString stringWithFormat: @"%f", _locationManager.location.coordinate.latitude],
                            @"longitude": [NSString stringWithFormat:@"%f", _locationManager.location.coordinate.longitude],
                            @"date": date_String,
                            };
                              
    [[newPersonRef childByAutoId] setValue: person];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);
    marker.icon = [self resizeImage:[UIImage imageNamed:@"MainTurdIcon"]];
    marker.title = [NSString stringWithFormat:@"%@, %@", _nameField.text, date_String];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    //                marker.snippet = [NSString stringWithFormat:@"%d sellers", [snapshot.value[@"sellers"] count]];
    marker.map = _mapView;
    
    _resetButton.enabled = TRUE;
    _shareButton.enabled = TRUE;
    _placeShitButton.enabled = FALSE;
    
    [_placeShitButton setTitle:@"SCHT PLACED!" forState:UIControlStateNormal];
    [_placeShitButton setTitle:@"SCHT PLACED!" forState:UIControlStateSelected];
    [_placeShitButton setTitle:@"SCHT PLACED!" forState:UIControlStateDisabled];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGPoint) convertToLocation:(FDataSnapshot*) location {
    NSString *lat = location.value[@"latitude"];
    NSString *lon = location.value[@"longitude"];
    CGPoint point = CGPointFromString([NSString stringWithFormat:@"{%@,%@}",lat, lon]);
    return point;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_nameField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}
- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [_nameField resignFirstResponder];
    NSLog([NSString stringWithFormat: @"%f,%f", coordinate.latitude, coordinate.longitude ]);
}

-(UIImage*)resizeImage: (UIImage*) image {
    CGRect rect = CGRectMake(0,0,61,65);
    UIGraphicsBeginImageContext( rect.size );
    [image drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    return [UIImage imageWithData:imageData];
}

-(void) reset {
    _resetButton.enabled = FALSE;
    _shareButton.enabled = FALSE;
    _placeShitButton.enabled = TRUE;
}

-(void)facebookShare {
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Sharing Tutorial", @"name",
                                       @"Build great social apps and get more installs.", @"caption",
                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
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
