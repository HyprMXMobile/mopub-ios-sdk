//
//  HyprMXInterstitialCustomEvent.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXInterstitialCustomEvent.h"
#import "HyprMXController.h"

@implementation HyprMXInterstitialCustomEvent

#pragma mark - Public Methods -

+ (NSInteger)adapterVersion {
    
    return [HyprMXController adapterVersion];
}

+ (NSString *)hyprMXSdkVersion {
    
    return [[HYPRManager sharedManager] versionString];
}

#pragma mark - MPInterstitialCustomEvent Override Methods -

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    NSAssert([NSThread isMainThread], @"Expected to be on the main thread, but something went wrong.");
    
    NSString *distributorID = [info objectForKey:kHyprMarketplaceAppConfigKeyDistributorId];
    
    if (distributorID == nil || ![distributorID isKindOfClass:[NSString class]] || [distributorID length] == 0 ) {
        
        NSLog(@"HyprMarketplace_HyprAdapter could not initialize - distributorID must be a non-empty string. Please check your MoPub Dashboard's AdUnit Settings");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    
    if (![HyprMXController hyprMXInitialized]) {
        [HyprMXController initializeSDKWithDistributorId:distributorID];
    }
    
    [HyprMXController canShowAd:^(BOOL isOfferReady) {
        if (isOfferReady) {
            [self.delegate interstitialCustomEvent:self didLoadAd:nil];
            
        } else {
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        }
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [HyprMXController canShowAd:^(BOOL isOfferReady) {
        if (isOfferReady) {
            [self.delegate interstitialCustomEventWillAppear:self];
            [self.delegate interstitialCustomEventDidAppear:self];
            
            [HyprMXController displayOfferRewarded:NO callback:^(BOOL completed, MPRewardedVideoReward *reward) {
                [self.delegate interstitialCustomEventWillDisappear:self];
                [self.delegate interstitialCustomEventDidDisappear:self];
                
            }];
        } else {
            [self.delegate interstitialCustomEventDidExpire:self];
        }
    }];
}

@end



