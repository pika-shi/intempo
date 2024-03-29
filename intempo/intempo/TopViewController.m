//
//  ViewController.m
//  intempo
//
//  Created by Hikaru Takemura on 2014/10/12.
//  Copyright (c) 2014 Hikaru Takemura. All rights reserved.
//

#import "TopViewController.h"

@interface TopViewController ()
{
    UIImageView *tempoAnimationBar;
    NSDate *current;
    NSDateFormatter *formatter;
    NSString *currentStr;
    NSTimer *timer;
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *choiceButton;
@property (weak, nonatomic) IBOutlet UIView *tempoView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UIImageView *tempoImage;
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
@property (weak, nonatomic) IBOutlet UIView *stopView;
@property (weak, nonatomic) IBOutlet UILabel *restLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)playButton:(id)sender;
- (IBAction)finishButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *tempoGradBar;
@property (weak, nonatomic) IBOutlet UIView *tempoBar;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UIImageView *musicListButton;
@end

@implementation TopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _stopView.alpha = 0;
    _restLabel.alpha = 0;
    _finishButton.alpha = 0;
    _playButton.alpha = 0;
    UIImage *tempoGBar = [UIImage imageNamed:@"tempobar.png"];
    tempoAnimationBar = [[UIImageView alloc]initWithImage:tempoGBar];
    [self.view addSubview:tempoAnimationBar];
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    [self setChoiceButtonText:@"ROUTING   SET"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

-(void)setChoiceButtonText:(NSString *)text
{
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSKernAttributeName
                           value:[NSNumber numberWithFloat:1.5f]
                           range:NSMakeRange(0, attributedText.length)];
    [_choiceButton setAttributedTitle:attributedText forState:UIControlStateNormal];
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
        _tempoImage.alpha = 0;
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
        _tempoBar.alpha = 0;
        _tempoGradBar.alpha = 1;
        _artistImage.alpha = 0;
        _artistNameLabel.alpha = 0;
        _albumNameLabel.alpha = 0;
        _musicListButton.alpha = 1;
        [self setChoiceButtonText:@"ROUTING   SET"];
        _backgroundView.image = [UIImage imageNamed:@"bg1.png"];
    } else {
        _detailLabel.alpha = 1;
        _detailImage.alpha = 1;
        _detailButton.alpha = 1;
        _tempoView.alpha = 1;
        _tempoLabel.alpha = 1;
        _tempoImage.alpha = 1;
        _hereImage.alpha = 1;
        _hereLabel.alpha = 1;
        _dotLabel.alpha = 1;
        _currentLabel.alpha = 1;
        _thereImage.alpha = 1;
        _thereLabel.alpha = 1;
        _departureLabel.alpha = 1;
        _jacketView.alpha = 0.8;
        _musicButton.alpha = 1;
        _titleLabel.alpha = 0;
        _tempoBar.alpha = 1;
        _tempoGradBar.alpha = 0;
        _artistImage.alpha = 1;
        _artistNameLabel.alpha = 1;
        _albumNameLabel.alpha = 1;
        _musicListButton.alpha = 0;
        [self setChoiceButtonText:@""];
        _backgroundView.image = [UIImage imageNamed:@"bg2.png"];
        _tempoLabel.text = _tempo;
        current = [NSDate date];
        currentStr = [formatter stringFromDate:current];
        _currentLabel.text = currentStr;
        _departureLabel.text = _departureTime;
        _thereLabel.text = [[NSString alloc] initWithFormat:@"%@駅", _departureStation];
        NSString* bpm = [self getMusic:[_tempo intValue]];
        _jacketView.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@.jpg", bpm]];
        _artistImage.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@.png", bpm]];
        _artistImage.layer.cornerRadius = 25.0f;
        _artistImage.clipsToBounds = YES;
        NSString *path = [[NSBundle mainBundle] pathForResource:bpm ofType:@"mp3"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        NSError *error = nil;
        if ([_play  isEqual: @"Y"]){
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [_audioPlayer setDelegate:self];
            [_audioPlayer play];
            _play = @"N";
        }
        
        tempoAnimationBar.alpha = 1;
        tempoAnimationBar.frame = CGRectMake(-320, 0, 320, 5);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:60.0f/[_tempo intValue]];
        [UIView setAnimationRepeatCount:10000];
        [UIView setAnimationRepeatAutoreverses:NO];
        tempoAnimationBar.frame = CGRectMake(320, 0, 320, 5);
        [UIView commitAnimations];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                                 target:self
                                               selector:@selector(onTimer:)
                                               userInfo:nil
                                                repeats:YES];
    }
}

-(void)onTimer:(NSTimer*)timer {
    current = [NSDate date];
    currentStr = [formatter stringFromDate:current];
    _currentLabel.text = currentStr;
}

-(NSString *)getMusic:(NSInteger)tempo
{
    NSInteger bpm;
    if (tempo <= 85) {
        bpm = 80;
        _artistNameLabel.text = @"いきものがかり";
        _albumNameLabel.text = @"歩いていこう";
    } else if (tempo <= 95) {
        bpm = 90;
        _artistNameLabel.text = @"ASIAN KUNG-FU GENERATION";
        _albumNameLabel.text = @"リライト";
    } else if (tempo <= 110) {
        bpm = 100;
        _artistNameLabel.text = @"Are you Gonna Be My Girl";
        _albumNameLabel.text = @"JET";
    } else if (tempo <= 145) {
        bpm = 120;
        _artistNameLabel.text = @"ゆず";
        _albumNameLabel.text = @"夏色";
    } else {
        bpm = 170;
        _artistNameLabel.text = @"AKB48";
        _albumNameLabel.text = @"ヘビーローテション";
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
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void){
                             _stopView.alpha = 0.9;
                             //_restLabel.alpha = 1.0;
                             _finishButton.alpha = 1.0;
                             _playButton.alpha = 1.0;
                             tempoAnimationBar.alpha = 0;
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
}
- (IBAction)playButton:(id)sender {
    [_audioPlayer play];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         _stopView.alpha = 0;
                         _restLabel.alpha = 0;
                         _finishButton.alpha = 0;
                         _playButton.alpha = 0;
                         tempoAnimationBar.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (IBAction)finishButton:(id)sender {
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         _stopView.alpha = 0;
                         _restLabel.alpha = 0;
                         _finishButton.alpha = 0;
                         _playButton.alpha = 0;
                     }
                     completion:^(BOOL finished){
                     }];
    _detailLabel.alpha = 0;
    _detailImage.alpha = 0;
    _detailButton.alpha = 0;
    _tempoView.alpha = 0;
    _tempoLabel.alpha = 0;
    _tempoImage.alpha = 0;
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
    _tempoBar.alpha = 0;
    _tempoGradBar.alpha = 1;
    _artistImage.alpha = 0;
    _artistNameLabel.alpha = 0;
    _albumNameLabel.alpha = 0;
    _musicListButton.alpha = 1;
    [self setChoiceButtonText:@"ROUTING   SET"];
    _backgroundView.image = [UIImage imageNamed:@"bg1.png"];
    _tempo = 0;
}
@end
