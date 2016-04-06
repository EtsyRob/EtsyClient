//
//  UIColor+Hex.h
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor(Hex)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end
