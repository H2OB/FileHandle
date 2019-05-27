//
//  ViewController.m
//  FileDownLoad
//
//  Created by North on 2019/5/24.
//  Copyright © 2019 North. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>

#define CompletionData @"completionData" //最终数据
#define ResumeData @"resumeData" //临时数据

typedef void(^TaskCompletionBlock)(void);

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidCompleteNotification:) name:AFNetworkingTaskDidCompleteNotification object:nil];
    
    
    
}
- (IBAction)startBtnAction:(id)sender {
    
    
    progressView.progress = 0;
    
    //远程地址
    NSURL *URL = [NSURL URLWithString:@"http://tb-video.bdstatic.com/videocp/16514218_b3883a9f1e041a181bda58804e0a5192.mp4"];
    //默认配置
  
    configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:URL.lastPathComponent];
    configuration.HTTPMaximumConnectionsPerHost = 10;

    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    manager.operationQueue = dispatch_queue_create(@"com.newhope.one", 0);
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:ResumeData];
    filePath = [filePath stringByAppendingPathComponent:request.URL.lastPathComponent];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
   
    
    if(data.length > 0){
        
        
        _downloadTask = [manager downloadTaskWithResumeData:data progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 设置进度条的百分比
                self->progressView.progress = (1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                NSLog(@"%.2f",self->progressView.progress);
            });
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [documentPath stringByAppendingPathComponent:CompletionData];
            filePath = [filePath stringByAppendingPathComponent:URL.lastPathComponent];
            
            return [NSURL fileURLWithPath:filePath];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
                
                [manager.session finishTasksAndInvalidate];
                //            [manager.session invalidateAndCancel];
                NSLog(@"%@",filePath.path);
                
                [[NSFileManager defaultManager] removeItemAtPath:[filePath.path stringByReplacingOccurrencesOfString:CompletionData withString:ResumeData] error:nil];
                
                
                
                
            }else{
                
                
            }
        }];
        
       
        
    }else{
        
        
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
            NSString *filePath = [documentPath stringByAppendingPathComponent:CompletionData];
            filePath = [filePath stringByAppendingPathComponent:URL.lastPathComponent];
            
            return [NSURL fileURLWithPath:filePath];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            
            
            
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
                
                [manager.session invalidateAndCancel];
//                NSLog(@"%@",filePath.path);

                [[NSFileManager defaultManager] removeItemAtPath:[filePath.path stringByReplacingOccurrencesOfString:CompletionData withString:ResumeData] error:nil];

            }else{
                
                
            }
            
        }];
    }

    
    [_downloadTask resume];
}

- (void)taskDidCompleteNotification:(NSNotification *)notification{
    
    if ([notification.object isKindOfClass:[ NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask *task = notification.object;
       
        NSError *error  = [notification.userInfo objectForKey:AFNetworkingTaskDidCompleteErrorKey] ;
        if (error) {
            
            NSData *resumeData = [error.userInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
            //这个是因为 用户比如强退程序之后 ,再次进来的时候 存进去这个继续的data  需要用户去刷新列表
            
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *directryPath = [documentPath stringByAppendingPathComponent:ResumeData];
           NSString * filePath = [directryPath stringByAppendingPathComponent:task.currentRequest.URL.lastPathComponent];
             NSError *writeError = nil;
            
            if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                
                BOOL creat =   [[NSFileManager defaultManager] createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
                if(creat){
                    
                }
                
            }
            
            BOOL sucess =   [resumeData writeToFile:filePath options:0 error:&writeError];
            if(sucess){
                
                
            }
 
            
        }else{
            
        
            
            
        }
    }
    
    
}

@end
