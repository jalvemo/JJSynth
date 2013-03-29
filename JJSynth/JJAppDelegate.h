//
//  JJAppDelegate.h
//  JJSynth
//
//  Created by Jesper Jalvemo on 03/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JJNoteDelegate.h"

@interface JJAppDelegate : NSObject <NSApplicationDelegate, JJNoteDelegate>{
    @private

    NSMutableArray *currentlyPlayingNotesInOrder;
    NSMutableSet *currentlyPlayingNotes;
    NSArray *noteDelegates;

}

@property (assign) IBOutlet NSWindow *window;

@property(nonatomic, strong) NSMutableArray *currentlyPlayingNotesInOrder;
@property(nonatomic, strong) NSMutableSet *currentlyPlayingNotes;
@property(nonatomic, strong) NSArray *noteDelegates;
@end