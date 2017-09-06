//
//  HyprMXRewardedVideoCustomEvent.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXRewardedVideoCustomEvent.h"

/**
 * Required Properties for configuration of adapter.
 * NOTE: Please configure your MoPub dashboard with an appropriate distributorID and propertyID.
 */
NSString * const kHyprMarketplaceAppConfigKeyDistributorId = @"distributorID";
NSString * const kHyprMarketplaceAppConfigKeyPropertyId = @"propertyID";
NSString * const kHyprMarketplaceAppConfigKeyUserId = @"userID";

NSInteger const kHyprMarketplace_HyprAdapter_Version = 1;

@interface HYPRManager ()

/**
 * This method checks the Inventory Status of offers
 * Also begins caching of offer assets
 *
 * @param A completion handler with boolean stating if the offer is ready to present
 */
- (void)canShowAd:(void (^)(BOOL))callback;

@end


@interface HyprMXRewardedVideoCustomEvent () <MPMediationSettingsProtocol>

#pragma mark - Internal Properties -

/**
 * A BOOL that is set to YES when checkInventory: has completed and offers are ready to show
 */
@property (nonatomic) BOOL offerReady;

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

/**
 * This method stores the rewards array in the HyprManager if provided by the globalMediationSettings
 */
- (void)configureRewardsFromGlobalSettings;

@end

/*****
 * Shared State. Adapter is reinitialized for each ad request, but we don't want to re-init HyprMX.
 * We store our shared state in these variables.
 *****/

/** A BOOL that is set to YES when HyprMX has been initialized */
static BOOL hyprSdkInitialized = NO;

/** An NSString that stores a copy of the distributor ID */
static NSString *hyprDistributorID;

/** An NSString that stores a copy of the property ID */
static NSString *hyprPropertyID;


@implementation HyprMXRewardedVideoCustomEvent

#pragma mark - Public Methods -

+ (NSInteger)adapterVersion {
    
    return kHyprMarketplace_HyprAdapter_Version;
}

+ (NSString *)hyprMXSdkVersion {
    
    return [[HYPRManager sharedManager] versionString];
}

#pragma mark - MPRewardedVideoCustomEvent Override Methods -

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    
    NSAssert([NSThread isMainThread], @"Expected to be on the main thread, but something went wrong.");
    
    self.offerReady = NO;
    
    self.globalMediationSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[HyprMXGlobalMediationSettings class]];
    
    NSString *propertyID = [info objectForKey:kHyprMarketplaceAppConfigKeyPropertyId];
    
    if (propertyID == nil || ![propertyID isKindOfClass:[NSString class]]) {
        
        NSLog(@"HyprMarketplace_HyprAdapter could not initialize - propertyID must be a string (empty is OK). Please check your MoPub Dashboard's AdUnit Settings.");
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
        return;
    }
    
    NSString *distributorID = [info objectForKey:kHyprMarketplaceAppConfigKeyDistributorId];
    
    if (distributorID == nil || ![distributorID isKindOfClass:[NSString class]] || [distributorID length] == 0 ) {
        
        NSLog(@"HyprMarketplace_HyprAdapter could not initialize - distributorID must be a non-empty string. Please check your MoPub Dashboard's AdUnit Settings");
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
        return;
    }
    
    [self manageUserId];
    
    if (!hyprSdkInitialized ||
        ![[HYPRManager sharedManager].userId isEqualToString:self.userID] ||
        ![hyprDistributorID isEqualToString:distributorID] ||
        ![hyprPropertyID isEqualToString:propertyID]) {
        
        hyprDistributorID = distributorID;
        hyprPropertyID = propertyID;
        
        [HYPRManager enableDebugLogging];
        [HYPRManager disableAutomaticPreloading];
        [self configureRewardsFromGlobalSettings];
        
        [[HYPRManager sharedManager] initializeWithDistributorId:distributorID
                                                      propertyId:propertyID
                                                          userId:self.userID];
        
        hyprSdkInitialized = YES;
    }
    
    [[HYPRManager sharedManager] canShowAd:^(BOOL isOfferReady) {
        
        self.offerReady = isOfferReady;
        
        if (isOfferReady) {
            [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];

        } else {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
            
        }
    }];
}

- (BOOL)hasAdAvailable {
    
    [[HYPRManager sharedManager] canShowAd:^(BOOL isOfferReady){
        
        self.offerReady = isOfferReady;
    }];
    
    return self.offerReady;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    
    if (self.offerReady) {
        
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
        
        [[HYPRManager sharedManager] displayOffer:^(BOOL completed, HYPROffer *offer) {
            
            NSLog(@"%@ %@ Offer %@", self.class, NSStringFromSelector(_cmd), completed ? @"completed SUCCESSFULLY" : @"FAILED completion");
            
            [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
            [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
            
            if (completed) {
                
                MPRewardedVideoReward *videoReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:offer.rewardText amount:offer.rewardQuantity];
                
                [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:videoReward];
                
                NSLog(@"Offer: %@", [offer title]);
                NSLog(@"Transaction ID: %@", offer.hyprTransactionID);
                NSLog(@"Reward ID: %@ Quantity: %@", offer.rewardIdentifier, offer.rewardQuantity);
            }
        }];
        
    } else {
        
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:nil];
    }
}

- (void)handleCustomEventInvalidated {
    
    NSLog(@"Adapter Invalidated Event Received.");
}

#pragma mark - Helper Methods -

- (void)manageUserId {
    
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

- (void)configureRewardsFromGlobalSettings {
    
    if ([self.globalMediationSettings.rewards count] < 1) {
        
        NSLog(@"No Rewards defined in Global Mediation Settings, using default rewards");
        
        return;
    }
    
    [[HYPRManager sharedManager] setRewards:self.globalMediationSettings.rewards];
}

@end
