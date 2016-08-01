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

#import "ZLAudioDeviceManager.h"

@interface ZLAudioDeviceManager (ProximitySensor)
#pragma mark - proximity sensor
@property (nonatomic, readonly) BOOL isSupportProximitySensor;
@property (nonatomic, readonly) BOOL isCloseToUser;
@property (nonatomic, readonly) BOOL isProximitySensorEnabled;

- (BOOL)enableProximitySensor;
- (BOOL)disableProximitySensor;
- (void)sensorStateChanged:(NSNotification *)notification;
@end
