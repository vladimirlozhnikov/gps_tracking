//
//  DBAttachment+Methods.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBAttachment.h"

@interface DBAttachment (Methods)

+ (DBAttachment*) attachmentWithImage:(UIImage*)image;
+ (DBAttachment*) attachmentWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) attachmentToDictionary;

- (void) imageInBackground:(UIImageView*)imageView;

@end
