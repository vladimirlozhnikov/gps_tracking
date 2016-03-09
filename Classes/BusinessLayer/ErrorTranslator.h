//
//  ErrorTranslator.h
//  GPSTracker
//
//  Created by YS on 2/27/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorTranslator : NSObject
{
	NSDictionary* _errors;
}

- (NSString*) descriptionForError:(NSUInteger)error;

@end
