//
// Created by jesperjalvemo on 3/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJSoundModule.h"

#define freqFromNote(note) (440 * (float)pow(2,(note-69)/12))

typedef float (*oscFunction)(float);

extern float squareOsc(float phase);
extern float sawOsc(float phase);
extern float sineOsc(float phase);

@interface JJOscillator : JJSoundModule{
    @private
    oscFunction waveFormFunction;
    float noteOffset;
    float phase;
    float frequency;
    float note;
    float pitchBend;
}

- (id)initWithNoteOffset:(float)theNoteOffset andWaveForm:(oscFunction)waveFunction;

+ (id)oscillatorWithNoteOffset:(float)noteOffset andWaveForm:(oscFunction)waveFunction;

- (float)getOutput;
@end