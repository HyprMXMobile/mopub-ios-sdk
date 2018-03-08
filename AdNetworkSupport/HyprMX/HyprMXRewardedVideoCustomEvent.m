//
//  HyprMXRewardedVideoCustomEvent.m
//  HyprMX MoPubSDK Adapter

#import "HyprMXRewardedVideoCustomEvent.h"
#import "HyprMXGlobalMediationSettings.h"
#import "HyprMXController.h"

@interface HyprMXRewardedVideoCustomEvent () <HyprMXPlacementDelegate>

@property (readonly) HyprMXPlacement *rewardedPlacement;

@end

@implementation HyprMXRewardedVideoCustomEvent

- (HyprMXPlacement *)rewardedPlacement {
    HyprMXPlacement *p = [HyprMX getPlacement:HyprMXPlacement.rewardedPlacementName];
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
    
    [self.rewardedPlacement loadAd];
}

- (BOOL)hasAdAvailable {
    return [self.rewardedPlacement isAdAvailable];
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if ([self.rewardedPlacement isAdAvailable]) {
        [self.rewardedPlacement showAd];
    } else {
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:nil];
    }
}

- (void)handleCustomEventInvalidated {
    NSLog(@"Adapter Invalidated Event Received.");
}

#pragma mark Placement Delegate

- (void)adDidStartForPlacement:(HyprMXPlacement *)placement {
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)adDidFinishForPlacement:(HyprMXPlacement *)placement adState:(HyprMXAdState)adState {
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

- (void)adDidRewardForPlacement:(HyprMXPlacement *)placement rewardName:(NSString *)rewardName rewardValue:(NSInteger)rewardValue {
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyType:rewardName amount:@(rewardValue)]];{
    NSLog(@"Reward: %@ Quantity: %@", rewardName, @(rewardValue));}
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
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:nil];
}

- (void)adAvailableForPlacement:(HyprMXPlacement *)placement {
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)adNotAvailableForPlacement:(HyprMXPlacement *)placement {
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:nil];
}


@end
