//
//  HyprMXGlobalMediationSettings.h
//  HyprMX MoPubSDK Adapter

#import <Foundation/Foundation.h>
#import <HyprMX/HyprMX.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPMediationSettingsProtocol.h"
#endif

@interface HyprMXGlobalMediationSettings : NSObject <MPMediationSettingsProtocol>

/** 
 * An NSString that uniquely identifies each user of the HyprMarketplace SDK
 */
@property (strong, nonatomic) NSString *userId;

/**
 * An NSArray of one or more HYPRReward objects.
 * HYPRRewards can be custom defined with Reward Text, Reward Quantity, and Maximum Quantity.
 * See HYPRReward.h for more information.
 */
@property (strong, nonatomic) NSArray<HYPRReward *> *rewards;

@end
