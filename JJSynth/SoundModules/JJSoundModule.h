//
// Created by jesperjalvemo on 3/24/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

// move..?
float sampleRate;
static inline float frequencyFromNote(float note) {
    return (float) (440.0 * pow(2,((double)note - 69.0) / 12.0));
}

@interface JJSoundModule : NSObject{

@private
    JJSoundModule *inputModule;
}

@property(nonatomic, strong) JJSoundModule *inputModule;

- (float)getOutput;


@end
