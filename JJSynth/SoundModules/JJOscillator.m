//
// Created by jesperjalvemo on 3/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "JJOscillator.h"


@implementation JJOscillator {

}

extern float sineOsc(float phase) {
    return (float)sin(phase * M_PI * 2);
}

extern float squareOsc(float phase) {
    return signbit(phase);
}

extern float sawOsc(float phase) {
    return phase;
}

- (id)initWithNoteOffset:(float)theNoteOffset andWaveForm:(oscFunction)waveFunction {
    self = [super init];
    if (self) {
        noteOffset = theNoteOffset;
        waveFormFunction = waveFunction;
        pitchBend = 0;
    }

    return self;
}

+ (id)oscillatorWithNoteOffset:(float)noteOffset andWaveForm:(oscFunction)waveFunction {
    return [[self alloc] initWithNoteOffset:noteOffset andWaveForm:waveFunction];
}

- (float)getOutput {
    phase += frequency / sampleRate; //  += 1.0 / (sampleRate / frequency);
    if (phase > 1) phase = -1;

    return (*waveFormFunction)(phase);
}

- (void)noteOn:(int)theNote withVelocity:(int)velocity {
    phase = 0;
    note = theNote;
    frequency = freqFromNote(theNote + pitchBend + noteOffset);
}

- (void)pitchBend:(float)bend {
    pitchBend = bend;
    frequency = freqFromNote(note + pitchBend + noteOffset);
}

@end