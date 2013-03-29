//
// Created by jesperjalvemo on 3/24/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@protocol JJNoteDelegate <NSObject>
- (void)noteOn:(int)note withVelocity: (int)velocity;
- (void)noteOff:(int)note;
- (void)noteTransferTo:(int)note;

@end