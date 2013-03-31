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

- (id)initWithNoteOffset:(float)theNoteOffset oscillatorFunction:(JJOscillatorFunction)anOscillatorFunction {
    self = [super init];
    if (self) {
        noteOffset = theNoteOffset;
        oscillatorFunction = anOscillatorFunction;
    }

    return self;
}

+ (id)oscillatorWithNoteOffset:(float)noteOffset oscillatorFunction:(JJOscillatorFunction)anOscillatorFunction {
    return [[self alloc] initWithNoteOffset:noteOffset oscillatorFunction:anOscillatorFunction];
}


- (float)getOutput {
    phase += playingFrequency / sampleRate; //  += 1.0 / (sampleRate / playingFrequency);
    if (phase > 1.0) phase = -1;

    return playingNote ? oscillatorFunction(phase) : 0;
}

- (void)noteOn:(int)note withVelocity:(int)velocity {
    phase = 0;
    playingNote = note;
    playingFrequency = frequencyFromNote(note);
}

- (void)noteOff:(int)note {
//    note = 0;
//    playingFrequency = 0;
//    playingNote = 0;
}

- (void)noteTransferTo:(int)note {
    [self noteOn:note withVelocity:1];
}

@end