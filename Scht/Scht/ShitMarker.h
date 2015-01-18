//
//  ShitMarker.h
//  Scht
//
//  Created by Brian Wang on 1/18/15.
//  Copyright (c) 2015 Scht. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface ShitMarker : GMSMarker
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *descriptionLabel;
@property (strong, nonatomic) NSString *key;
@property (assign, nonatomic) BOOL image;
@end
