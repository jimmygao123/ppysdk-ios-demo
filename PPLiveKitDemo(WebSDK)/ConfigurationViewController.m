//
//  ConfigurationViewController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by Jimmy on 16/9/7.
//  Copyright © 2016年 高国栋. All rights reserved.
//
#import "HTTPManager.h"
#import "ConfigurationViewController.h"
#import "MBProgressHUD.h"

@interface ConfigurationViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIButton *btnGroup480P;
@property (weak, nonatomic) IBOutlet UIButton *btnGroup540P;
@property (weak, nonatomic) IBOutlet UIButton *btnGroup720P;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) MBProgressHUD *processHUD;

@property (assign, nonatomic) BOOL btn480PSelected;
@property (assign, nonatomic) BOOL btn540PSelected;
@property (assign, nonatomic) BOOL btn720PSelected;

@property (assign, nonatomic) BOOL isNeedFetchPushURLFromServer;
@property (copy, nonatomic) NSString *room;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConstraitCenterY;  //btn540P

@end

@implementation ConfigurationViewController{
    dispatch_semaphore_t sem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self initData];
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}
-(void)initData{
    sem = dispatch_semaphore_create(0);
    _btn480PSelected = YES; //默认为480P；
    _width = 480;
    _height = 640;
    _isNeedFetchPushURLFromServer = YES;
}

-(void)initUI{
    self.btnOK.layer.cornerRadius = 15;
    [self.btnOK clipsToBounds];
    
    self.textField.delegate = self;
    self.textField.backgroundColor = [UIColor clearColor];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入房间号" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.3]}];
    
    if(self.type == 1){
        self.btnGroup480P.hidden = YES;
        self.btnGroup540P.hidden = YES;
        self.btnGroup720P.hidden = YES;
    }
    
    [self updateUI];
}

-(void)updateUI{
    UIImage *img1 = self.btn480PSelected ? [UIImage imageNamed:@"流畅-亮"] : [UIImage imageNamed:@"流畅-暗"];
    [self.btnGroup480P setBackgroundImage:img1 forState:UIControlStateNormal];
    
    img1 = self.btn540PSelected ? [UIImage imageNamed:@"标清-亮"] : [UIImage imageNamed:@"标清-暗"];
    [self.btnGroup540P setBackgroundImage:img1 forState:UIControlStateNormal];
    
    img1 = self.btn720PSelected ? [UIImage imageNamed:@"高清-亮"] : [UIImage imageNamed:@"高清-暗"];
    [self.btnGroup720P setBackgroundImage:img1 forState:UIControlStateNormal];

}

#pragma mark ----
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNetworkState:) name:kNotification_NetworkStateChanged object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotification_NetworkStateChanged object:nil];
}

-(void)showNetworkState:(NSNotification *)info{
    NSNumber *value = (NSNumber *)info.object;
    NSString *tip = nil;
    switch (value.integerValue) {
        case AFNetworkReachabilityStatusUnknown:
            tip = @"网络异常发生未知错误";
            break;
        case AFNetworkReachabilityStatusNotReachable:
            tip = @"网络断开,请检查网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            tip = @"当前使用3G/4G网络";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            tip = @"当前使用Wi-Fi";
            break;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = tip;
    [hud hideAnimated:YES afterDelay:2.f];
}

#pragma mark --Action--
- (IBAction)do720P:(id)sender {
    self.btn480PSelected = NO;
    self.btn540PSelected = NO;
    self.btn720PSelected = YES;
    
    [self updateUI];
    
    _width = 720;
    _height = 1280;
}
- (IBAction)do540P:(id)sender {
    self.btn480PSelected = NO;
    self.btn540PSelected = YES;
    self.btn720PSelected = NO;
    
    [self updateUI];
    
    _width = 544;
    _height = 960;
}
- (IBAction)do480P:(id)sender {
    self.btn480PSelected = YES;
    self.btn540PSelected = NO;
    self.btn720PSelected = NO;
    
    [self updateUI];
    
    _width = 480;
    _height = 640;
}

- (IBAction)doExit:(id)sender {
    [self.delegate viewControllerDoExit:self];
}
- (IBAction)doOK:(id)sender {
    
    if(![self isRightRoomIDFormat])
        return;
    
    AFNetworkReachabilityStatus netState = [HTTPManager shareInstance].currentNetworkStatus;
    if(netState == AFNetworkReachabilityStatusNotReachable ||
       netState == AFNetworkReachabilityStatusUnknown){
        
        [self throwError:5 info:@"本地网络关闭，不可用"];
    }else{
        self.processHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        
        if(self.type == 0){
            NSString *pushRTMP = [self getPushURLFromLocal];
            NSLog(@"pushRTMP = %@",pushRTMP);
            if(pushRTMP == nil){
                [self getPushURLWithRoomID];
            }else{
                [self detectWetherCreateRoomNeeded];

                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                    if(weakSelf.isNeedFetchPushURLFromServer){
                        [weakSelf getPushURLWithRoomID];
                        NSLog(@"fetch push rtmp address from server");
                    }else{
                        NSLog(@"fetch push rtmp address from local");
                        [weakSelf.delegate viewController:weakSelf didFetchPushRTMPAddress:pushRTMP];
                    }
                });
                
            }
        }else if(self.type == 1){
            [self getPullURLWithRoomID];
        }
    }
}



#pragma mark --Custom Method--
-(void)throwError:(int)errorCode info:(NSString *)errorInfo{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.processHUD){
            [weakSelf.processHUD hideAnimated:YES];
        }
    });
    
    NSString *displayInfo = errorInfo;
    if(errorCode == 3){
        NSArray *componets = [errorInfo componentsSeparatedByString:@":"];
        NSLog(@"componets = %@",componets);
        if([componets[0] isEqualToString:@"399995"]){
            displayInfo = @"房间号已经存在";
        }
    }else if(errorCode == 17){
        NSArray *componets = [errorInfo componentsSeparatedByString:@":"];
        NSLog(@"componets = %@",componets);
        displayInfo = @"获取拉流地址失败";
    }else if(errorCode == 13){
        displayInfo = @"流状态错误";
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = displayInfo;
        
        [hud hideAnimated:YES afterDelay:2.f];
    });
}

-(void)getPullURLWithRoomID{
    __weak typeof (self) weakSelf = self;
    [HTTPManager shareInstance].roomID = self.room;
    [[HTTPManager shareInstance] fetchPlayURL:^(NSDictionary *dic) {
        if(dic != nil){
            NSLog(@"jimmy_dic = %@",dic);
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                NSString *url = (NSString *)[data objectForKey:@"rtmpUrl"];
                NSString *flvURL = [data objectForKey:@"hdlUrl"];
                if(url){
                    [[HTTPManager shareInstance] fetchStreamStatusSuccess:^(NSDictionary *dic) {
                        if(dic != nil){
                            NSLog(@"%s,dic = %@",__FUNCTION__,dic);
                            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                                NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                                NSString *liveState = (NSString *)[data objectForKey:@"liveStatus"];
                                NSString *streamState = (NSString *)[data objectForKey:@"streamStatus"];
                                if(streamState == nil){
                                    [weakSelf throwError:11 info:@"资源不存在"];
                                }else if([streamState isEqualToString:@"ok"] && [liveState isEqualToString:@"stopped"]){
                                    [weakSelf throwError:12 info:@"主播已离开房间"];
                                }else if([streamState isEqualToString:@"ok"] && [liveState isEqualToString:@"living"]){
                                    [weakSelf.delegate viewController:weakSelf didFetchPullRTMPAddress:url];
                                }else{
                                    NSString *status = [NSString stringWithFormat:@"live status:%@,streaStatus:%@",liveState,streamState];
                                    [weakSelf throwError:13 info:status];
                                }
                            }else{
                                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                                if([errCode isEqualToString:@"1001"]){
                                    [self throwError:15 info:@"主播还未开播"];
                                }else{
                                    [self throwError:14 info:[NSString stringWithFormat:@"%@:%@",errCode,errorInfo]];
                                }
                                
                            }
                        }
                    } failured:^(NSError *err) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.processHUD hideAnimated:YES];
                        });
                        if(err){
                            [weakSelf throwError:2 info:@"网络连接断开，不可用"];
                        }
                    }];
                }else{
                    [weakSelf throwError:4 info:@"无效的url或者token"];
                }
            }else{
                
                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
                if([errCode isEqualToString:@"300005"]){
                    [self throwError:16 info:@"房间不存在"];
                }else{
                    [self throwError:17 info:[NSString stringWithFormat:@"%@:%@",errCode,errorInfo]];
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.processHUD hideAnimated:YES];
            });
        }
    } Failured:^(NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.processHUD hideAnimated:YES];
        });
        if(err){
            [weakSelf throwError:2 info:@"网络连接断开，不可用"];
        }
    }];
}
-(NSString *)getPushURLFromLocal{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"KRoomID-RTMPAddr"];

    NSLog(@"get KRoomID-RTMPAddr from local: %@",dic);
    NSLog(@"self.room = %@",self.room);
    NSString *rtmp = (NSString *)[dic objectForKey:self.room];
    NSLog(@"rtmp = %@",rtmp);
    return rtmp;
}

-(void)savePushURLToLocal:(NSString *)rtmpURL{
    
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc]init];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"KRoomID-RTMPAddr"];
    for(NSString *room in [dic allKeys]){
        [newDic setObject:[dic objectForKey:room]  forKey:room];
    }
    [newDic setObject:rtmpURL forKey:self.room];
    NSLog(@"save KRoomID-RTMPAddr from local: %@",newDic);
    [[NSUserDefaults standardUserDefaults] setObject:newDic forKey:@"KRoomID-RTMPAddr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)getPushURLWithRoomID{
    __weak typeof(self) weakSelf = self;
    [HTTPManager shareInstance].roomID = self.room;
    [[HTTPManager shareInstance] fetchPushRTMPAddressSuccess:^(NSDictionary *dic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.processHUD hideAnimated:YES];
        });
        if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
            NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
            NSString *url = (NSString *)[data objectForKey:@"pushUrl"];
            NSString *token = (NSString *)[data objectForKey:@"token"];
            if(url && token){
                NSString *rtmpAddress = [[url stringByAppendingString:@"/"] stringByAppendingString:token];
                NSLog(@"rtmpAddress = %@",rtmpAddress);
                [weakSelf savePushURLToLocal:rtmpAddress];
                [weakSelf.delegate viewController:weakSelf didFetchPushRTMPAddress:rtmpAddress];
                
            }else{
                [weakSelf throwError:4 info:@"无效的url或者token"];
            }
        }else{
            NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
            NSString *errCode = (NSString *)[dic objectForKey:@"err"];
            [weakSelf throwError:3 info:[[errCode stringByAppendingString:@":"] stringByAppendingString:errorInfo] ];
        }
        
    } failured:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.processHUD hideAnimated:YES];
        });
        if(error){
            [weakSelf throwError:2 info:@"网络连接断开，不可用"];
        }
    }];

}
//本地格式检测
-(BOOL)isRightRoomIDFormat{
    BOOL rightFormat = NO;
    
    self.room = self.textField.text;
    [self.textField resignFirstResponder];
    
    if(self.room == nil || self.room.length <= 0){
        [self throwError:1 info:@"房间名不能为空"];
    }else{
        rightFormat = YES;
    }
    return rightFormat;
}

-(void)detectWetherCreateRoomNeeded{
    
    __weak typeof(self) weakSelf = self;
    [HTTPManager shareInstance].roomID = self.room;
    
    [[HTTPManager shareInstance] fetchStreamStatusSuccess:^(NSDictionary * dic) {
        if(dic != nil){
            NSLog(@"%s,dic = %@",__FUNCTION__,dic);
            if([[dic objectForKey:@"err"] isEqualToString:@"0"]){
                NSDictionary *data = (NSDictionary *)[dic objectForKey:@"data"];
                NSString *liveState = (NSString *)[data objectForKey:@"liveStatus"];
                NSString *streamState = (NSString *)[data objectForKey:@"streamStatus"];
                if([streamState isEqualToString:@"ok"] && [liveState isEqualToString:@"stopped"]){
                    weakSelf.isNeedFetchPushURLFromServer = YES;
                }else{
                    weakSelf.isNeedFetchPushURLFromServer = NO;
                }
            }else{
                weakSelf.isNeedFetchPushURLFromServer = YES;
                //                NSString *errorInfo = (NSString *)[dic objectForKey:@"msg"];
                //                NSString *errCode = (NSString *)[dic objectForKey:@"err"];
            }
        }
        dispatch_semaphore_signal(sem);
        
    } failured:^(NSError *error) {
        dispatch_semaphore_signal(sem);
    }];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark --Getter and Setter--
-(NSString *)roomID{
    return self.room;
}

#pragma mark --Keyboard Notification--
- (void)keyboardWillShow:(NSNotification *)notification{

    CGRect kbFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat verticalSpaceBtnOKToBottomEdge = [UIScreen mainScreen].bounds.size.height - self.btnOK.frame.origin.y - self.btnOK.frame.size.height;
    CGFloat keyboardHeight = kbFrame.size.height;
    NSLog(@"verticalSpaceBtnOKToBottomEdge = %f,keyboardHeight = %f",verticalSpaceBtnOKToBottomEdge,keyboardHeight);
    if(verticalSpaceBtnOKToBottomEdge < keyboardHeight){
        self.ConstraitCenterY.constant = verticalSpaceBtnOKToBottomEdge - keyboardHeight;
        [self.view setNeedsLayout];
    }
}

- (void)keyboardWillHidden{
    self.ConstraitCenterY.constant = 0;
    [self.view setNeedsLayout];
}
#pragma mark --UITextFieldDelegate--
- (BOOL)textFieldShouldReturn:(UITextField *)aTextField{
    if(aTextField == self.textField){
        self.room = aTextField.text;
    }
    
    [aTextField resignFirstResponder];
    return YES;
}
@end
