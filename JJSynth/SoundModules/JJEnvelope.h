//
// Created by jesperjalvemo on 3/26/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJSoundModule.h"
#import "JJNoteDelegate.h"


@interface JJEnvelope : JJSoundModule <JJNoteDelegate>{
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
@property(nonatomic) float attack;
@property(nonatomic) float decay;
@property(nonatomic) float sustainLevel;
@property(nonatomic) float releaseRate;

@property(nonatomic, strong) JJSoundModule *input;

- (id)initWithAttack:(float)attack decay:(float)decay sustainLevel:(float)sustainLevel release:(float)release input:(JJSoundModule *)input;

+ (id)envelopeWithAttack:(float)attack decay:(float)decay sustainLevel:(float)sustainLevel release:(float)release input:(JJSoundModule *)input;

@end