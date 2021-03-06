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
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Firebase/Firebase.h>
#include <stdlib.h>

@interface MapViewController : UIViewController<CLLocationManagerDelegate,GMSMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
}
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UIButton *placeShitButton;

@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *resetButton;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;

@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *descriptionField;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) UIImage *pictureForShit;


@end
