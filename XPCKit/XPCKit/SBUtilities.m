//
//  SBUtilities.m
//  XPCKit
//
//  Created by Jörg Jacobsen on 16/2/12. Copyright 2012 SandboxingKit.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

// Author: Peter Baumgartner


//----------------------------------------------------------------------------------------------------------------------


#import "SBUtilities.h"
#import <Security/SecCode.h>
#import <Security/SecRequirement.h>
#import <sys/types.h>
#import <pwd.h>


//----------------------------------------------------------------------------------------------------------------------


// Check if the host app is sandboxed. This code is based on suggestions from the FrameworksIT mailing list...

BOOL IMBIsSandboxed()
{
	static BOOL sIsSandboxed = NO;
	static dispatch_once_t sIsSandboxedToken = 0;

    dispatch_once(&sIsSandboxedToken,
    ^{
		SecCodeRef codeRef = NULL;
		SecCodeCopySelf(kSecCSDefaultFlags,&codeRef);

		if (codeRef != NULL)
		{
			SecRequirementRef reqRef = NULL;
			SecRequirementCreateWithString(CFSTR("entitlement[\"com.apple.security.app-sandbox\"] exists"),kSecCSDefaultFlags,&reqRef);

			if (reqRef != NULL)
			{
				OSStatus status = SecCodeCheckValidity(codeRef,kSecCSDefaultFlags,reqRef);
				
				if (status == noErr)
				{
					sIsSandboxed = YES;
				};
			}
		}
    });
	
	return sIsSandboxed;
}


//----------------------------------------------------------------------------------------------------------------------


#pragma mark


// Replacement function for NSHomeDirectory...

NSString* IMBHomeDirectory()
{
	struct passwd* passInfo = getpwuid(getuid());
	char* homeDir = passInfo->pw_dir;
	return [NSString stringWithUTF8String:homeDir];
}


// Convenience function for getting a path to an application container directory...

NSString* IMBApplicationContainerHomeDirectory(NSString* inBundleIdentifier)
{
    NSString* bundleIdentifier = inBundleIdentifier;
    
    if (bundleIdentifier == nil) 
    {
        bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    }
    
    NSString* appContainerDir = IMBHomeDirectory();
    appContainerDir = [appContainerDir stringByAppendingPathComponent:@"Library"];
    appContainerDir = [appContainerDir stringByAppendingPathComponent:@"Containers"];
    appContainerDir = [appContainerDir stringByAppendingPathComponent:bundleIdentifier];
    appContainerDir = [appContainerDir stringByAppendingPathComponent:@"Data"];
    
    return appContainerDir;
}


//----------------------------------------------------------------------------------------------------------------------


#pragma mark


// Private function to read contents of a prefs file at given path into a dinctionary...

static NSDictionary* _IMBPreferencesDictionary(NSString* inHomeFolderPath,NSString* inPrefsFileName)
{
    NSString* path = [inHomeFolderPath stringByAppendingPathComponent:@"Library"];
    path = [path stringByAppendingPathComponent:@"Preferences"];
    path = [path stringByAppendingPathComponent:inPrefsFileName];
    path = [path stringByAppendingPathExtension:@"plist"];
    
   return [NSDictionary dictionaryWithContentsOfFile:path];
}


// Private function to access a certain value in the prefs dictionary...

static CFTypeRef _IMBGetValue(NSDictionary* inPrefsFileContents,CFStringRef inKey)
{
    CFTypeRef value = NULL;

    if (inPrefsFileContents) 
    {
        id tmp = [inPrefsFileContents objectForKey:(NSString*)inKey];
    
        if (tmp)
        {
            value = (CFTypeRef) tmp;
            CFRetain(value);
        }
    }
    
    return value;
}


// High level function that should be used instead of CFPreferencesCopyAppValue, because in  
// sandboxed apps we need to work around problems of CFPreferencesCopyAppValue returning NULL...

CFTypeRef IMBPreferencesCopyAppValue(CFStringRef inKey,CFStringRef inBundleIdentifier)
{
    CFTypeRef value = NULL;
    NSString* path;
    
    // First try the official API. If we get a value, then use it...
    
    if (value == nil)
    {
        value = CFPreferencesCopyAppValue((CFStringRef)inKey,(CFStringRef)inBundleIdentifier);
    }
    
    // In sandboxed apps that may have failed tough, so try a workaround. If the app has the entitlement
    // com.apple.security.temporary-exception.files.absolute-path.read-only for a wide enough part of the
    // file system, we can read the prefs file ourself and parse it manually...
    
    if (value == nil)
    {
        path = IMBHomeDirectory();
        NSDictionary* prefsFileContents = _IMBPreferencesDictionary(path,(NSString*)inBundleIdentifier);
        value = _IMBGetValue(prefsFileContents,inKey);
    }

    // It's possible that the other app is sandboxed as well, so we may need look for the prefs file 
    // in its container directory...
    
    if (value == nil)
    {
        path = IMBApplicationContainerHomeDirectory((NSString*)inBundleIdentifier);
        NSDictionary* prefsFileContents = _IMBPreferencesDictionary(path,(NSString*)inBundleIdentifier);
        value = _IMBGetValue(prefsFileContents,inKey);
    }
    
    return value;
}


//----------------------------------------------------------------------------------------------------------------------
