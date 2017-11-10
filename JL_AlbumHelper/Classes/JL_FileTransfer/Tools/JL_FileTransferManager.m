//
//  JL_FileTransferManager.m
//  JL_AlbumHelper
//
//  Created by JasonLee on 2017/11/10.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import "JL_FileTransferManager.h"
#import "JL_HTTPConnection.h"
#import "JL_DeviceInfoCenter.h"

@interface JL_FileTransferManager ()

@property (nonatomic, copy) NSString *tmpFileName;
@property (nonatomic, copy) NSString *tmpFilePath;

@property (nonatomic, copy) JL_FileTransferBeginBlock    beginBlock;
@property (nonatomic, copy) JL_FileTransferProgressBlock progressBlock;
@property (nonatomic, copy) JL_FileTransferFinishBlock   finishBlock;

@end

@implementation JL_FileTransferManager

- (void)dealloc {
    [self _configureStopHTTPServer];
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.webPath = [[NSBundle mainBundle] resourcePath];
        self.fileSavePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    }
    
    return self;
}

static JL_FileTransferManager *instance = nil;
+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (NSString *)deviceIPAddress {
    return [JL_DeviceInfoCenter deviceIPAddress];
}

- (UInt16)port {
    return self.httpServer.port;
}

#pragma mark - start server

- (BOOL)startHTTPServerAtPort:(UInt16)port {
    
    HTTPServer *server = [HTTPServer new];
    server.port = port;
    self.httpServer = server;
    
    [self.httpServer setDocumentRoot:self.webPath];
    [self.httpServer setConnectionClass:[JL_HTTPConnection class]];
    
    NSError *error = nil;
    [self.httpServer start:&error];
    
    if (error == nil) {
        [self _configureStartHTTPServer];
    }
    
    return error == nil;
}

- (BOOL)startHTTPServerAtPort:(UInt16)port
                        begin:(JL_FileTransferBeginBlock)begin
                     progress:(JL_FileTransferProgressBlock)progress
                       finish:(JL_FileTransferFinishBlock)finish
{
    self.beginBlock    = begin;
    self.progressBlock = progress;
    self.finishBlock   = finish;
    
    return [self startHTTPServerAtPort:port];
}

- (void)_configureStartHTTPServer {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileTransferBegin:) name:JL_FileTransferDidBeginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileTransferFinish:) name:JL_FileTransferDidEndNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileTransferProgress:) name:JL_FileTransferProgressNotification object:nil];
}

- (void)fileTransferBegin:(NSNotification *)notification {
    
    NSString *fileName = notification.object[@"fileName"];
    NSString *filePath = [self.fileSavePath stringByAppendingPathComponent:fileName];
    self.tmpFileName = fileName;
    self.tmpFilePath = filePath;
    
    if (self.beginBlock) {
        self.beginBlock(fileName, filePath);
    }
}

- (void)fileTransferFinish:(NSNotification *)notification {

    if (self.finishBlock) {
        self.finishBlock(self.tmpFileName, self.tmpFilePath);
    }
}

- (void)fileTransferProgress:(NSNotification *)notification {
    
    CGFloat progress = [notification.object[@"progress"] doubleValue];
    if (self.progressBlock) {
        self.progressBlock(self.tmpFileName, self.tmpFilePath, progress);
    }
}
#pragma mark - other

- (BOOL)isHTTPServerRunning {
    
    return self.httpServer.isRunning;
}

- (void)stopHTTPServer {
    
    if ([self isHTTPServerRunning]) {
        [self.httpServer stop];
    }
    [self _configureStopHTTPServer];
}

- (void)_configureStopHTTPServer {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.beginBlock = nil;
    self.progressBlock = nil;
    self.finishBlock = nil;
}

#pragma mark - Block Setter

- (void)setFileTransferBeginCallback:(JL_FileTransferBeginBlock)callback {
    self.beginBlock = callback;
}

- (void)setFileTransferProgressCallback:(JL_FileTransferProgressBlock)callback {
    self.progressBlock = callback;
}

- (void)setFileTransferFinishCallback:(JL_FileTransferFinishBlock)callback {
    self.finishBlock = callback;
}

@end
