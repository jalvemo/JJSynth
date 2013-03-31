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

- (float)getOutput {

    float output = [input getOutput];

    output += strength * [(NSNumber *)history[(phase + 1) % length] floatValue];

    history[phase] = [NSNumber numberWithFloat:output];

    phase = (phase + 1) % length;

    return output;
}


- (void)controllerChange:(float)change onController:(int)controller {
    switch (controller) {
        case 91:
            strength = change / 127;
            break;
        case 17:
//            length = (int) (change * sampleRate / 127); // todo think about how to in a nice way keep the delay continues while changing delay length.
            break;
        default:
            break;
    }
}


@end