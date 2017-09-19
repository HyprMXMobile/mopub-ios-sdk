//
//  HyprMXRewardedVideoCustomEvent.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXRewardedVideoCustomEvent.h"
#import "HyprMXGlobalMediationSettings.h"
#import "HyprMXController.h"

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
    
    NSString *distributorID = [info objectForKey:kHyprMarketplaceAppConfigKeyDistributorId];
    
    if (distributorID == nil || ![distributorID isKindOfClass:[NSString class]] || [distributorID length] == 0 ) {
        
        NSLog(@"HyprMarketplace_HyprAdapter could not initialize - distributorID must be a non-empty string. Please check your MoPub Dashboard's AdUnit Settings");
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
        return;
    }
    
    HyprMXGlobalMediationSettings *globalMediationSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[HyprMXGlobalMediationSettings class]];
    NSString *userID = nil;
    
    if (globalMediationSettings.userId.length > 0) {
        userID = globalMediationSettings.userId;
        
    }
    
    [HyprMXController initializeSDKWithDistributorId:distributorID userID:userID];
    
    [HyprMXController canShowAd:^(BOOL isOfferReady) {
        if (isOfferReady) {
            [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];

        } else {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
        }
    }];
}

- (BOOL)hasAdAvailable {
    return [HyprMXController hasAdAvailable];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    
    [HyprMXController canShowAd:^(BOOL isOfferReady) {
        if (isOfferReady) {
            [self.delegate rewardedVideoWillAppearForCustomEvent:self];
            [self.delegate rewardedVideoDidAppearForCustomEvent:self];
            
            [HyprMXController displayOfferRewarded:YES callback:^(BOOL completed, MPRewardedVideoReward *reward) {
                [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
                [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
                if (reward) {
                    
                    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:reward];
                    
                    NSLog(@"Reward: %@ Quantity: %@", reward.currencyType, reward.amount);
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
