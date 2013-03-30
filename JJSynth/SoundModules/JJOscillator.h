//
// Created by jesperjalvemo on 3/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJSoundModule.h"


@interface JJOscillator : JJSoundModule{
    @private
    float noteOffset;
    float phase;
    float playingNote;
    float playingFrequency;
}

@property(nonatomic) float noteOffset;
@property(nonatomic) float phase;
@property(nonatomic) float playingNote;
@property(nonatomic) float playingFrequency;

- (id)initWithNoteOffset:(float)noteOffset;

+ (id)oscillatorWithNoteOffset:(float)noteOffset;

- (float)getOutput;
@end