//
//  HyprMXController.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXController.h"

/**
 * Required Properties for configuration of adapter.
 * NOTE: Please configure your MoPub dashboard with an appropriate distributorID.
 */
NSString * const kHyprMarketplaceAppConfigKeyDistributorId = @"distributorID";


NSString * const kHyprMarketplaceAppConfigKeyUserId = @"hyprMarketplaceAppConfigKeyUserId";

NSString * const hyprPropertyID = @"iOSMopubAdapter";

NSInteger const kHyprMarketplace_HyprAdapter_Version = 2;


/*****
 * Shared State. Adapter is reinitialized for each ad request, but we don't want to re-init HyprMX.
 * We store our shared state in these variables.
 *****/

/** A BOOL that is set to YES when HyprMX has been initialized */
static BOOL hyprSdkInitialized = NO;

/** A BOOL that is set to YES when HyprMX has been initialized */
static BOOL hyprOfferReady = NO;

/** An NSString that stores a copy of the distributor ID */
static NSString *hyprDistributorID;

/** An NSString that stores a copy of the User ID */
static NSString *hyprUserID;

@interface HyprMXController () <MPMediationSettingsProtocol>
@end

@implementation HyprMXController

#pragma mark - Public Methods -

+ (NSInteger)adapterVersion {
    return kHyprMarketplace_HyprAdapter_Version;
}

+ (NSString *)hyprMXSdkVersion {
    
    return [[HYPRManager sharedManager] versionString];
}

+ (BOOL)hyprMXInitialized {
    return hyprSdkInitialized;
}

#pragma mark - Initialization and Inventory Checking Methods -

+ (void)initializeSDKWithDistributorId:(NSString *)distributorID userID:(NSString *)userID {
    
    [HyprMXController manageUserIdWithUserID:userID];
    
    if (hyprSdkInitialized && ![hyprDistributorID isEqualToString:distributorID]) {
        NSLog(@"WARNING: HYPRManager already initialized with another distributor ID");
    }
    
    if (!hyprSdkInitialized ||
        ![[HYPRManager sharedManager].userId isEqualToString:hyprUserID]) {
        
        if (nil == hyprDistributorID) {
            hyprDistributorID = distributorID;
        }
        
        // TODO: enable debug logging only when needed?
        [HYPRManager enableDebugLogging];
        
        [HYPRManager disableAutomaticPreloading];
        
        [[HYPRManager sharedManager] initializeWithDistributorId:hyprDistributorID
                                                      propertyId:hyprPropertyID
                                                          userId:hyprUserID];
        hyprSdkInitialized = YES;
    }
}

+ (BOOL)hasAdAvailable {
    return hyprOfferReady;
}

+ (void)canShowAd:(void (^)(BOOL))callback {
    [[HYPRManager sharedManager] canShowAd:^(BOOL isOfferReady){
        hyprOfferReady = isOfferReady;
        callback(isOfferReady);
    }];
}

+ (void)displayOfferRewarded:(BOOL)rewarded callback:(void (^)(BOOL completed, MPRewardedVideoReward *reward))callback {

    hyprOfferReady = NO;
    [[HYPRManager sharedManager] displayOffer:^(BOOL completed, HYPROffer *offer) {
        
        NSLog(@"%@ %@ Offer %@", self.class, NSStringFromSelector(_cmd), completed ? @"completed SUCCESSFULLY" : @"FAILED completion");
        
        if (completed) {
            NSLog(@"Offer: %@", [offer title]);
            NSLog(@"Transaction ID: %@", offer.hyprTransactionID);
        }
        
        MPRewardedVideoReward *videoReward = nil;
        if (rewarded && completed) {
            
            videoReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:offer.rewardText amount:offer.rewardQuantity];
        }
        
        // Refresh inventory state after showing an ad.
        [self canShowAd:^(BOOL canShowAd) {}];
        callback(completed, videoReward);
    }];
}
#pragma mark - Helper Methods -


+ (void)manageUserIdWithUserID:(NSString *)userID {

    if (userID.length < 1) {
        NSString *savedUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kHyprMarketplaceAppConfigKeyUserId];
        if (savedUserID) {
            userID = savedUserID;
        } else {
            userID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
     }
    
    if (![hyprUserID isEqualToString:userID]) {
        hyprUserID = userID;
        [[NSUserDefaults standardUserDefaults] setObject:hyprUserID
                                                  forKey:kHyprMarketplaceAppConfigKeyUserId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
