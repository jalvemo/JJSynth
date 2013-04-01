//
//  JJFilter.m
//  JJSynth
//
//  Created by Joakim Bergman on 2013-03-30.
//
//

#import "JJFilter.h"

@implementation JJFilter

// http://www.musicdsp.org/showone.php?id=185
// cutoff and resonance are from 0 to 127
- (void)updateFilter {
    c = (float) pow(0.5, (128 - cutoff)   / 16.0);
    r = (float) pow(0.5, (resonance + 24) / 16.0);
    fval = 1 - r * c;
}

- (float)applySimpleFilterToInput:(float)input {
    v0 = fval * v0 - c * v1 + c * input;
    v1 = fval * v1 + c * v0;

    return v1;
}

- (float)getOutput {
    if (cutoff == 127 && resonance == 0){
        return [input getOutput];
    }else{
        return [self applySimpleFilterToInput:[input getOutput]];
    }
}

- (id)initWithCutoff:(float)theCutoff resonance:(float)theResonance input:(JJSoundModule *)theInput {
    self = [super init];
    if (self) {
        cutoff = theCutoff;
        resonance = theResonance;
        input = theInput;

        [self updateFilter];
    }
    
    return self;
}

+ (id)filterWithCutoff:(float)cutoff resonance:(float)resonance input:(JJSoundModule *)input {
    return [[self alloc] initWithCutoff:cutoff resonance:resonance input:input];
}

- (void)controllerChange:(float)change onController:(int)controller {
    // http://www.spectrasonics.net/products/legacy/atmosphere-cclist.php
    switch (controller) {
        case 71:
            resonance = change;
            [self updateFilter];
            break;
        case 74:
            cutoff = change;
            [self updateFilter];
            break;
        default:
            break;
    }
}

@end
