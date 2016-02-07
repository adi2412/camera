//
//  ServerPickerViewController.h
//  CameraApp
//
//  Created by Aditya Raisinghani on 2/7/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanLAN.h"

@interface ServerPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ScanLANDelegate>

@end
