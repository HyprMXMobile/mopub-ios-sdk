//
//  HyprMXController.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXController.h"
#import "HyprMXGlobalMediationSettings.h"

/**
 * Required Properties for configuration of adapter.
 * NOTE: Please configure your MoPub dashboard with an appropriate distributorID.
 */
NSString * const kHyprMarketplaceAppConfigKeyDistributorId = @"distributorID";


NSString * const kHyprMarketplaceAppConfigKeyUserId = @"userID";

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

+ (BOOL)isOfferReady {
    return hyprOfferReady;
}

#pragma mark - Initialization and Inventory Checking Methods -

+ (void)initializeSDKWithDistributorId:(NSString *)distributorID {
    
    if (hyprSdkInitialized) {
        return;
    }
    
    [HyprMXController manageUserId];
    
    if (!hyprSdkInitialized ||
        ![[HYPRManager sharedManager].userId isEqualToString:hyprUserID] ||
        ![hyprDistributorID isEqualToString:distributorID]) {
        
        hyprDistributorID = distributorID;
        
        [HYPRManager enableDebugLogging];
        [HYPRManager disableAutomaticPreloading];
        
        [[HYPRManager sharedManager] initializeWithDistributorId:hyprDistributorID
                                                      propertyId:hyprPropertyID
                                                          userId:hyprUserID];
        hyprSdkInitialized = YES;
    }
}

+ (BOOL)checkForAd {
    [[HYPRManager sharedManager] canShowAd:^(BOOL isOfferReady){
        hyprOfferReady = isOfferReady;
    }];
    return hyprOfferReady;
}

+ (void)canShowAd:(void (^)(BOOL))callback {
    [[HYPRManager sharedManager] canShowAd:^(BOOL isOfferReady){
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
        callback(completed, videoReward);
    }];
}
#pragma mark - Helper Methods -


+ (void)manageUserId {

    HyprMXGlobalMediationSettings *globalMediationSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[HyprMXGlobalMediationSettings class]];
    NSString *userID = nil;
    
    if (globalMediationSettings.userId.length > 0) {
        userID = globalMediationSettings.userId;
        
    } else {
        
        NSString *savedUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kHyprMarketplaceAppConfigKeyUserId];
        if (savedUserID) {
            userID = savedUserID;

        } else {
            userID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
     }
    
    hyprUserID = userID;
    [[NSUserDefaults standardUserDefaults] setObject:userID
                                              forKey:kHyprMarketplaceAppConfigKeyUserId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
