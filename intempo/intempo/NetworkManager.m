//
//  NetworkManager.m
//  intempo
//
//  Created by Hikaru Takemura on 2014/10/12.
//  Copyright (c) 2014年 Hikaru Takemura. All rights reserved.
//

#import "NetworkManager.h"
@interface NetworkManager ()
{
    NSString *jsonResponse;
}
@end

@implementation NetworkManager

-(void)getNearestStation:(NSString*)lat lon:(NSString*)lon
{
     NSString *URL = [[NSString alloc] initWithFormat: @"/v1/json/geo/station?geoPoint=35.6783055555556,139.770441666667,tokyo,1000"];
     [self requestURL:URL];
}

-(void)getDistanceToStation:(NSString*)fromlat fromlon:(NSString*)fromlon tolat:(NSString*)tolat tolon:(NSString*)tolon
{
    NSData *data;
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:
                                       @"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%@,%@&destinations=%@,%@&sensor=false", fromlat, fromlon, tolat, tolon]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"yeah: %@", response);
}

-(void)getDistanceToStation2:(NSString*)fromlat fromlon:(NSString*)fromlon tolat:(NSString*)tolat tolon:(NSString*)tolon
{
    NSString *URL = [[NSString alloc] initWithFormat:
                     @"http://maps.googleapis.com/maps/api/distancematrix/json?origins=%@,%@&destinations=%@,%@&sensor=false", fromlat, fromlon, tolat, tolon];
    NSString *response = [self requestURL:URL];
    NSLog(@"yeah: %@", response);
}

-(NSString*)requestURL:(NSString*)URL
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0;
    [manager GET:URL parameters:nil success:^(NSURLSessionDataTask *task, NSString *responseObject) {
        jsonResponse = responseObject;
        NSLog(@"success: %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"failure: %ld", (long)response.statusCode);
    }];
    
    return jsonResponse;
}
@end
