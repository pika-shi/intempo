//
//  MusicListViewController.m
//  intempo
//
//  Created by Hikaru Takemura on 2014/11/03.
//  Copyright (c) 2014年 Hikaru Takemura. All rights reserved.
//

#import "MusicListViewController.h"

@interface MusicListViewController ()
- (IBAction)closeButton:(id)sender;
@end

@implementation MusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButton:(id)sender {
    //NSArray *arrayForNavigationViewControllers = [[NSArray alloc] initWithArray:self.navigationController.viewControllers];
    //TopViewController *topViewController = [[TopViewController alloc] init];
    //topViewController = [arrayForNavigationViewControllers objectAtIndex:0];
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
