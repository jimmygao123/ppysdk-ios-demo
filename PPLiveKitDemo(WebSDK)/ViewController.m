//
//  ViewController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/8/25.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "ViewController.h"

#import "ConfigurationViewController.h"
#import "PlayListController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnPush;
@property (weak, nonatomic) IBOutlet UIButton *btnPull;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.btnPush.layer.cornerRadius = 10;
    [self.btnPush clipsToBounds];

    self.btnPull.layer.cornerRadius = 10;
    self.btnPull.layer.borderWidth = 1.5;
    self.btnPull.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    [self.btnPull clipsToBounds];
}


- (IBAction)doPush:(id)sender {
    ConfigurationViewController *pushConfigureVC = [[ConfigurationViewController alloc]initWithNibName:@"ConfigurationViewController" bundle:nil];
    [self.navigationController pushViewController:pushConfigureVC animated:YES];
}

- (IBAction)doPull:(id)sender {
    PlayListController *playListVC = [[PlayListController alloc]initWithNibName:@"PlayListController" bundle:nil];
    [self.navigationController pushViewController:playListVC animated:YES];
}
@end
