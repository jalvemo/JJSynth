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
    noteOn = YES;
    phase = 0;
}
- (void)noteOff:(int)note{
    noteOn = NO;
}
- (void)noteTransferTo:(int)note{

}

- (float)getOutput {

    float result;
    if (noteOn){
        phase += 1.0 / sampleRate;

        if (phase <= attack)
            result = phase / attack;
        else if (phase <= decay)
            result = (1.0 - (1.0 - sustainLevel) * (phase - attack) / (decay - attack));
        else
            result = sustainLevel;
    }

    if (!noteOn){
        result = lastResult - releaseRate;
        if (result < 0)
            result = 0;
    }

    lastResult = result;

    return result * [input getOutput];;

}

@end