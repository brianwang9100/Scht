//
//  MapViewController.m
//  Scht
//
//  Created by Brian Wang on 1/17/15.
//  Copyright (c) 2015 Scht. All rights reserved.
//

#import "MapViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface MapViewController ()

@end

@implementation MapViewController {
    GMSMapView *_mapView;
    NSUserDefaults *_defaults;
    NSString *_lockedDescription;
    BOOL *_pictureTaken;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //start up the map shit
    [self startMap];
    
    _imageView.hidden = TRUE;
    
    [_placeShitButton addTarget:self action:@selector(placeShit) forControlEvents:UIControlEventTouchUpInside];
    [_shareButton addTarget: self action: @selector(facebookShare) forControlEvents:UIControlEventTouchUpInside];
    [_resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [_cameraButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    
    
    _pictureTaken = FALSE;
    
    _shareButton.enabled = FALSE;
    _resetButton.hidden = TRUE;
    _cameraButton.hidden = FALSE;
    
    _nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _nameField.delegate = self;
    _defaults = [NSUserDefaults standardUserDefaults];
    _nameField.text = [_defaults objectForKey:@"name"];
    
    _descriptionField.delegate = self;
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
                marker.icon = [self resizeImage:[UIImage imageNamed:@"MainTurdIcon"] newSize:CGSizeMake(30, 33)];
            } else {
                marker.icon = [self resizeImage:[UIImage imageNamed:@"DarkTurdIcon"] newSize:CGSizeMake(30, 33)];

            }
            marker.position = CLLocationCoordinate2DMake(point.x, point.y);
            marker.title = [NSString stringWithFormat:@"%@, %@", name, date ];
            marker.snippet = locationEvent.value[@"description"];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = _mapView;
        }
    }];
}
-(void)placeShit {
    if (_nameField.text.length == 0||_descriptionField.text.length >= 50) {
//        _nameField.backgroundColor = [UIColor redColor];
//        _nameField.textColor = [UIColor whiteColor];
        return;
    }
    
    _lockedDescription = _descriptionField.text;

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
                            @"description": _descriptionField.text,
                            };
    
    
    Firebase *randRef = [newPersonRef childByAutoId];
    NSString *referenceKey = randRef.key;
    if (!_pictureTaken) {
        [person setValue:@"false" forKey:@"image"];
    } else {
        [person setValue:@"true" forKey:@"image"];
        
    }
    
    [randRef setValue: person];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);
    marker.icon = [self resizeImage:[UIImage imageNamed:@"MainTurdIcon"] newSize:CGSizeMake(30, 33)];
    marker.title = [NSString stringWithFormat:@"%@, %@", _nameField.text, date_String];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.snippet = _lockedDescription;
    marker.map = _mapView;

    
    _shareButton.enabled = TRUE;
    _placeShitButton.enabled = FALSE;
    _resetButton.hidden = FALSE;
    _cameraButton.hidden = TRUE;
    
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
    [_descriptionField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}
- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [_nameField resignFirstResponder];
    [_descriptionField resignFirstResponder];
    NSLog([NSString stringWithFormat: @"%f,%f", coordinate.latitude, coordinate.longitude ]);
}



- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void) reset {
    _shareButton.enabled = FALSE;
    _placeShitButton.enabled = TRUE;
    _resetButton.hidden = TRUE;
    _cameraButton.hidden = FALSE;
    
    
    _pictureForShit = NULL;
    [_imageView setImage: NULL];
    _imageView.hidden = TRUE;
    _pictureTaken = FALSE;
}
-(void) takePicture {
    UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
    cameraController.delegate = self;
    cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    cameraController.allowsEditing = YES;
    [self presentViewController:cameraController
                       animated:YES completion:nil];
}



-(void)facebookShare {

    NSMutableDictionary *otherParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"\"%@\"", _lockedDescription], @"name",
                                   @"I just had to share about my Scht!", @"caption",
                                   @"Scht is the app that allows you to document and log your shits! Scht and share your most intimate moments!", @"description",
                                   @"Scht.io", @"link",
                                   @"http://i.imgur.com/Ks8wWvT.jpg", @"picture",
                                   nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:otherParams
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

- (void) imagePickerControllerDidCancel:(UIImagePickerController *) picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *originalImage = (UIImage *) [info objectForKey:
                                         UIImagePickerControllerEditedImage];
    _pictureForShit = [self resizeImage: originalImage newSize:CGSizeMake(100,100)];
    _imageView.hidden = FALSE;
    [_imageView setImage: _pictureForShit];
    _pictureTaken = TRUE;
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
