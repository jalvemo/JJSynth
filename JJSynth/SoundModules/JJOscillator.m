//
// Created by jesperjalvemo on 3/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "JJOscillator.h"
#import "math.h"

NSString * const VPCreativeTrackingEventCreativeView = @"VPCreativeTrackingEventCreativeView";

JJOscillatorFunction const JJOscillatorSaw = ^(float phase){
    return phase;
};
JJOscillatorFunction const JJOscillatorSin = ^(float phase){
    return (float)sin(phase * 2 * M_PI);
};
JJOscillatorFunction const JJOscillatorSquare = ^(float phase){
    return phase > 0 ? 1.0f : -1.0f;
};


static inline float frequencyFromNote(float note) {
    return (float) (440.0 * pow(2,((double)note - 69.0) / 12.0));
}

@implementation JJOscillator {

}

- (id)initWithNoteOffset:(float)theNoteOffset amplitude:(float)anAmplitude oscillatorFunction:(JJOscillatorFunction)anOscillatorFunction {
    self = [super init];
    if (self) {
        noteOffset = theNoteOffset;
        oscillatorFunction = anOscillatorFunction;
        amplitude = anAmplitude;
    }

    return self;
}


+ (id)oscillatorWithNoteOffset:(float)noteOffset amplitude:(float)anAmplitude ampletude:(float)anAmpletude oscillatorFunction:(JJOscillatorFunction)anOscillatorFunction {
    return [[self alloc] initWithNoteOffset:noteOffset amplitude:anAmplitude oscillatorFunction:anOscillatorFunction];
}

- (float)getOutput {
    phase += frequency / sampleRate;
    if (phase > 1) phase = -1;

    return oscillatorFunction(phase);

}

- (void)noteOn:(int)theNote withVelocity:(int)velocity {
    phase = 0;
    note = theNote;
    frequency = amplitude * frequencyFromNote(theNote + pitchBend + noteOffset);
}

- (void)pitchBend:(float)bend {
    pitchBend = bend;
    frequency = amplitude * frequencyFromNote(note + pitchBend + noteOffset);
}

@end