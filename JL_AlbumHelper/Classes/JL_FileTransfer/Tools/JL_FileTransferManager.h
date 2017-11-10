//
//  JL_FileTransferManager.h
//  JL_AlbumHelper
//
//  Created by JasonLee on 2017/11/10.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"

static NSString * const JL_FileTransferDidBeginNotification = @"JL_FileTransferDidBeginNotification";
static NSString * const JL_FileTransferProgressNotification = @"JL_FileTransferProgressNotification";
static NSString * const JL_FileTransferDidEndNotification   = @"JL_FileTransferDidEndNotification";

static NSString * const JL_FileTransferNotificationFileNameKey = @"JL_FileTransferNotificationFileNameKey";
static NSString * const JL_FileTransferNotificationProgressKey = @"JL_FileTransferNotificationProgressKey";

typedef void (^JL_FileTransferBeginBlock)(NSString *fileName, NSString *savePath);
typedef void (^JL_FileTransferProgressBlock)(NSString *fileName, NSString *savePath, CGFloat progress);
typedef void (^JL_FileTransferFinishBlock)(NSString *fileName, NSString *savePath);

@interface JL_FileTransferManager : NSObject

@property (nonatomic, strong) HTTPServer *httpServer;
@property (nonatomic, copy) NSString *fileSavePath;
@property (nonatomic, copy) NSString *webPath;

+ (instancetype)sharedManager;

- (BOOL)startHTTPServerAtPort:(UInt16)port;
- (BOOL)startHTTPServerAtPort:(UInt16)port
                        begin:(JL_FileTransferBeginBlock)begin
                     progress:(JL_FileTransferProgressBlock)progress
                       finish:(JL_FileTransferFinishBlock)finish;

- (BOOL)isHTTPServerRunning;
- (void)stopHTTPServer;

- (NSString *)deviceIPAddress;
- (UInt16)port;

- (void)setFileTransferBeginCallback:(JL_FileTransferBeginBlock)callback;
- (void)setFileTransferProgressCallback:(JL_FileTransferProgressBlock)callback;
- (void)setFileTransferFinishCallback:(JL_FileTransferFinishBlock)callback;

@end





