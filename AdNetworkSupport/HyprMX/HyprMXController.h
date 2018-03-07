//
//  HyprMXController.h
//  HyprMX MoPubSDK Adapter

#import <HyprMX/HyprMX.h>
#import <Foundation/Foundation.h>

#import "MoPub.h"

@interface HyprMXController : NSObject

extern NSString * const kHyprMarketplaceAppConfigKeyDistributorId;

/**
 * This method returns the version of the HyprMX Mopub Adapters
 *
 * @return - An NSInteger version number of the adapter
 */
+ (NSInteger)adapterVersion;

/**
 * Initializes the HYPRManager if it has not been initializes previously
 * @param distributorID - distributor Id received from the MoPub dashboard
 * @param userID - user Id reported to the HYPRMarketplace.  If the userID is changed, the HYPRManager will re-initialize.
 */
+ (void)initializeSDKWithDistributorId:(NSString *)distributorID userID:(NSString *)userID;

/**
 * Returns the initialization state of HYPRManager
 */
+ (BOOL)hyprMXInitialized;

@end
