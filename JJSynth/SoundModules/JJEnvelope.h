//
// Created by jesperjalvemo on 3/26/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJSoundModule.h"


@interface JJEnvelope : JJSoundModule{
    @private
    JJSoundModule *input;
    float attack;
    float decay;
    float sustainLevel;
    float releaseRate;
    float phase;
    float lastResult;

    Boolean noteOn;
}

- (id)initWithAttack:(float)attack decay:(float)decay sustainLevel:(float)sustainLevel release:(float)release input:(JJSoundModule *)input;

+ (id)envelopeWithAttack:(float)attack decay:(float)decay sustainLevel:(float)sustainLevel release:(float)release input:(JJSoundModule *)input;

@end