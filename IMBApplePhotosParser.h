//
//  IMBApplePhotosParser.h
//  iMedia
//
//  Created by Jörg Jacobsen on 10.02.15.
//
//

#import <MediaLibrary/MediaLibrary.h>
#import <iMedia/iMedia.h>
#import "IMBParser.h"

/**
 Base class for parser classes that support different Apple Photos app media types.
 */
@interface IMBApplePhotosParser : IMBParser
{
    NSString *_appPath;
    MLMediaLibrary *_AppleMediaLibrary;
    MLMediaSource *_AppleMediaSource;
}

/**
 Path to library's original app.
 */
@property (strong) NSString *appPath;

/**
 The root library object (providing possibly multiple media sources from different apps).
 */
@property (strong) MLMediaLibrary *AppleMediaLibrary;

/**
 An MLMediaSource (an app's library) in Apple speak is not a mediaSource (a library's URL) in iMedia speak.
 */
@property (strong) MLMediaSource *AppleMediaSource;

@end

@interface IMBApplePhotosImageParser : IMBApplePhotosParser

@end

@interface IMBApplePhotosMovieParser : IMBApplePhotosParser

@end

