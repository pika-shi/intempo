//
//  ViewController.m
//  intempo
//
//  Created by Hikaru Takemura on 2014/10/12.
//  Copyright (c) 2014 Hikaru Takemura. All rights reserved.
//

#import "TopViewController.h"

@interface TopViewController ()
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *choiceButton;
@property (weak, nonatomic) IBOutlet UIView *tempoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UILabel *equalLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempoLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIImageView *hereImage;
@property (weak, nonatomic) IBOutlet UILabel *hereLabel;
@property (weak, nonatomic) IBOutlet UILabel *dotLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thereImage;
@property (weak, nonatomic) IBOutlet UILabel *thereLabel;
@property (weak, nonatomic) IBOutlet UILabel *departureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *jacketView;
@property(nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIButton *musicButton;
- (IBAction)musicButton:(id)sender;
@end

@implementation TopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tempoView.layer.borderWidth = 0.5f;
    _tempoView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _tempoView.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (!_tempo) {
        _detailLabel.alpha = 0;
        _detailImage.alpha = 0;
        _detailButton.alpha = 0;
        _tempoView.alpha = 0;
        _tempoLabel.alpha = 0;
        _equalLabel.alpha = 0;
        _hereImage.alpha = 0;
        _hereLabel.alpha = 0;
        _dotLabel.alpha = 0;
        _currentLabel.alpha = 0;
        _thereImage.alpha = 0;
        _thereLabel.alpha = 0;
        _departureLabel.alpha = 0;
        _jacketView.alpha = 0;
        _musicButton.alpha = 0;
        _titleLabel.alpha = 1;
        _choiceButton.alpha = 1;
        _backgroundView.image = [UIImage imageNamed:@"bg1.png"];
    } else {
        _detailLabel.alpha = 1;
        _detailImage.alpha = 1;
        _detailButton.alpha = 1;
        _tempoView.alpha = 1;
        _tempoLabel.alpha = 1;
        _equalLabel.alpha = 1;
        _hereImage.alpha = 1;
        _hereLabel.alpha = 1;
        _dotLabel.alpha = 1;
        _currentLabel.alpha = 1;
        _thereImage.alpha = 1;
        _thereLabel.alpha = 1;
        _departureLabel.alpha = 1;
        _jacketView.alpha = 0.8;
        _musicButton.alpha = 0.8;
        _titleLabel.alpha = 0;
        _choiceButton.alpha = 0;
        _backgroundView.image = [UIImage imageNamed:@"bg2.png"];
        //_tempoLabel.text = _tempo;
        NSDate *current = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
        NSString *currentStr = [formatter stringFromDate:current];
        _currentLabel.text = currentStr;
        _departureLabel.text = _departureTime;
        _thereLabel.text = [[NSString alloc] initWithFormat:@"%@駅", _departureStation];
        NSString* bpm = [self getMusic:[_tempo intValue]];
        _jacketView.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@.jpg", bpm]];
        NSString *path = [[NSBundle mainBundle] pathForResource:bpm ofType:@"mp3"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [_audioPlayer setDelegate:self];
        [_audioPlayer play];
    }
}

-(NSString *)getMusic:(NSInteger)tempo
{
    NSInteger bpm;
    if (tempo <= 85) {
        bpm = 80;
    } else if (tempo <= 95) {
        bpm = 90;
    } else if (tempo <= 110) {
        bpm = 100;
    } else if (tempo <= 145) {
        bpm = 120;
    } else {
        bpm = 170;
    }
    return [[NSString alloc] initWithFormat:@"%ld", (long)bpm];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"toWebViewController"]) {
        WebViewController *webViewController = (WebViewController*)[segue destinationViewController];
        webViewController.url = _routeURL;
    }
}

- (IBAction)musicButton:(id)sender {
    if (_audioPlayer.playing){
        [_audioPlayer stop];
    }
    else{
        [_audioPlayer play];
    }
}
@end
