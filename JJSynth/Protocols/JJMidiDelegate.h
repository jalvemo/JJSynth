//
// Created by jesperjalvemo on 3/24/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@protocol JJMidiDelegate <NSObject>
- (void)noteOn:(int)note withVelocity: (int)velocity;
- (void)noteOff:(int)note;
- (void)noteTransferTo:(int)note;
- (void)pitchBend:(float)bend;
- (void)controllerChange:(float)change onController: (int)controller;
@end