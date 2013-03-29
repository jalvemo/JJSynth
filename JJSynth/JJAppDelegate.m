//
//  JJAppDelegate.m
//  JJSynth
//
//  Created by Jesper Jalvemo on 03/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
#import <CoreMIDI/CoreMIDI.h>
#import "JJAppDelegate.h"
#import "Novocaine.h"
#import "JJSoundModule.h"
#import "JJOcillator.h"
#import "JJMixer.h"
#import "JJEnvelope.h"

@implementation JJAppDelegate
//
//float sineOsc(float phase){
//    return (float) sin(phase * M_PI * 2);
//}
//
//float squareOsc(float phase){
//    return signbit(phase);
//}
//
//float sawOsc(float phase){
//    return phase;
//}

@synthesize currentlyPlayingNotesInOrder;
@synthesize currentlyPlayingNotes;

@synthesize noteDelegates;

- (void)noteOn:(int)note withVelocity: (int)velocity{
    for (id<JJNoteDelegate> noteDelegate in noteDelegates){
        [noteDelegate noteOn:note withVelocity:velocity];
    }
}
- (void)noteOff:(int) note{
    for (id<JJNoteDelegate> noteDelegate in noteDelegates){
        [noteDelegate noteOff:note];
    }
}
- (void)noteTransferTo:(int) note{
    for (id<JJNoteDelegate> noteDelegate in noteDelegates){
        [noteDelegate noteTransferTo:note];
    }
}

void midiInputCallback (const MIDIPacketList *packetList, void *procRef, void *srcRef)
{
    JJAppDelegate *delegate = (__bridge JJAppDelegate *)procRef;

    const MIDIPacket *packet = packetList->packet;
    int message = packet->data[0];
    int note = packet->data[1];
    int velocity = packet->data[2];

    //NSLog(@"%3i %3i %3i", message, note, velocity);

    if ((message >= 128 && message <= 143) || velocity == 0) { // note off
        [delegate.currentlyPlayingNotes removeObject:[NSNumber numberWithInt:note]];

        // ta bort senaste noterna om de inte spelas längre
        while ([delegate.currentlyPlayingNotesInOrder count] > 0 && ![delegate.currentlyPlayingNotes containsObject:[delegate.currentlyPlayingNotesInOrder lastObject]]) {
            [delegate.currentlyPlayingNotesInOrder removeLastObject];
        }

        if ([delegate.currentlyPlayingNotesInOrder count] > 0) {
            [delegate noteTransferTo:[[[delegate currentlyPlayingNotesInOrder] lastObject] integerValue]];

        } else {
            [delegate noteOff:note];
        }
    }
    else if (message >= 144 && message <= 159) { // note on
        if (delegate.currentlyPlayingNotes.count == 0){
            [delegate noteOn:note withVelocity:velocity];
        }else{
            [delegate noteTransferTo:note];
        }
        [delegate.currentlyPlayingNotesInOrder addObject:[NSNumber numberWithInt:note]];
        [delegate.currentlyPlayingNotes addObject:[NSNumber numberWithInt:note]];
    }
}

- (void)setupMIDI{

    //set up midi inputModule
    MIDIClientRef midiClient;
    MIDIEndpointRef src;

    OSStatus result;

    result = MIDIClientCreate(CFSTR("MIDI client"), NULL, NULL, &midiClient);
    if (result != noErr) {
        //        NSLog(@"Errore : %s - %s",
        //              GetMacOSStatusErrorString(result),
        //              GetMacOSStatusCommentString(result));
        NSLog(@"Error : error creating midi client.");
        return;
    }

    //note the use of "self" to send the reference to this document object
    result = MIDIDestinationCreate(midiClient, CFSTR("Porta virtuale"), midiInputCallback, (__bridge void *)self, &src);
    if (result != noErr ) {
        //        NSLog(@"Errore : %s - %s",
        //              GetMacOSStatusErrorString(result),
        //              GetMacOSStatusCommentString(result));
        NSLog(@"Error : error creating midi destination.");
        return;
    }

    MIDIPortRef inputPort;
    //and again here
    result = MIDIInputPortCreate(midiClient, CFSTR("Input"), midiInputCallback, (__bridge void *) self, &inputPort);

    ItemCount numOfDevices = MIDIGetNumberOfDevices();

    for (int i = 0; i < numOfDevices; i++) {
        MIDIDeviceRef midiDevice = MIDIGetDevice(i);
        //        NSDictionary *midiProperties;
        CFPropertyListRef *midiProperties;

        MIDIObjectGetProperties(midiDevice, (CFPropertyListRef *)&midiProperties, YES);
        src = MIDIGetSource(i);
        MIDIPortConnectSource(inputPort, src, NULL);
    }
}

- (void)setupSynth{
    Novocaine *audioManager = [Novocaine audioManager];

    __block NSArray *soundModules = [NSArray arrayWithObjects: nil];

    sampleRate = (float) audioManager.samplingRate;

    JJOcillator *oscillator1 = [JJOcillator ocillatorWithNoteOffset:-0];
    JJOcillator *oscillator2 = [JJOcillator ocillatorWithNoteOffset:-0.0];
    JJOcillator *oscillator3 = [JJOcillator ocillatorWithNoteOffset:-12];

    JJEnvelope *envelope = [JJEnvelope
            envelopeWithAttack:0.05
                         decay:1.0
                  sustainLevel:0.8
                       release:0.2
                         input:[JJMixer mixerWithInputs:[NSArray arrayWithObjects:oscillator1, oscillator2, oscillator3, nil]]];

    noteDelegates = [NSArray arrayWithObjects:oscillator1, oscillator2, oscillator3, envelope, nil];

    JJSoundModule *soundModule = envelope;

    [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)  {

        for (int i=0; i < numFrames; ++i) {

            float theta = [soundModule getOutput] * 0.1;

            for (int iChannel = 0; iChannel < numChannels; ++iChannel)
                data[i * numChannels + iChannel] = theta;
        }
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{

    currentlyPlayingNotes = [NSMutableSet set];
    currentlyPlayingNotesInOrder = [NSMutableArray array];
    noteDelegates = [NSArray array]; // do mutable ??

    [self setupSynth];
    [self setupMIDI];
}


@end