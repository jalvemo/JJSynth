//
// Created by jesperjalvemo on 3/26/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JJSoundModule.h"


@interface JJMixer : JJSoundModule{
    @private
    NSArray *inputs;
}

@property(nonatomic, strong) NSArray *inputs;

- (id)initWithInputs:(NSArray *)inputs;

+ (id)mixerWithInputs:(NSArray *)inputs;

- (float)getOutput;

@end