//
//  HyprMXInterstitialCustomEvent.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXInterstitialCustomEvent.h"

/**
 * Required Properties for configuration of adapter.
 * NOTE: Please configure your MoPub dashboard with an appropriate distributorID and propertyID.
 */
NSString * const kHyprMarketplaceAppConfigKeyDistributorId = @"distributorID";
NSString * const kHyprMarketplaceAppConfigKeyPropertyId = @"propertyID";
NSString * const kHyprMarketplaceAppConfigKeyUserId = @"userID";

NSInteger const kHyprMarketplace_Interstitial_HyprAdapter_Version = 1;

@interface HyprMXInterstitialCustomEvent () <MPMediationSettingsProtocol>

#pragma mark - Internal Properties -

/**
 * A unique NSString that identifies an individual user
 * userID can be provided by the HyprMXGlobalMediationSettings object
 * if no userID is provided, the UIDevice identifierForVendor is used
 */
@property (strong, nonatomic) NSString *userID;

/**
 * Global Configuration Object containing userID and Array of Rewards
 */
@property (strong, nonatomic) HyprMXGlobalMediationSettings *globalMediationSettings;


#pragma mark - Internal Methods -

/**
 * This method manages the retreival and storage of the user ID and checks the globalMediationSettings and NSUserDefaults for a valid ID
 * Will set the userID to UIDevice identifierForVendor if no other is available and stores the userID property to NSUserDefaults
 */
- (void)manageUserId;

@end

/*****
 * Shared State. Adapter is reinitialized for each ad request, but we don't want to re-init HyprMX.
 * We store our shared state in these variables.
 *****/

/** A BOOL that is set to YES when HyprMX has been initialized */
//static BOOL hyprSdkInitialized = NO;

/** An NSString that stores a copy of the distributor ID */
//static NSString *hyprDistributorID;

/** An NSString that stores a copy of the property ID */
//static NSString *hyprPropertyID;


@implementation HyprMXInterstitialCustomEvent

#pragma mark - Public Methods -

+ (NSInteger)adapterVersion {

    return kHyprMarketplace_Interstitial_HyprAdapter_Version;
}

+ (NSString *)hyprMXSdkVersion {

    return [[HYPRManager sharedManager] versionString];
}

#pragma mark - MPInterstitialCustomEvent Override Methods -

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    NSAssert([NSThread isMainThread], @"Expected to be on the main thread, but something went wrong.");
    
    self.globalMediationSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[HyprMXGlobalMediationSettings class]];
    
    NSString *distributorID = [info objectForKey:kHyprMarketplaceAppConfigKeyDistributorId];
    
    
        [[HYPRManager sharedManager] canShowAd:^(BOOL isOfferReady) {
    
            if (isOfferReady) {
                [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    
            } else {
                [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
    
            }
        }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    
}

@end



