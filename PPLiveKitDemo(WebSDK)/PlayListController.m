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



static NSString * reuseIdentifier = @"flowcell";

@interface PlayListController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PlayerListHelperDelegate>
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
}

-(void)viewWillAppear:(BOOL)animated{
    [self.flowView triggerPullToRefresh];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.playerType = PlayerType_Live;
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
        [self dismissViewControllerAnimated:NO completion:nil];
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
    
    self.navItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"形状-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack)];
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
    if(self.playerType == PlayerType_Live){
        NSDictionary *model = (NSDictionary *)self.liveList[indexPath.item];
        [self.helper startPlayWithType:PlayerType_Live withNeededInfo:model];
    }else if(self.playerType == PlayerType_VOD){
        NSDictionary *model = (NSDictionary *)self.VODList[indexPath.item];
        NSString *VODURL = [self.helper fetchVodURLWithChannelWebID: [model objectForKey:kChannelWebID]];
        
        [[PPYPlayEngine shareInstance] startPlayFromURL:VODURL WithType:PPYSourceType_VOD];
        UIView *displayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [[PPYPlayEngine shareInstance] presentPreviewOnView:displayView];
        [self.view addSubview:displayView];

    }else{
        
    }
    
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







