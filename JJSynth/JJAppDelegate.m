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
#import "JJOscillator.h"
#import "JJMixer.h"
#import "JJEnvelope.h"
#import "JJDelay.h"
#import "JJFilter.h"

#define AMP (0.3)

@implementation JJAppDelegate

@synthesize currentlyPlayingNotesInOrder;
@synthesize currentlyPlayingNotes;

@synthesize midiDelegates;

- (void)noteOn:(int)note withVelocity: (int)velocity{
    for (id<JJMidiDelegate> midiDelegate in midiDelegates){
        [midiDelegate noteOn:note withVelocity:velocity];
    }
}
- (void)noteOff:(int) note{
    for (id<JJMidiDelegate> midiDelegate in midiDelegates){
        [midiDelegate noteOff:note];
    }
}
- (void)noteTransferTo:(int) note{
    for (id<JJMidiDelegate> midiDelegate in midiDelegates){
        [midiDelegate noteTransferTo:note];
    }
}
- (void)pitchBend:(float)bend {
    for (id<JJMidiDelegate> midiDelegate in midiDelegates){
        [midiDelegate pitchBend:bend];
    }
}
- (void)controllerChange:(float)change onController:(int)controller {
    for (id<JJMidiDelegate> midiDelegate in midiDelegates){
        [midiDelegate controllerChange:change onController:controller];
    }
}

static inline unsigned short CombineBytes(unsigned char First, unsigned char Second) {
    unsigned short combined = (unsigned short)Second;
    combined <<= 7;
    combined |= (unsigned short)First;
    return combined;
}

void midiInputCallback (const MIDIPacketList *packetList, void *procRef, void *srcRef)
{
    JJAppDelegate *delegate = (__bridge JJAppDelegate *)procRef;

    const MIDIPacket *packet = packetList->packet;
    int note = packet->data[1];
    int velocity = packet->data[2];

    int combined = CombineBytes(packet->data[1], packet->data[2]);
    
    switch (packet->data[0] & 0xF0) {
        case 0x80: // note off
            [delegate.currentlyPlayingNotes removeObject:[NSNumber numberWithInt:note]];

            // remove last note in list if it's not currently playing
            while ([delegate.currentlyPlayingNotesInOrder count] > 0 && ![delegate.currentlyPlayingNotes containsObject:[delegate.currentlyPlayingNotesInOrder lastObject]]) {
                [delegate.currentlyPlayingNotesInOrder removeLastObject];
            }

            // we have notes still playing
            if ([delegate.currentlyPlayingNotesInOrder count] > 0) {
                [delegate noteOn:(int)[[[delegate currentlyPlayingNotesInOrder] lastObject] integerValue] withVelocity:1];
            } else {
                [delegate noteOff:note];
            }
            break;
        case 0x90: // note on
            [delegate noteOn:note withVelocity:velocity];
            [delegate.currentlyPlayingNotesInOrder addObject:[NSNumber numberWithInt:note]];
            [delegate.currentlyPlayingNotes addObject:[NSNumber numberWithInt:note]];
            break;
        case 0xB0: // control change
            // http://www.spectrasonics.net/products/legacy/atmosphere-cclist.php
            [delegate controllerChange:packet->data[2] onController:packet->data[1]];
            break;
        case 0xD0: // after touch
            break;
        case 0xE0: // pitch bend
            // get value between -1 and 1, 0 is equlibrium
            [delegate pitchBend:(float) (combined / (double) 0x1FFF - 1)];
            break;
        case 0xF0: // sys stuff, ignore
        default:
            //NSLog(@"%3d %3d %3d", message, note, velocity);
            break;
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

    sampleRate = (float) audioManager.samplingRate;

    JJOscillator *oscillator1 = [JJOscillator oscillatorWithNoteOffset:0 andWaveForm:&sawOsc];
    JJOscillator *oscillator2 = [JJOscillator oscillatorWithNoteOffset:0.1 andWaveForm:&sawOsc];
    JJOscillator *oscillator3 = [JJOscillator oscillatorWithNoteOffset:-12 andWaveForm:&sineOsc];

    JJMixer *oscillatorMixer = [JJMixer mixerWithInputs:[NSArray arrayWithObjects:oscillator1, oscillator2, oscillator3, nil]];
    
    JJFilter *filter = [JJFilter
              filterWithCutoff:127
                     resonance:0
                         input:oscillatorMixer];

    JJEnvelope *envelope = [JJEnvelope
            envelopeWithAttack:0.05
                         decay:1.0
                  sustainLevel:0.8
                       release:0.1
                         input:filter];

    JJDelay *delay = [JJDelay
            delayWithStrength:0.4
                       length:0.2
                        input:envelope];

    JJSoundModule *lastSoundModuleInChain;
    lastSoundModuleInChain = delay;

    midiDelegates = [NSArray arrayWithObjects:oscillator1, oscillator2, oscillator3, filter, envelope, delay, oscillatorMixer, nil];

    [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)  {

        for (int i=0; i < numFrames; ++i) {

            float theta = [lastSoundModuleInChain getOutput] * AMP;

            for (int iChannel = 0; iChannel < numChannels; ++iChannel)
                data[i * numChannels + iChannel] = theta;
        }
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{

    currentlyPlayingNotes = [NSMutableSet set];
    currentlyPlayingNotesInOrder = [NSMutableArray array];
    midiDelegates = [NSArray array]; // do mutable ??

    [self setupSynth];
    [self setupMIDI];
}


@end