//
// Created by jesperjalvemo on 3/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "JJOcillator.h"


@implementation JJOcillator {

}
@synthesize noteOffset;
@synthesize phase;
@synthesize playingNote;
@synthesize playingFrequency;

- (id)initWithNoteOffset:(float)noteOffset {
    self = [super init];
    if (self) {
        self.noteOffset = noteOffset;
    }

    return self;
}

+ (id)ocillatorWithNoteOffset:(float)noteOffset {
    return [[self alloc] initWithNoteOffset:noteOffset];
}


- (float)getOutput {
    phase += playingFrequency / sampleRate; //  += 1.0 / (sampleRate / playingFrequency);
    if (phase > 1.0) phase = -1;

    return playingNote ? phase : 0;
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