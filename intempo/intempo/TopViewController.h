//
//  ViewController.h
//  intempo
//
//  Created by Hikaru Takemura on 2014/10/12.
//  Copyright (c) 2014 Hikaru Takemura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "AFHTTPSessionManager.h"
#import "WebViewController.h"

@interface TopViewController : UIViewController<AVAudioPlayerDelegate>
@property (nonatomic, strong) NSString *departureTime;
@property (nonatomic, strong) NSString *departureStation;
@property (nonatomic, strong) NSString *tempo;
@property (nonatomic, strong) NSString *routeURL;
@end

