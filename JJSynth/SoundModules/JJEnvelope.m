//
// Created by jesperjalvemo on 3/26/13.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "JJEnvelope.h"

@implementation JJEnvelope {

}
- (id)initWithAttack:(float)theAttack decay:(float)theDecay sustainLevel:(float)theSustainLevel release:(float)theRelease input:(JJSoundModule *)theInput {
    self = [super init];
    if (self) {
        attack = theAttack;
        decay = attack + theDecay;
        sustainLevel = theSustainLevel;
        releaseRate = 1.0 / sampleRate / theRelease;
        input = theInput;
        noteOn = NO;
    }

    return self;
}

+ (id)envelopeWithAttack:(float)attack decay:(float)decay sustainLevel:(float)sustainLevel release:(float)release input:(JJSoundModule *)input {
    return [[self alloc] initWithAttack:attack decay:decay sustainLevel:sustainLevel release:release input:input];
}

- (void)noteOn:(int)note withVelocity: (int)velocity{
    if (!noteOn)
        phase = 0;

    noteOn = YES;
}
- (void)noteOff:(int)note{
    noteOn = NO;
}

- (float)getOutput {

    float result;
    if (noteOn) {
        phase += 1.0 / sampleRate;

        if (phase <= attack)
            result = phase / attack;
        else if (phase <= decay)
            result = (1.0 - (1.0 - sustainLevel) * (phase - attack) / (decay - attack));
        else
            result = sustainLevel;
    }else {
        result = lastResult - releaseRate;
        if (result < 0)
            result = 0;
    }

    lastResult = result;

    return result * [input getOutput];
}

#define MAX_ATTACK_DECAY_RELEASE 127
- (void)controllerChange:(float)change onController:(int)controller {

    switch (controller) {
        case 73:
            attack = change / MAX_ATTACK_DECAY_RELEASE;
            break;
        case 75:
            decay = change / MAX_ATTACK_DECAY_RELEASE;
            break;
        case 79:
            sustainLevel = change / 127;
            break;
        case 72:
            releaseRate = 1.0 / sampleRate / (change / MAX_ATTACK_DECAY_RELEASE);
            break;
        default:
            break;
    }
}

@end