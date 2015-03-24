//
//  IMBAppleMediaLibraryParserMessenger.m
//  iMedia
//
//  Created by Jörg Jacobsen on 24.02.15.
//
//

#import <MediaLibrary/MediaLibrary.h>

#import "NSObject+iMedia.h"
#import "NSWorkspace+iMedia.h"
#import "NSImage+iMedia.h"
#import "IMBAppleMediaLibraryParserMessenger.h"
#import "IMBAppleMediaLibraryParser.h"
#import "IMBAppleMediaLibraryParserConfiguration.h"

/**
 Reverse-engineered keys of the Photos app media source's attributes.
 
 Apple doesn't seem to yet publicly define these constants anywhere.
 */
NSString *kIMBMediaSourceAttributeIdentifier = @"mediaSourceIdentifier";

/**
 Attribute keys supported by iPhoto media source (as of OS X 10.10.3)
 */
NSString *kIMBMediaRootGroupAttributeLibraryURL = @"URL";

#pragma mark -

@interface IMBMLParserMessengerSubclassConfiguration : NSObject
{
    NSMutableArray *parsers;
    dispatch_once_t parsersCreationToken;
    NSString *mediaType;
    NSString *identifier;
}

@end

@implementation IMBMLParserMessengerSubclassConfiguration

@end

#pragma mark -

@implementation IMBAppleMediaLibraryParserMessenger

#pragma mark Configuration

/**
 initializes all subclass configurations.
 */
+ (void)load
{
    static NSMutableDictionary *subclassConfigurations;
    subclassConfigurations = [NSMutableDictionary dictionary];
}

/**
 Controls whether parser runs in-process or in XPC service if corresponding XPC service is present.
 
 The Apple Photos parser is not intended to run as an XPC service since it delegates all substantial work to the MLMediaLibrary service anyway. In fact it might not work in XPC service since retrieval of some of MLMediaLibrary properties is done asynchronously with KVO notifications into the main thread which might not work in XPC services.
 */
+ (BOOL) useXPCServiceWhenPresent
{
    return NO;
}

+ (NSString *)parserClassName
{
    return @"IMBAppleMediaLibraryParser";
}

#pragma mark - Object Lifecycle

/**
 
 */
- (id) initWithCoder:(NSCoder *)inDecoder
{
    NSKeyedUnarchiver* decoder = (NSKeyedUnarchiver*)inDecoder;
    
    if ((self = [super initWithCoder:decoder]))
    {
        // Add handling of class specific properties / ivars here
    }
    return self;
}

/**
 
 */
- (void) encodeWithCoder:(NSCoder *)inCoder
{
    [super encodeWithCoder:inCoder];
    
    // Add handling of class specific properties / ivars here
}

/**
 
 */
- (id) copyWithZone:(NSZone*)inZone
{
    id copy = [super copyWithZone:inZone];
    
    // Add handling of class specific properties / ivars here
    
    return copy;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    [self imb_throwAbstractBaseClassExceptionForSelector:_cmd];
    return 0;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    [self imb_throwAbstractBaseClassExceptionForSelector:_cmd];
    return nil;
}

- (NSArray *)parserInstancesWithError:(NSError **)outError
{
    Class myClass = [self class];
    dispatch_once([myClass parserInstancesOnceTokenRef], ^
                  {
                      IMBAppleMediaLibraryParser *parser = (IMBAppleMediaLibraryParser *)[self newParser];
                      MLMediaType mediaType = [IMBAppleMediaLibraryParser MLMediaTypeForIMBMediaType:[myClass mediaType]];
                      parser.configuration = [myClass parserConfigurationFactory](mediaType);
                      [[myClass parsers] addObject:parser];
                  });
    return [myClass parsers];
}


#pragma mark - Object Description

- (NSString *) metadataDescriptionForMetadata:(NSDictionary*)inMetadata
{
    return [NSImage imb_imageMetadataDescriptionForMetadata:inMetadata];
}

@end

#pragma mark - Subclasses For Media Type IMAGE

@implementation IMBMLPhotosImageParserMessenger

+ (void) load {
    @autoreleasepool {
        if (IMBRunningOnYosemite10103OrNewer()) {
            [IMBParserController registerParserMessengerClass:self forMediaType:[[self class] mediaType]];
        }
    }
}

+ (NSString*) mediaType {
    return kIMBMediaTypeImage;
}

+ (NSString*) identifier {
    return @"com.apple.medialibrary.Photos.image";
}

+ (NSMutableArray *)parsers
{
    static NSMutableArray *parsers = nil;
    if (!parsers) parsers = [[NSMutableArray alloc] init];
    return parsers;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    return IMBMLPhotosParserConfigurationFactory;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    static dispatch_once_t onceToken = 0;
    return &onceToken;
}

@end

@implementation IMBMLiPhotoImageParserMessenger

+ (void) load {
    @autoreleasepool {
        if (IMBRunningOnMavericksOrNewer()) {
            [IMBParserController registerParserMessengerClass:self forMediaType:[[self class] mediaType]];
        }
    }
}

+ (NSString*) mediaType {
    return kIMBMediaTypeImage;
}

+ (NSString*) identifier {
    return @"com.apple.medialibrary.iPhoto.image";
}

+ (NSMutableArray *)parsers
{
    static NSMutableArray *parsers = nil;
    if (!parsers) parsers = [[NSMutableArray alloc] init];
    return parsers;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    return IMBMLiPhotoParserConfigurationFactory;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    static dispatch_once_t onceToken = 0;
    return &onceToken;
}

@end

@implementation IMBMLApertureImageParserMessenger

+ (void) load {
    @autoreleasepool {
        if (IMBRunningOnMavericksOrNewer()) {
            [IMBParserController registerParserMessengerClass:self forMediaType:[[self class] mediaType]];
        }
    }
}

+ (NSString*) mediaType {
    return kIMBMediaTypeImage;
}

+ (NSString*) identifier {
    return @"com.apple.medialibrary.Aperture.image";
}

+ (NSMutableArray *)parsers
{
    static NSMutableArray *parsers = nil;
    if (!parsers) parsers = [[NSMutableArray alloc] init];
    return parsers;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    return IMBMLApertureParserConfigurationFactory;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    static dispatch_once_t onceToken = 0;
    return &onceToken;
}

@end

#pragma mark - Subclasses For Media Type MOVIE

@implementation IMBMLPhotosMovieParserMessenger

+ (void) load {
    @autoreleasepool {
        if (IMBRunningOnYosemite10103OrNewer()) {
            [IMBParserController registerParserMessengerClass:self forMediaType:[[self class] mediaType]];
        }
    }
}

+ (NSString*) mediaType {
    return kIMBMediaTypeMovie;
}

+ (NSString*) identifier {
    return @"com.apple.medialibrary.Photos.movie";
}

+ (NSMutableArray *)parsers
{
    static NSMutableArray *parsers = nil;
    if (!parsers) parsers = [[NSMutableArray alloc] init];
    return parsers;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    return IMBMLPhotosParserConfigurationFactory;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    static dispatch_once_t onceToken = 0;
    return &onceToken;
}

@end

@implementation IMBMLiPhotoMovieParserMessenger

+ (void) load {
    @autoreleasepool {
        if (IMBRunningOnMavericksOrNewer()) {
            [IMBParserController registerParserMessengerClass:self forMediaType:[[self class] mediaType]];
        }
    }
}

+ (NSString*) mediaType {
    return kIMBMediaTypeMovie;
}

+ (NSString*) identifier {
    return @"com.apple.medialibrary.iPhoto.movie";
}

+ (NSMutableArray *)parsers
{
    static NSMutableArray *parsers = nil;
    if (!parsers) parsers = [[NSMutableArray alloc] init];
    return parsers;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    return IMBMLiPhotoParserConfigurationFactory;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    static dispatch_once_t onceToken = 0;
    return &onceToken;
}

@end

@implementation IMBMLApertureMovieParserMessenger

+ (void) load {
    @autoreleasepool {
        if (IMBRunningOnMavericksOrNewer()) {
            [IMBParserController registerParserMessengerClass:self forMediaType:[[self class] mediaType]];
        }
    }
}

+ (NSString*) mediaType {
    return kIMBMediaTypeMovie;
}

+ (NSString*) identifier {
    return @"com.apple.medialibrary.Aperture.movie";
}

+ (NSMutableArray *)parsers
{
    static NSMutableArray *parsers = nil;
    if (!parsers) parsers = [[NSMutableArray alloc] init];
    return parsers;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    return IMBMLApertureParserConfigurationFactory;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    static dispatch_once_t onceToken = 0;
    return &onceToken;
}

@end

#pragma mark - Subclasses For Media Type AUDIO

@implementation IMBMLiTunesAudioParserMessenger

+ (void) load {
    @autoreleasepool {
        if (IMBRunningOnMavericksOrNewer()) {
            [IMBParserController registerParserMessengerClass:self forMediaType:[[self class] mediaType]];
        }
    }
}

+ (NSString*) mediaType {
    return kIMBMediaTypeAudio;
}

+ (NSString*) identifier {
    return @"com.apple.medialibrary.iTunes.audio";
}

+ (NSMutableArray *)parsers
{
    static NSMutableArray *parsers = nil;
    if (!parsers) parsers = [[NSMutableArray alloc] init];
    return parsers;
}

+ (IMBMLParserConfigurationFactory)parserConfigurationFactory
{
    return IMBMLiTunesParserConfigurationFactory;
}

+ (dispatch_once_t *)parserInstancesOnceTokenRef
{
    static dispatch_once_t onceToken = 0;
    return &onceToken;
}

@end




