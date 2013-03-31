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
    JJAppDelegate *appDelegate = (__bridge JJAppDelegate *)procRef;

    const MIDIPacket *packet = packetList->packet;
    int message = packet->data[0];
    int note = packet->data[1];
    int velocity = packet->data[2];

    int combined = CombineBytes(packet->data[1], packet->data[2]);
    
    NSNumber *noteNumber = [NSNumber numberWithInt:packet->data[1]];
    
    switch (packet->data[0] & 0xF0) {
        case 0x80: // note off
            [appDelegate.currentlyPlayingNotes removeObject:[NSNumber numberWithInt:note]];

            // ta bort senaste noterna om de inte spelas längre
            while ([appDelegate.currentlyPlayingNotesInOrder count] > 0 && ![appDelegate.currentlyPlayingNotes containsObject:[appDelegate.currentlyPlayingNotesInOrder lastObject]]) {
                [appDelegate.currentlyPlayingNotesInOrder removeLastObject];
            }

            if ([appDelegate.currentlyPlayingNotesInOrder count] > 0) {
                [appDelegate noteTransferTo:[[[appDelegate currentlyPlayingNotesInOrder] lastObject] integerValue]];

            } else {
                [appDelegate noteOff:note];
            }
            break;
        case 0x90: // note on
            if (appDelegate.currentlyPlayingNotes.count == 0){
                [appDelegate noteOn:note withVelocity:velocity];
            }else{
                [appDelegate noteTransferTo:note];
            }
            [appDelegate.currentlyPlayingNotesInOrder addObject:[NSNumber numberWithInt:note]];
            [appDelegate.currentlyPlayingNotes addObject:[NSNumber numberWithInt:note]];
            break;
        case 0xB0: // control change
            // http://www.spectrasonics.net/products/legacy/atmosphere-cclist.php
            [appDelegate controllerChange:packet->data[2] onController:packet->data[1]];
            break;
        case 0xD0: // after touch
            break;
        case 0xE0: // pitch bend
            // get value between -1 and 1, 0 is equlibrium
            [appDelegate pitchBend:(float) (combined / (double) 0x1FFF - 1)];
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

    JJOscillator *oscillator1 = [JJOscillator oscillatorWithNoteOffset:0 oscillatorFunction:JJOscillatorSaw];
    JJOscillator *oscillator2 = [JJOscillator oscillatorWithNoteOffset:0.1 oscillatorFunction:JJOscillatorSaw];
    JJOscillator *oscillator3 = [JJOscillator oscillatorWithNoteOffset:-12 oscillatorFunction:JJOscillatorSaw];

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

    JJDelay *delay = [JJDelay delayWithStrength:0.0 length:0.2 input:envelope];

    JJSoundModule *soundModule = delay;

    midiDelegates = [NSArray arrayWithObjects:oscillator1, oscillator2, oscillator3, envelope, delay, nil];

    [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)  {

        for (int i=0; i < numFrames; ++i) {

            float theta = [soundModule getOutput] * 0.1;

            for (int iChannel = 0; iChannel < numChannels; ++iChannel)
                data[i * numChannels + iChannel] = theta;
        }
    }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{

    self.currentlyPlayingNotes = [NSMutableSet set];
    self.currentlyPlayingNotesInOrder = [NSMutableArray array];
    midiDelegates = [NSArray array];

    [self setupSynth];
    [self setupMIDI];
}


@end