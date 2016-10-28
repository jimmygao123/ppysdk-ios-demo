//
//  PlayListController.m
//  PPLiveKitDemo(WebSDK)
//
//  Created by admin on 2016/10/13.
//  Copyright © 2016年 高国栋. All rights reserved.
//

#import "PlayListController.h"
#import "FlowCell.h"
#import "SVPullToRefresh.h"
#import "PlayListHelper.h"
#import "NotifyView.h"
#import <PPYLiveKit/PPYLiveKit.h>
#import "PullViewController.h"


static NSString * reuseIdentifier = @"flowcell";

@interface PlayListController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PlayerListHelperDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UICollectionView *flowView;
@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UILabel *lblTip;

@property (strong, nonatomic) PlayListHelper *helper;
@property (strong, nonatomic) NSMutableArray *liveList;
@property (strong, nonatomic) NSMutableArray *VODList;

@property (assign, nonatomic) int pageNum;
@property (assign, nonatomic) PlayerType playerType;

@property (strong, nonatomic) PullViewController *pullController;
@property (strong, nonatomic) UITapGestureRecognizer *clickGesture;
@property (strong, nonatomic) UIButton *cancelButton;
@property  CGPoint beginPoint;;
@property (assign, nonatomic) BOOL isDefaultWindowPlayer; //表示第一次是否默认窗口播放, 默认NO

@end

@implementation PlayListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateNavBarAndStatusBar];
    [self setupCollectionView];
    [self setupRefreshView];
    
    self.helper = [[PlayListHelper alloc]init];
    self.helper.delegate = self;
    self.playerType = PlayerType_Live;
    
    [self.flowView triggerPullToRefresh]; //启动页面时请求结果, ViewWillAppear不需要刷新
}

-(void)doPullRefresh{
    if(self.playerType == PlayerType_Live){
        self.pageNum = 1;
        [self.helper fetchLiveListWithPageNum:self.pageNum];
    }else if(self.playerType == PlayerType_VOD){
        self.pageNum = 1;
        [self.helper fetchVODListWithPageNum:self.pageNum];
    }
}
-(void)doInfiniteScrolling{
    if(self.playerType == PlayerType_Live){
        self.pageNum ++;
        [self.helper fetchLiveListWithPageNum:self.pageNum];
    }else if(self.playerType == PlayerType_VOD){
        self.pageNum ++;
        [self.helper fetchVODListWithPageNum:self.pageNum];
    }
}

-(void)doBack{
    if(self.playerType == PlayerType_VOD){
        self.playerType = PlayerType_Live;
        [self.flowView triggerPullToRefresh];
    }else if(self.playerType == PlayerType_Live){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)promote{
    if(self.playerType == PlayerType_Live){
        self.playerType = PlayerType_VOD;
        [self.flowView triggerPullToRefresh];
    }
}

-(void)updateNavBarAndStatusBar{
    [[UINavigationBar appearance] setBarTintColor:self.view.backgroundColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    [self.navBar setTranslucent:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"播放列表-back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack)];
    self.navItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"sss.png"] style:UIBarButtonItemStylePlain target:self action:@selector(promote)];
}

-(void)setupCollectionView{
    self.flowView.backgroundColor = [UIColor whiteColor];
    
    self.flowView.delegate = self;
    self.flowView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"FlowCell" bundle:[NSBundle mainBundle]];
    [self.flowView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
}

-(void)setupRefreshView{
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.flowView addPullToRefreshWithActionHandler:^{
        [weakSelf doPullRefresh];
    }];
    [weakSelf.flowView addInfiniteScrollingWithActionHandler:^{
        [weakSelf doInfiniteScrolling];
    }];
}

#pragma mark ---PlayerListHelperDelegate---
-(void)didFetchLiveListSuccess:(NSMutableArray *)array{
    if(self.pageNum == 1){    //下拉刷新只显示第一页内容
        self.liveList = array;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.flowView.pullToRefreshView stopAnimating];
            [self.flowView.infiniteScrollingView stopAnimating];
        });
        
    }else if(self.pageNum > 1){   //上拉加载需要累加
        for(NSDictionary *model in array){
            [self.liveList addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.flowView.infiniteScrollingView stopAnimating];
        });
    }

    if(self.liveList.count == 0){
        self.imgBackground.hidden = NO;
        self.lblTip.text = @"当前无直播视频，去看看回放视频吧";
        self.lblTip.hidden = NO;
    }else{
        self.imgBackground.hidden = YES;
        self.lblTip.hidden = YES;
    }
    
    NSLog(@"current Live list = %@",self.liveList);
    [self.flowView reloadData];
}
-(void)didFetchLiveListFailured:(PlayerListErrorType)type Code:(int)errorCode Info:(NSString *)errInfo{
    NSLog(@"%s,errorCode = %d,errorInfo = %@",__FUNCTION__,errorCode,errInfo);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.flowView.pullToRefreshView stopAnimating];
        if(self.liveList.count == 0){
            self.imgBackground.hidden = NO;
            self.lblTip.hidden = NO;
            self.lblTip.text = @"加载出错了...";
        }else{
            self.imgBackground.hidden = YES;
            self.lblTip.hidden = YES;
        }
    });
}
-(void)didFetchVODListSuccess:(NSMutableArray *)array{
    if(self.pageNum == 1){    //下拉刷新只显示第一页内容
        self.VODList = array;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.flowView.pullToRefreshView stopAnimating];
            [self.flowView.infiniteScrollingView stopAnimating];
        });
        
    }else if(self.pageNum > 1){   //上拉加载需要累加
        for(NSDictionary *model in array){
            [self.VODList addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.flowView.infiniteScrollingView stopAnimating];
        });
    }
    
    if(self.VODList.count == 0){
        self.imgBackground.hidden = NO;
        self.lblTip.hidden = NO;
        self.lblTip.text = @"当前无播放视频，去看看直播视频吧";
    }else{
        self.imgBackground.hidden = YES;
        self.lblTip.hidden = YES;
    }
    NSLog(@"current VOD list = %@",self.VODList);
    [self.flowView reloadData];
}

-(void)didFetchVODListFailued:(PlayerListErrorType)type Code:(int)errorCode Info:(NSString *)errInfo{
    NSLog(@"%s,errorCode = %d,errorInfo = %@",__FUNCTION__,errorCode,errInfo);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.flowView.infiniteScrollingView stopAnimating];
        if(self.VODList.count == 0){
            self.imgBackground.hidden = NO;
            self.lblTip.hidden = NO;
            self.lblTip.text = @"加载出错了...";
        }else{
            self.imgBackground.hidden = YES;
            self.lblTip.hidden = YES;
        }
    });
}
#pragma mark ---UICollectionViewDelegate---
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"index = %@",indexPath);
    
    [[PPYPlayEngine shareInstance] stopPlayerBlackDisplayNeeded:NO];
    
    //悬浮窗口播放
    if (!self.pullController) {
        self.pullController = [[PullViewController alloc]initWithNibName:@"PullViewController" bundle:nil];
    }
    
    if(self.playerType == PlayerType_Live){
        NSDictionary *model = (NSDictionary *)self.liveList[indexPath.item];
        [self.helper fetchLivingURLsWithRoomID: [model objectForKey:kRoomName] SuccessBlock:^(NSDictionary *dic) {
            NSString *RTMPURL = (NSString *)[dic objectForKey:kRTMPURL];
            
            self.pullController.sourceType = PPYSourceType_Live;
            self.pullController.playAddress = RTMPURL;
            self.pullController.usefulInfo = dic;
            
        } FailuredBlock:^(int errCode, NSString *errInfo) {
            NSLog(@"流地址获取失败,errCode = %d,erroInfo = %@",errCode,errInfo);
        }];
        
    }else if(self.playerType == PlayerType_VOD){
        NSDictionary *model = (NSDictionary *)self.VODList[indexPath.item];
        NSString *VODURL = [self.helper fetchVodURLWithChannelWebID: [model objectForKey:kChannelWebID]];
        NSLog(@"vod playAddress=%@", VODURL);
        self.pullController.sourceType = PPYSourceType_VOD;
        self.pullController.playAddress = VODURL;
        self.pullController.windowPlayerDisabled = NO;
    }
    
    self.pullController.playListController = self;
    if (self.isDefaultWindowPlayer) {
        [self.pullController.view setFrame:CGRectMake(10, 100, 200, 150)];//小窗
    } else {
        [self.pullController.view setFrame:[UIScreen mainScreen].bounds];//全屏
    }
    
    [self addChildViewController:self.pullController];
    [self.view addSubview:self.pullController.view];
    self.pullController.isWindowPlayer = self.isDefaultWindowPlayer;//默认第一次全屏播放
//    [self.pullController preparePlayerView];//重设view的大小
//    [self.pullController requestOtherVideo];
    
    [self addCancelButton];
    [self addGesture:self.pullController.view];
    self.isDefaultWindowPlayer = YES;//后面切换视频是小窗播放
}

#pragma mark - playerView
//单独增加一个cancel按钮, 因为播放页面的退出按钮会执行pop操作
- (void)addCancelButton
{
    if (!self.cancelButton.superview && self.isDefaultWindowPlayer) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setImage:[UIImage imageNamed:@"关闭.png"] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(removePlayerViewControler) forControlEvents:UIControlEventTouchUpInside];
        [self.pullController.view addSubview:self.cancelButton];
        self.cancelButton.frame = CGRectMake(0, 0, 40, 40);
    }
}

- (void)removePlayerViewControler
{
    self.isDefaultWindowPlayer = NO;
    
    if (self.pullController) {
        [self.pullController.view removeFromSuperview];
        [self.pullController removeFromParentViewController];
        self.pullController = nil;
    }
}

- (void)addGesture:(UIView *)view
{
    // 单击事件-隐藏显示控制器
    self.clickGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleClickEvent:)];
    self.clickGesture.numberOfTapsRequired = 1;
    self.clickGesture.delegate = self;
    [view addGestureRecognizer:self.clickGesture];
}

- (void)handleSingleClickEvent:(UITapGestureRecognizer *)gesture
{
    [self.pullController.view removeGestureRecognizer:self.clickGesture];
    self.clickGesture.delegate = nil;
    [self.cancelButton removeFromSuperview];
    self.cancelButton = nil;
    
    self.pullController.isWindowPlayer = NO;
    self.pullController.windowPlayerFrame = self.pullController.view.frame;//记录悬浮窗口的位置
    self.pullController.view.frame = self.view.frame;
    [self.pullController preparePlayerView];
}

//拖动事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if (touch.view != self.pullController.view && touch.view.superview != self.pullController.view) {
        return;
    }
    
    self.beginPoint = [touch locationInView:self.pullController.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    if (touch.view != self.pullController.view && touch.view.superview != self.pullController.view) {
        return;
    }
    
    CGPoint nowPoint = [touch locationInView:self.pullController.view];
    
    float offsetX = nowPoint.x - self.beginPoint.x;
    float offsetY = nowPoint.y - self.beginPoint.y;
    
    CGFloat centerX = self.pullController.view.center.x + offsetX;
    CGFloat centerY = self.pullController.view.center.y + offsetY;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    //限制拖动范围在屏幕内
    if (centerX < self.pullController.view.frame.size.width/2) {
        centerX = self.pullController.view.frame.size.width/2;
    } else if (centerX > screenWidth - self.pullController.view.frame.size.width/2) {
        centerX = screenWidth - self.pullController.view.frame.size.width/2;
    }
    
    if (centerY < self.pullController.view.frame.size.height/2) {
        centerY = self.pullController.view.frame.size.height/2;
    } else if (centerY > screenHeight - self.pullController.view.frame.size.height/2) {
        centerY = screenHeight - self.pullController.view.frame.size.height/2;
    }
    
    self.pullController.view.center = CGPointMake(centerX, centerY);
}

#pragma mark ---UICollectionViewDataSource---
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.playerType == PlayerType_Live){
        return self.liveList.count;
    }else if(self.playerType == PlayerType_VOD){
        return self.VODList.count;
    }else{
        NSLog(@"no this player type");
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *model = nil;
    if(self.playerType == PlayerType_Live){
        model = self.liveList[indexPath.item];
    }else if(self.playerType == PlayerType_VOD){
        model = self.VODList[indexPath.item];
    }
    
    FlowCell *cell = (FlowCell *) [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.lblRoomID.text = (NSString *)[model objectForKey:kRoomName];
    if(self.playerType == PlayerType_Live){
        cell.imgLiveState.image = (UIImage *)[UIImage imageNamed:@"live.png"];
    }else if(self.playerType == PlayerType_VOD){
        cell.imgLiveState.image = (UIImage *)[UIImage imageNamed:@"组-6.png"];
    }
    NSString *imgURL = (NSString *)[model objectForKey:kScreenShot];

    [self.helper downLoadWebImage:imgURL onQueueAsync:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(NSData *data) {
        if(data){
            cell.imgBackground.image = [UIImage imageWithData:data];
        }else{
            cell.imgBackground.image = [UIImage imageNamed:@"defalutFlow.png"];
        }
    }];
    return cell;
}

#pragma mark ---UICollectionViewDelegateFlowLayout---
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect rect = [UIScreen mainScreen].bounds;
    int width = rect.size.width / 2 - 10;
    
    return CGSizeMake(width, width);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
@end







