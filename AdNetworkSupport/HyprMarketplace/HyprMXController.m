//
//  HyprMXController.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXController.h"

/**
 * Required Properties for configuration of adapter.
 * NOTE: Please configure your MoPub dashboard with an appropriate distributorID and propertyID.
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

/** An NSString that stores a copy of the distributor ID */
static NSString *hyprDistributorID;

/** An NSString that stores a copy of the User ID */
static NSString *hyprUserID;

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

#pragma mark - MPRewardedVideoCustomEvent Override Methods -

+ (void)initializeSDKWithDistributorId:(NSString *)distributorID userID:(NSString *)userID {
    
    if (hyprSdkInitialized) {
        return;
    }
    
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

+ (void)checkForAd:(void (^)(BOOL))callback {
    [[HYPRManager sharedManager] canShowAd:^(BOOL isOfferReady){
        callback(isOfferReady);
    }];
}

#pragma mark - Helper Methods -

+ (NSString *)manageUserId {
    
    if (self.globalMediationSettings.userId) {
        
        self.userID = self.globalMediationSettings.userId;
    
    } else {
        
        NSString *savedUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kHyprMarketplaceAppConfigKeyUserId];
        
        if (savedUserID) {
            
            self.userID = savedUserID;
            
        } else {
            
            self.userID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            
        }
     }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.userID
                                              forKey:kHyprMarketplaceAppConfigKeyUserId];
            
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
