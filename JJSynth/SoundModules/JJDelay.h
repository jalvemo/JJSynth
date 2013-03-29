//
// Created by jesperjalvemo on 3/29/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJSoundModule.h"


@interface JJDelay : JJSoundModule{
    @private
    JJSoundModule *input;

    float strength;
    int length;

    NSUInteger phase;
    NSMutableArray *history;
}
- (id)initWithStrength:(float)aStrength length:(float)aLength input:(JJSoundModule *)anInput;

+ (id)delayWithStrength:(float)aStrength length:(float)aLength input:(JJSoundModule *)anInput;


@end