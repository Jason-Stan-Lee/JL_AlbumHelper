//
//  JL_HTTPConnection.h
//  JL_AlbumHelper
//
//  Created by JasonLee on 2017/11/10.
//  Copyright © 2017年 JasonLee. All rights reserved.
//

#import "HTTPConnection.h"

@class MultipartFormDataParser;
@interface JL_HTTPConnection : HTTPConnection
{
    MultipartFormDataParser *_parser;
    NSMutableArray *_uploadedFiles;
    NSFileHandle *_storeFile;
}

@end
