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

#import <Foundation/Foundation.h>

@protocol ZLDeviceManagerProximitySensorDelegate<NSObject>
/*!
 @method
 @brief Posted when the state of the proximity sensor changes.
 @param isCloseToUser indicates whether the proximity sensor is close to the user (YES) or not (NO).
 @discussion
 @result
 */
- (void)proximitySensorChanged:(BOOL)isCloseToUser;


@end
