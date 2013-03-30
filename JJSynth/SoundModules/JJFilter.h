//
//  JJFilter.h
//  JJSynth
//
//  Created by Joakim Bergman on 2013-03-30.
//
//

#import "JJSoundModule.h"

@interface JJFilter : JJSoundModule {
@private
    JJSoundModule *input;

    float cutoff;
    float resonance;
    float c;
    float r;
    float v0;
    float v1;
    float fval;
}

- (id)initWithCutoff:(float)cutoff resonance:(float)resonance input:(JJSoundModule *)input;

+ (id)filterWithCutoff:(float)cutoff resonance:(float)resonance input:(JJSoundModule *)input;

@end
