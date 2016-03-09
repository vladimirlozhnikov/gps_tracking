//
//  FileUtils.h
//  
//
//  Created by yurysh on 15.10.09.
//  Copyright 2009 JVL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileUtils : NSObject 
{

}

+(NSString*)documentsDirectory;
+(NSString*)documentPath:(NSString*)file;
+(NSString*)resourcesDirectory;
+(NSString*)resourcePath:(NSString*)file;
+(BOOL)fileExistsAtPath:(NSString*)path;
+(BOOL)removeFileAtPath:(NSString*)path;

@end
