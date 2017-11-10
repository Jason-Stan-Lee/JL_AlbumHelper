//
//  JL_HTTPConnection.m
//  JL_AlbumHelper
//
//  Created by JasonLee on 2017/11/10.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import "JL_HTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#import "JL_FileTransferManager.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;

@interface JL_HTTPConnection ()
{
    UInt64 _contentLength;
    UInt64 _currentLength;
}

@end

/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation JL_HTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    // Add support for POST
    if ([method isEqualToString:@"POST"]) {
        
        if ([path isEqualToString:@"/upload.html"]){
            
            return YES;
        }
    }
    
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    // Inform HTTP server that we expect a body to accompany a POST request
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
        // enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"]) {
        
        // this method will generate response with links to uploaded file
        NSMutableString* filesStr = [[NSMutableString alloc] init];
        
        for( NSString* filePath in _uploadedFiles ) {
            //generate links
            [filesStr appendFormat:@"<a href=\"%@\"> %@ </a><br/>",filePath, [filePath lastPathComponent]];
        }
        NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"upload.html"];
        NSDictionary* replacementDict = [NSDictionary dictionaryWithObject:filesStr forKey:@"MyFiles"];
        // use dynamic file response to apply our links to response template
        return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
    }
    if( [method isEqualToString:@"GET"] && [path hasPrefix:@"/upload/"] ) {
        // let download the uploaded files
        return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
    }
    
    return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {
    
    // set up mime _parser
    NSString* boundary = [request headerField:@"boundary"];
    _parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    _parser.delegate = self;
    
    _uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk {
    
    // append data to the _parser. It will invoke callbacks to let us handle
    // parsed data.
    [_parser appendData:postDataChunk];
}

//-----------------------------------------------------------------
#pragma mark multipart form data _parser delegate


- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
        // an empty form sent. we won't handle it.
        return;
    }
    
    // post file transfer begin
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JL_FileTransferDidBeginNotification object:@{JL_FileTransferNotificationFileNameKey : filename ?: @"File"}];
    });
    
    // setup upload directory path
    NSString *uploadDirPath = [JL_FileTransferManager sharedManager].fileSavePath;
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        _storeFile = nil;
    }
    else {
        HTTPLogVerbose(@"Saving file to %@", filePath);
        if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
            HTTPLogError(@"Could not create directory at path: %@", filePath);
        }
        if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
            HTTPLogError(@"Could not create file at path: %@", filePath);
        }
        _storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [_uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
    }
}

- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header {
    // here we just write the output from _parser to the file.
    
    // 由于除传输文件内容外，还有HTML内容和空文件通过此方法处理，因此需要过滤掉HTML和空文件内容
    if (!header.fields[@"Content-Disposition"]) {
        return;
    } else {
        MultipartMessageHeaderField *field = header.fields[@"Content-Disposition"];
        NSString *fileName = field.params[@"filename"];
        if (fileName.length == 0) return;
    }
    
    _currentLength += data.length;
    CGFloat progress;
    if (_contentLength == 0) {
        progress = 1.0f;
    } else {
        progress = (CGFloat)_currentLength / _contentLength;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:JL_FileTransferProgressNotification object:@{JL_FileTransferNotificationProgressKey : @(progress)}];
    });
    
    if( _storeFile ) {
        [_storeFile writeData:data];
    }
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header {
    // as the file part is over, we close the file.
    
    // 由于除传输文件内容外，还有HTML内容和空文件通过此方法处理，因此需要过滤掉HTML和空文件内容
    if (!header.fields[@"Content-Disposition"]) {
        return;
    } else {
        
        MultipartMessageHeaderField *field = header.fields[@"Content-Disposition"];
        NSString *fileName = field.params[@"filename"];
        if (fileName.length == 0) return;
    }
    
    [_storeFile closeFile];
    _storeFile = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:JL_FileTransferDidEndNotification object:nil];
    });
}

- (void) processPreambleData:(NSData*) data {
    // if we are interested in preamble data, we could process it here.
    
}

- (void) processEpilogueData:(NSData*) data {
    // if we are interested in epilogue data, we could process it here.
    
}

@end
