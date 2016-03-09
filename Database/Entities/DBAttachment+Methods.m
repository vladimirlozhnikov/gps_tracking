//
//  DBAttachment+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBAttachment+Methods.h"
#import "PPDbManager.h"
#import "Types.h"
#import "Base64.h"
#import "Model.h"
#import "PPDbManager.h"
#import "ImageUtils.h"

@implementation DBAttachment (Methods)

+ (DBAttachment*) attachmentWithDictionary:(NSDictionary*)dictionary
{
    DBAttachment* attachment = [PPDbManager objectForEntityName:@"DBAttachment"];
    
    NSString* dataString = [dictionary objectForKey:@"data"];
    attachment.imageUrl = dataString;
    NSInteger type = [[dictionary objectForKey:@"type"] intValue] + 1;
    attachment.type = [NSNumber numberWithInteger:type];
    
	return attachment;
}

+ (DBAttachment*) attachmentWithImage:(UIImage*)image
{
	DBAttachment* attachment = [PPDbManager objectForEntityName:@"DBAttachment"];
	attachment.image = UIImageJPEGRepresentation(image, 0);
	attachment.type = [NSNumber numberWithInteger:AttachmentTypeImage];
    
	return attachment;
}

- (NSDictionary*) attachmentToDictionary
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:@([self.type integerValue] - 1) forKey:@"type"];
    
	if(self.image)
    {
        [dictionary setObject:[Base64 encode:self.image] forKey:@"data"];
    }
	else
    {
        [dictionary setObject:@"" forKey:@"data"];
    }
	
	return dictionary;
}

-(BOOL)isEmpty
{
	return [self.type integerValue] == AttachmentTypeNone;
}

- (UIImage*) imageAvatar
{
	if (([self.type integerValue] == AttachmentTypeImage) && self.image)
    {
        return [UIImage imageWithData:self.image];
    }
	
	return nil;
}

- (void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeObject:[self attachmentToDictionary]];
}

#pragma mark - Properties

- (void) imageLoadDidFinish:(UIImageView*)imageView
{
    UIImage* image = [UIImage imageWithData:self.image];
    if (image.size.width > 1000 || image.size.height > 1000)
    {
        CGSize newSize;
        CGSize sz = image.size;
        float scale;
        if (sz.width > sz.height)
        {
            scale = 1000 / sz.width;
        }
        else
        {
            scale = 1000 / sz.height;
        }
        
        newSize = CGSizeMake(sz.width * scale, sz.height * scale);
        
        imageView.image = [ImageUtils imageWithImage:image scaledToSize:newSize];
    }
    else
    {
        imageView.image = image;
    }
    imageView.hidden = NO;
    
    [Model sharedInstance].totalDownloadBytes = [self.image length];
    
    [activity stopAnimating];
}

- (void) loadImage:(UIImageView*)imageView
{
    self.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
    
    [self performSelectorOnMainThread:@selector(imageLoadDidFinish:) withObject:imageView waitUntilDone:YES];
}

- (void) imageInBackground:(UIImageView*)imageView
{
    if (self.image)
    {
        UIImage* image = [UIImage imageWithData:self.image];
        if (image.size.width > 1000 || image.size.height > 1000)
        {
            CGSize newSize;
            CGSize sz = image.size;
            float scale;
            if (sz.width > sz.height)
            {
                scale = 1000 / sz.width;
            }
            else
            {
                scale = 1000 / sz.height;
            }
            
            newSize = CGSizeMake(sz.width * scale, sz.height * scale);
            
            imageView.image = [ImageUtils imageWithImage:image scaledToSize:newSize];
        }
        else
        {
            imageView.image = image;
        }
        imageView.hidden = NO;
    }
    else if ([self.imageUrl length] > 0)
    {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.frame = CGRectMake(imageView.frame.size.width / 2 - 20.0, imageView.frame.size.height / 2 - 20.0, 40.0, 40.0);
        [imageView addSubview:activity];
        [activity startAnimating];

        [self performSelectorInBackground:@selector(loadImage:) withObject:imageView];
    }
}

@end
