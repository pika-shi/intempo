//
//  ChoiceViewController.m
//  intempo
//
//  Created by Hikaru Takemura on 2014/10/18.
//  Copyright (c) 2014 Hikaru Takemura. All rights reserved.
//

#import "ChoiceViewController.h"

@interface ChoiceViewController ()
{
    AFHTTPSessionManager *manager;
    CLLocation *location;
    NSInteger distance;
    NSString *routeURL;
    NSArray *routeArray;
    NSInteger step;
    NSString *departure;
    NSString *departureStation;
    NSInteger bpm;
    NSTimer *timer;
    double lat;
    double lon;
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITextField *departureField;
@property (weak, nonatomic) IBOutlet UITextField *arrivalField;
- (IBAction)timeButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *route1Button;
@property (weak, nonatomic) IBOutlet UIButton *route2Button;
@property (weak, nonatomic) IBOutlet UIButton *route3Button;
- (IBAction)route1Button:(id)sender;
- (IBAction)route2Button:(id)sender;
- (IBAction)route3Button:(id)sender;
@end

@implementation ChoiceViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // ProgresBar
    [[SVProgressHUD appearance] setHudBackgroundColor:[UIColor blackColor]];
    [[SVProgressHUD appearance] setHudForegroundColor:[UIColor whiteColor]];
    
    // GPS
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    
    // Network
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0;
    
    // Field
    _departureField.delegate = self;
    _arrivalField.delegate = self;
    
    step = 60;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _route1Button.alpha = 0;
    _route2Button.alpha = 0;
    _route3Button.alpha = 0;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_locationManager stopUpdatingLocation];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//***** form *****//
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //if (textField == _departureField) {
    //    [_arrivalField becomeFirstResponder];
    //}
    [textField resignFirstResponder];
    
    return YES;
}

//***** GPS *****//
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //lat = (CLLocation)[locations lastObject].coordinate.latitude;
    location = [locations lastObject];
    lat = location.coordinate.latitude;
    lon = location.coordinate.longitude;
}

- (IBAction)timeButton:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    NSString *URL = [[NSString alloc] initWithFormat:
                     @"http://pikashi.tokyo/intempo/getdata?lat=%f&lon=%f&departure_station=%@&arrival_station=%@&departure_time=%d",
                     //lat, lon, _departureField.text, _arrivalField.text, 2300];
                     lat, lon, @"練馬", @"六本木", 2020];
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:URL parameters:nil success:^(NSURLSessionDataTask *task, NSString *response) {
        [self parseJson:response.description];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"failure: %ld", (long)response.statusCode);
    }];
}

-(void)parseJson:(NSString *)response
{
    response = [self decodeJSONString:response];
    NSString *resStr = [response componentsSeparatedByString:@"\""][1];
    NSArray *resArray = [resStr componentsSeparatedByString:@","];
    distance = [resArray[0] intValue];
    routeURL = resArray[1];
    routeArray = [resArray[2] componentsSeparatedByString:@" "];
    [_route1Button setTitle:routeArray[0] forState:UIControlStateNormal];
    [_route2Button setTitle:routeArray[1] forState:UIControlStateNormal];
    [_route3Button setTitle:routeArray[2] forState:UIControlStateNormal];
    _route1Button.alpha = 1;
    _route2Button.alpha = 1;
    _route3Button.alpha = 1;
    [SVProgressHUD dismiss];
}

- (NSString *)decodeJSONString:(NSString *)input
{
    
    NSString *esc1 = [input stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *quoted = [[@"\"" stringByAppendingString:esc2] stringByAppendingString:@"\""];
    NSData *data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
    NSString *unesc = [NSPropertyListSerialization propertyListFromData:data
                                                       mutabilityOption:NSPropertyListImmutable format:NULL
                                                       errorDescription:NULL];
    assert([unesc isKindOfClass:[NSString class]]);
    return unesc;
}

-(NSInteger)calcTempo:(NSString *)departureTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *current = [NSDate date];
    NSString *currentString = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *departureDate = [dateFormatter dateFromString: [[NSString alloc] initWithFormat:@"%@/%@/%@ %@", [currentString substringToIndex:4], [currentString substringWithRange:NSMakeRange(5, 2)],[currentString substringWithRange:NSMakeRange(8, 2)], departureTime]];
    NSTimeInterval interval = [departureDate timeIntervalSinceDate:current];
    NSInteger delta = round(interval);
    NSInteger tempo = (distance * 6000) / (step * delta);
    return round(tempo/10)*10;
}

-(void)segue
{
    NSArray *arrayForNavigationViewControllers = [[NSArray alloc] initWithArray:self.navigationController.viewControllers];
    TopViewController *topViewController = [[TopViewController alloc] init];
    topViewController = [arrayForNavigationViewControllers objectAtIndex:0];
    topViewController.tempo = [[NSString alloc] initWithFormat:@"%ld", (long)bpm];
    topViewController.routeURL = routeURL;
    topViewController.departureTime = departure;
    topViewController.departureStation = departureStation;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [SVProgressHUD dismiss];
    [timer invalidate];
}

- (IBAction)route1Button:(id)sender {
    NSLog(@"%@", routeArray[0]);
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    departure = [routeArray[0] substringToIndex:5];
    departureStation = [[routeArray[0] componentsSeparatedByString:@"."][3] componentsSeparatedByString:@"-"][0];
    bpm = [self calcTempo:departure];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(segue) userInfo:nil repeats:YES];
}

- (IBAction)route2Button:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    departure = [routeArray[1] substringToIndex:5];
    departureStation = [[routeArray[1] componentsSeparatedByString:@"."][3] componentsSeparatedByString:@"-"][0];
    bpm = [self calcTempo:departure];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(segue) userInfo:nil repeats:YES];
}

- (IBAction)route3Button:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    departure = [routeArray[2] substringToIndex:5];
    departureStation = [[routeArray[2] componentsSeparatedByString:@"."][3] componentsSeparatedByString:@"-"][0];
    bpm = [self calcTempo:departure];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(segue) userInfo:nil repeats:YES];
}
@end