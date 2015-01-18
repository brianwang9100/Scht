//
//  ShitInfoWindow.h
//  Scht
//
//  Created by Brian Wang on 1/18/15.
//  Copyright (c) 2015 Scht. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShitInfoWindow : UIView

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
