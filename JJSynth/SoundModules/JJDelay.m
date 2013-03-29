//
// Created by jesperjalvemo on 3/29/13.
//
// To change the template use AppCode | Preferences | File Templates.´                                                                                                    ´
//


#import "JJDelay.h"


@implementation JJDelay {

}
- (id)initWithStrength:(float)aStrength length:(float)aLength input:(JJSoundModule *)anInput {
    self = [super init];
    if (self) {
        strength = aStrength;
        length = (int) (aLength * sampleRate); // todo: check rounding
        input = anInput;
        phase = 0;
        history = [NSMutableArray arrayWithCapacity:(NSUInteger) length];
        for (int i = 0; i < length; i ++){
            history[(NSUInteger) i] = [NSNumber numberWithFloat:0.0];
        }
    }

    return self;
}

+ (id)delayWithStrength:(float)aStrength length:(float)aLength input:(JJSoundModule *)anInput {
    return [[self alloc] initWithStrength:aStrength length:aLength input:anInput];
}

static const Boolean multiDelay = YES;

- (float)getOutput {

    float output = [input getOutput];

    if (!multiDelay)
        history[phase] = [NSNumber numberWithFloat:output];

    output += strength * [(NSNumber *)history[(phase + 1) % length] floatValue];

    if (multiDelay)
        history[phase] = [NSNumber numberWithFloat:output];

    phase = (phase + 1) % length;

    return output;
//    }

}

@end