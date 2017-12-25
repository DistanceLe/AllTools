//
//  ViewController.m
//  LJTools-Demo
//
//  Created by LiJie on 2017/5/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+LJRefresh.h"
#import "LJImageTools.h"

#import "LJRegisterRequest.h"
#import "LJNetworkManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIImage* originImage = [UIImage imageNamed:@"man2"];
    
    UIImage* changeImage = [LJImageTools changeImageRatioCompress:originImage ratioCompressSize:CGSizeMake(240, 150)];
    self.contentImageView.image = changeImage;
    self.contentImageView.layer.masksToBounds = YES;

    @weakify(self);
    [self.contentScrollView addSystemHeadRefresh:@"😁😎😆hello" handler:^{
       @strongify(self);
        DLog(@" 开始刷新啦`````");
        
//        [self registerRequset];
//        [self uploadFile];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.35*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.contentScrollView endSystemHeadRefresh];
        });
    }];
    
    
    //创建异步加载：
    dispatch_queue_t anyncQueue = dispatch_queue_create("anyncQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(anyncQueue, ^{
        
        const char*  dispatchLabel = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        NSLog(@"%s", dispatchLabel);//anyncQueue
        dispatch_sync(dispatch_get_main_queue(), ^{
            const char*  dispatchLabel = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
            NSLog(@"%s", dispatchLabel);//com.apple.main-thread
        });
    });
    
    PLog(@"print log");
    DLog(@"NSLog");
    
    
}

-(void)registerRequset{
    LJRegisterRequest* request = [[LJRegisterRequest alloc]init];
    request.phone = @"12345678910";
    request.password = @"123456哈哈哈能开到吗";
    request.smsCode = @"1234";
    [request requestGetWithHandler:^(id returnValue, NSString *message, NSError *error) {
        DLog(@"...%@, %@, %@", returnValue, message, error);
        
    }];
}

-(void)uploadFile{
    
//    NSString* filePath = [[NSBundle mainBundle]pathForResource:@"K6" ofType:@"bin"];
//
//    [LJNetworkManager uploadFileWithURL:@"http://192.168.31.96:8080/WebDemo/Upload/UploadServlet" parameters:nil name:@"K6" fileType:@"bin" filePath:filePath progress:^(NSProgress *progress) {
//        DLog(@"...progress:  %.2f", progress.completedUnitCount*1.0/progress.totalUnitCount);
//    } success:^(id responseObject) {
//        DLog(@"...成功上传 ✌️ %@", responseObject);
//    } failure:^(NSError *error) {
//        DLog(@"上传失败。。。%@", error);
//    }];
    
//    [LJNetworkManager uploadImagesWithURL:@"http://192.168.31.96:8080/WebDemo/Upload/UploadServlet" parameters:nil name:@"endImage" images:@[[UIImage imageNamed:@"end.png"]] fileNames:@[@"endFileName"] imageScale:1.0 imageType:@"png" progress:^(NSProgress *progress) {
//        DLog(@"...progress:  %.2f", progress.completedUnitCount/progress.totalUnitCount/1.0);
//    } success:^(id responseObject) {
//        DLog(@"...成功上传 ✌️ %@", responseObject);
//    } failure:^(NSError *error) {
//        DLog(@"上传失败。。。%@", error);
//    }];
    
}

-(void)notificationTest{
    [[NSNotificationCenter defaultCenter]addObserverName:@"name" object:@"1" handler:^(id sender, id status) {
        DLog(@"111...%@", sender);
    }];
    [[NSNotificationCenter defaultCenter]addObserverName:@"name" object:@"2" handler:^(id sender, id status) {
        DLog(@"222...%@", sender);
    }];
    [[NSNotificationCenter defaultCenter]addObserverName:@"name" object:nil handler:^(id sender, id status) {
        DLog(@"333...%@", sender);
    }];
    
    [[NSNotificationCenter defaultCenter]addObserverName:@"name2" object:nil handler:^(id sender, id status) {
        DLog(@"444```````...%@", sender);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.35*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"name" object:nil];
    });
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.35*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"name2" object:nil];
    });
}


@end
