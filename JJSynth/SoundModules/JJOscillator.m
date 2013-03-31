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
    }

    return self;
}

+ (id)oscillatorWithNoteOffset:(float)noteOffset andWaveForm:(oscFunction)waveFunction {
    return [[self alloc] initWithNoteOffset:noteOffset andWaveForm:waveFunction];
}

- (float)getOutput {
    phase += playingFrequency / sampleRate; //  += 1.0 / (sampleRate / playingFrequency);
    if (phase > 1) phase = -1;

    return (*waveFormFunction)(phase);
}

- (void)noteOn:(int)note withVelocity:(int)velocity {
    phase = 0;
    playingFrequency = freqFromNote(note + noteOffset);
}

@end