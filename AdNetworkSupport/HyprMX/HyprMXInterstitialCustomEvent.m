//
//  HyprMXInterstitialCustomEvent.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXInterstitialCustomEvent.h"
#import "HyprMXController.h"

@interface HyprMXInterstitialCustomEvent () <HyprMXPlacementDelegate>
@property (readonly) HyprMXPlacement *interstitialPlacement;
@end

@implementation HyprMXInterstitialCustomEvent

- (HyprMXPlacement *)interstitialPlacement {
    HyprMXPlacement *p = [HyprMX getPlacement:HyprMXPlacement.INTERSTITIAL];
    p.placementDelegate = self;
    return p;
}

#pragma mark - Public Methods -

+ (NSInteger)adapterVersion {
    return [HyprMXController adapterVersion];
}

+ (NSString *)hyprMXSdkVersion {
    return [NSString stringWithFormat:@"%s", HyprMX_SDKVersionString];
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
    
    [HyprMXController initializeSDKWithDistributorId:distributorID userID:nil];
    
    [self.interstitialPlacement loadAd];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if ([self.interstitialPlacement isAdAvailable]) {
        [self.interstitialPlacement showAd];
    } else {
        [self.delegate interstitialCustomEventDidExpire:self];
    }
}

- (void)adDidStartForPlacement:(HyprMXPlacement *)placement {
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)adDidFinishForPlacement:(HyprMXPlacement *)placement adState:(HyprMXAdState)adState {
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)adDisplayErrorForPlacement:(HyprMXPlacement *)placement error:(HyprMXError)hyprMXError {
    NSString *message = @"Unknown";
    switch (hyprMXError) {
        case DISPLAY_ERROR:
            message = @"Error displaying Ad.";
            break;
        case NO_FILL:
            message = @"No Fill.";
            break;
        case PLACEMENT_DOES_NOT_EXIST:
            message = [NSString stringWithFormat:@"No such placement: %@", placement];
            break;
    }
    NSLog(@"[HyprMX] Error displaying %@ ad: %@", placement.placementName, message);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adAvailableForPlacement:(HyprMXPlacement *)placement {
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)adNotAvailableForPlacement:(HyprMXPlacement *)placement {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

@end



