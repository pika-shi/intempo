//
//  NetworkManager.h
//  intempo
//
//  Created by Hikaru Takemura on 2014/10/12.
//  Copyright (c) 2014年 Hikaru Takemura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface NetworkManager : AFHTTPSessionManager
-(void)getNearestStation:(NSString*)lat lon:(NSString*)lon;
-(void)getDistanceToStation:(NSString*)fromlat fromlon:(NSString*)fromlon tolat:(NSString*)tolat tolon:(NSString*)tolon;
-(NSString*)requestURL:(NSString*)URL;
@end
