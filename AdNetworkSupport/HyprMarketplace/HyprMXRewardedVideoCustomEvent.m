//
//  HyprMXRewardedVideoCustomEvent.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXRewardedVideoCustomEvent.h"
#import "HyprMXController.h"

/**
 * Required Properties for configuration of adapter.
 * NOTE: Please configure your MoPub dashboard with an appropriate distributorID and propertyID.
 */
NSString * const kHyprMarketplaceAppConfigKeyDistributorId = @"distributorID";


@interface HyprMXRewardedVideoCustomEvent () <MPMediationSettingsProtocol>

/**
 * Global Configuration Object containing userID and Array of Rewards
 */
@property (strong, nonatomic) HyprMXGlobalMediationSettings *globalMediationSettings;
@property (nonatomic) BOOL offerReady;

@end

@implementation HyprMXRewardedVideoCustomEvent

#pragma mark - Public Methods -

+ (NSInteger)adapterVersion {
    
    return [HyprMXController adapterVersion];
}

+ (NSString *)hyprMXSdkVersion {
    
    return [[HYPRManager sharedManager] versionString];
}

#pragma mark - MPRewardedVideoCustomEvent Override Methods -

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    
    NSAssert([NSThread isMainThread], @"Expected to be on the main thread, but something went wrong.");
    
    self.globalMediationSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[HyprMXGlobalMediationSettings class]];
    
    NSString *distributorID = [info objectForKey:kHyprMarketplaceAppConfigKeyDistributorId];
    
    if (distributorID == nil || ![distributorID isKindOfClass:[NSString class]] || [distributorID length] == 0 ) {
        
        NSLog(@"HyprMarketplace_HyprAdapter could not initialize - distributorID must be a non-empty string. Please check your MoPub Dashboard's AdUnit Settings");
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
        return;
    }
    NSString *userID = nil;
    if (self.globalMediationSettings.userId) {
        userID = self.globalMediationSettings.userId;
    }
    
    if (![HyprMXController hyprMXInitialized]) {
        [HyprMXController initializeSDKWithDistributorId:distributorID userId];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [HyprMXController checkForAd:^(BOOL isOfferReady) {
        weakSelf.offerReady = isOfferReady;
        
        if (isOfferReady) {
            [weakSelf.delegate rewardedVideoDidLoadAdForCustomEvent:weakSelf];
            
        } else {
            [weakSelf.delegate rewardedVideoDidFailToLoadAdForCustomEvent:weakSelf error:nil];
        }
    }];
}

- (BOOL)hasAdAvailable {
    __weak typeof(self) weakSelf = self;
    
    [HyprMXController checkForAd:^(BOOL isOfferReady) {
        weakSelf.offerReady = isOfferReady;
    }];
    return self.offerReady;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    
    [HyprMXController checkForAd:^(BOOL isOfferReady) {
        if (isOfferReady) {
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
    }];
}

- (void)handleCustomEventInvalidated {
    
    NSLog(@"Adapter Invalidated Event Received.");
}

@end
