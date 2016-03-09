//
//  Protocol.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 19.03.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchGroupCell;
@class SearchGroupHeader;

@protocol TrafficProtocol <NSObject>
- (void) trafficChanged:(NSString*)friendlyDownload friendlyUpload:(NSString*)friendlyUpload;

@end

@protocol AddressBookProtocol <NSObject>
- (void) didGetContacts:(NSArray*)contacts;

@end

@protocol StatisticsProtocol <NSObject>
- (void) didDateChoose:(NSDate*)from to:(NSDate*)to;
- (void) backClicked;

@end

@protocol SearchGroupCellDelegate <NSObject>
-(void) searchGroupCellOnName:(SearchGroupHeader*)cell;
-(void) searchGroupCellOnOwner:(SearchGroupCell*)cell;
-(void) searchGroupCellOnUsers:(SearchGroupCell*)cell;
-(void) searchGroupCellOnLogin:(SearchGroupCell*)cell;

@end

@class UserMapMenuVC;
@protocol UserMapMenuVCDelegate <NSObject>
-(void) userMapMenuVCOnDetailsMessage:(UserMapMenuVC*)object;
- (void) statisticsDidChoose;

@end

@class GMSMarker;
@protocol MarkerMenuVCDelegate <NSObject>
- (void) didAddressClick:(GMSMarker*)marker;
- (void) didShareClick:(GMSMarker*)marker;
- (void) didRemoveClick:(GMSMarker*)marker;

@end

@protocol BackgroundActionsDelegate <NSObject>
@optional
- (void) didImageLoad:(id)sender image:(UIImage*)image;

@end

@protocol ReadMessageListVCDelegate <NSObject>
- (void) didReadSharedMarker:(NSDictionary*)parameters;

@end