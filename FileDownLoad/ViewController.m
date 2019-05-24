//
//  ViewController.m
//  FileDownLoad
//
//  Created by North on 2019/5/24.
//  Copyright © 2019 North. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
@interface ViewController ()
{
    
    NSURLSessionDownloadTask *_downloadTask;
    __weak IBOutlet UIProgressView *progressView;
    NSURLSessionConfiguration *configuration;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}
- (IBAction)startBtnAction:(id)sender {
    
    
    progressView.progress = 0;
    
    //远程地址
    NSURL *URL = [NSURL URLWithString:@"http://tb-video.bdstatic.com/videocp/16514218_b3883a9f1e041a181bda58804e0a5192.mp4"];
    //默认配置
  
    if(!configuration){
        
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.newhope.one"];
        configuration.HTTPMaximumConnectionsPerHost = 10;
    }
    
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    manager.operationQueue = dispatch_queue_create(@"com.newhope.one", 0);
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //下载Task操作
    _downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // @property int64_t totalUnitCount;     需要下载文件的总大小
        // @property int64_t completedUnitCount; 当前已经下载的大小
        
        // 回到主队列刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // 设置进度条的百分比
            self->progressView.progress = (1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
            
            NSLog(@"%.2f",self->progressView.progress);
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *filePath = [documentPath stringByAppendingPathComponent:URL.lastPathComponent];
        
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        
        
        
        
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
            
            NSLog(@"%@",filePath.path);
            
        }else{
            
            
        }
        
    }];
    
    [_downloadTask resume];
}


@end
