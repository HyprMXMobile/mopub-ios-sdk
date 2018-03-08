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
NSInteger const kHyprMarketplace_HyprAdapter_Version = 3;


/*****
 * Shared State. Adapter is reinitialized for each ad request, but we don't want to re-init HyprMX.
 * We store our shared state in these variables.
 *****/

/** A BOOL that is set to YES when HyprMX has been initialized */
static BOOL hyprSdkInitialized = NO;

/** An NSString that stores a copy of the distributor ID */
static NSString *hyprDistributorID;

/** An NSString that stores a copy of the current User ID */
static NSString *hyprUserID;

@interface HyprMXController () <MPMediationSettingsProtocol, HyprMXInitializationDelegate>
@end

@implementation HyprMXController

#pragma mark - Public Methods -

+ (NSInteger)adapterVersion {
    return kHyprMarketplace_HyprAdapter_Version;
}

+ (NSString *)hyprMXSdkVersion {
    return [NSString stringWithFormat:@"%s", HyprMX_SDKVersionString];
}

+ (BOOL)hyprMXInitialized {
    return hyprSdkInitialized;
}

#pragma mark - Initialization and Inventory Checking Methods -

+ (void)initializeSDKWithDistributorId:(NSString *)distributorID userID:(NSString *)userID {
    
    if (hyprSdkInitialized && ![hyprDistributorID isEqualToString:distributorID]) {
        NSLog(@"WARNING: HYPRMX already initialized with another distributor ID");
    }
    
    if (!hyprSdkInitialized ||
        ![userID isEqualToString:hyprUserID]) {
        
        [HyprMXController manageUserIdWithUserID:userID];
        
        if (nil == hyprDistributorID) {
            hyprDistributorID = distributorID;
        }
        
        [HyprMX initializeWithDistributorId:hyprDistributorID userId:hyprUserID initializationDelegate:self];
        hyprSdkInitialized = YES;
    }
}

- (void)initializationDidComplete {
    NSLog(@"HyprMX Initialization finished.");
}

- (void)initializationFailed {
    NSLog(@"HyprMX Initialization Failed.");
    hyprSdkInitialized = NO;
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
