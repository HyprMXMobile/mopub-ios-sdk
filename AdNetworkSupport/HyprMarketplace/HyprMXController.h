//
//  HyprMXController.h
//  HyprMX MoPubSDK Adapter

#import <HyprMX/HyprMX.h>
#import <Foundation/Foundation.h>

#import "MoPub.h"

@interface HyprMXController : NSObject

/**
 * This method returns the version of the HyprMXRewardedVideo Adapter
 *
 * @return - An NSInteger version number of the adapter
 */
+ (NSInteger)adapterVersion;

+ (void)initializeSDKWithDistributorId:(NSString *)distributorID;

+ (void)checkForAd:(void (^)(BOOL))callback;

+ (BOOL)hyprMXInitialized;

@end
