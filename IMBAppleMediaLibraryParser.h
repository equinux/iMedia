//
//  IMBAppleMediaLibraryParser.h
//  iMedia
//
//  Created by Jörg Jacobsen on 24.02.15.
//
//

#import <MediaLibrary/MediaLibrary.h>
#import <iMedia/iMedia.h>

#import "IMBParser.h"

/**
 Base class for parser classes that access their libraries through Apple's MediaLibrary framework.
 */
@interface IMBAppleMediaLibraryParser : IMBParser
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

/**
 Returns whether the node given should be shown in the node hierarchy.
 
 @discussion
 This implementation always returns YES. You are welcome to override in your subclass parser.
 */

- (BOOL)shouldUseMediaGroup:(MLMediaGroup *)mediaGroup;

/**
 Returns whether the group given should use the same media objects as its parent.
 
 @discussion
 This implementation always returns NO. You are welcome to override in your subclass parser (will boost performance).
 */
- (BOOL)shouldReuseMediaObjectsOfParentGroupForGroup:(MLMediaGroup *)mediaGroup;

@end
