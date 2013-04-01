//
// Created by jesperjalvemo on 3/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJSoundModule.h"

typedef float(^JJOscillatorFunction)(float);

extern JJOscillatorFunction const JJOscillatorSaw;
extern JJOscillatorFunction const JJOscillatorSin;
extern JJOscillatorFunction const JJOscillatorSquare;


@interface JJOscillator : JJSoundModule{
    @private
    JJOscillatorFunction oscillatorFunction;
    float noteOffset;
    float phase;
    float frequency;
    float note;
    float pitchBend;
}

- (id)initWithNoteOffset:(float)noteOffset oscillatorFunction:(JJOscillatorFunction)anOscillatorFunction;

+ (id)oscillatorWithNoteOffset:(float)noteOffset oscillatorFunction:(JJOscillatorFunction)anOscillatorFunction;

- (float)getOutput;
@end