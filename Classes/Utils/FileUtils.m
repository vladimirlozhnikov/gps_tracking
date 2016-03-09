//
//  FileUtils.m
//  
//
//  Created by yurysh on 15.10.09.
//  Copyright 2009 JVL. All rights reserved.
//

#import "FileUtils.h"

@implementation FileUtils

+(NSString*)documentsDirectory
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* dir = [NSString stringWithString:[paths objectAtIndex:0]];
	return dir;	
}

+(NSString*)documentPath:(NSString*)file
{
	assert(file);
	return [NSString stringWithFormat:@"%@/%@", [FileUtils  documentsDirectory], file];
}

+(NSString*)resourcesDirectory
{
	return [[NSBundle mainBundle] bundlePath];
}

+(NSString*)resourcePath:(NSString*)file
{
	assert(file);
	return [NSString stringWithFormat:@"%@/%@", [FileUtils  resourcesDirectory], file];
}

+(BOOL)fileExistsAtPath:(NSString*)path
{
	assert(nil != path);	
	if( [path hasPrefix:@"~"] )
		path = [path stringByExpandingTildeInPath];
	
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+(BOOL)removeFileAtPath:(NSString*)path
{
	assert(nil != path);	
	if( [path hasPrefix:@"~"] )
		path = [path stringByExpandingTildeInPath];

	return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

@end
