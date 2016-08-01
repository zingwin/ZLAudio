/*------------------------------------------------------------
 *  ______  _   _   _____   _   _    _        _   ___    _
 * |___  / | | | | /  _  \ | | | |  | |      |_| |   \  | |
 *    / /  | |_| | | | | | | | | |  | |       _  |  \ \ | |
 *   / /   |  _  | | | | | | | | |  | |      | | | | \ \| |
 *  / /__  | | | | | |_| | | |_| |  | |____  | | | |  \   |
 * /_____| |_| |_| \_____/ \_____/  |______\ |_| |_|   \__|
 *
 *                   May. 26 2014 @马上科技
 ------------------------------------------------------------*/

#import "ZLAudioDeviceManager+ProximitySensor.h"
#import <UIKit/UIKit.h>

@implementation ZLAudioDeviceManager (ProximitySensor)
@dynamic isSupportProximitySensor;
@dynamic isCloseToUser;


#pragma mark - proximity sensor
- (BOOL)isProximitySensorEnabled {
    BOOL ret = NO;
    ret = self.isSupportProximitySensor && [UIDevice currentDevice].proximityMonitoringEnabled;
    
    return ret;
}

- (BOOL)enableProximitySensor {
    BOOL ret = NO;
    if (_isSupportProximitySensor) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        ret = YES;
    }
    
    return ret;
}

- (BOOL)disableProximitySensor {
    BOOL ret = NO;
    if (_isSupportProximitySensor) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        _isCloseToUser = NO;
        ret = YES;
    }
    
    return ret;
}

- (void)sensorStateChanged:(NSNotification *)notification {
    BOOL ret = NO;
    if ([[UIDevice currentDevice] proximityState] == YES) {
        ret = YES;
    }
    _isCloseToUser = ret;
    if([self.delegate respondsToSelector:@selector(proximitySensorChanged:)]){
        [self.delegate proximitySensorChanged:_isCloseToUser];
    }
}

#pragma mark - getter
- (BOOL)isCloseToUser {
    return _isCloseToUser;
}

- (BOOL)isSupportProximitySensor {
    return _isSupportProximitySensor;
}
@end
