//
//  HyprMXController.h
//  HyprMX MoPubSDK Adapter

#import <HyprMX/HyprMX.h>
#import <Foundation/Foundation.h>

#import "MoPub.h"

@interface HyprMXController : NSObject

extern NSString * const kHyprMarketplaceAppConfigKeyDistributorId;

/**
 * This method returns the version of the HyprMXRewardedVideo Adapter
 *
 * @return - An NSInteger version number of the adapter
 */
+ (NSInteger)adapterVersion;

+ (void)initializeSDKWithDistributorId:(NSString *)distributorID;

+ (BOOL)checkForAd;

+ (void)canShowAd:(void (^)(BOOL))callback;

+ (void)displayOfferRewarded:(BOOL)rewarded callback:(void (^)(BOOL completed, MPRewardedVideoReward *reward))callback;

+ (BOOL)hyprMXInitialized;

@end
