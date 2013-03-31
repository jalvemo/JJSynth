//
// Created by jesperjalvemo on 3/24/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJMidiDelegate.h"

// move..?
float sampleRate;

@interface JJSoundModule : NSObject<JJMidiDelegate>{
    
@private
    JJSoundModule *inputModule;
}

@property(nonatomic, strong) JJSoundModule *inputModule;

- (float)getOutput;


@end
