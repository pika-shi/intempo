//
//  WebViewController.h
//  intempo
//
//  Created by Hikaru Takemura on 2014/10/18.
//  Copyright (c) 2014 Hikaru Takemura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, strong) NSString *url;
@end
