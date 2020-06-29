//
//  Piano.m
//  Riff Writer
//
//  Created by Isaac Brown on 4/17/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import "Piano.h"

@implementation Piano

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        NewAUGraph(&(_audioGraph));
        
        AudioComponentDescription acd;
        
        acd.componentType = kAudioUnitType_Output;
        acd.componentSubType = kAudioUnitSubType_RemoteIO;
        acd.componentManufacturer = kAudioUnitManufacturer_Apple;
        acd.componentFlags = 0;
        acd.componentFlagsMask = 0;
        
        AUGraphAddNode(_audioGraph, &acd, &(_ioNode));
        
        acd.componentType = kAudioUnitType_MusicDevice;
        acd.componentSubType = kAudioUnitSubType_MIDISynth;
        acd.componentManufacturer = kAudioUnitManufacturer_Apple;
        acd.componentFlags = 0;
        acd.componentFlagsMask = 0;
        
        AUGraphAddNode(_audioGraph, &acd, &(_midiSynthNode));
        AUGraphOpen(_audioGraph);
        AUGraphNodeInfo(_audioGraph, _midiSynthNode, nil, &(_synthUnit));
        AUGraphConnectNodeInput(_audioGraph, _midiSynthNode, 0, _ioNode, 0);
        AUGraphInitialize(_audioGraph);
        AUGraphStart(_audioGraph);
        
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"SalC5Light2" withExtension:@"sf2"];
        
        AudioUnitSetProperty(_synthUnit, kMusicDeviceProperty_SoundBankURL, kAudioUnitScope_Global, 0, &(url), sizeof(url));
    }
    
    return self;
}

- (void)noteOn:(UInt8)note {
    UInt32 noteCommand = 0x90 | 0;
    
    MusicDeviceMIDIEvent(_synthUnit, noteCommand, (UInt32)note, 127, 0);
}

- (void)noteOff:(UInt8)note {
    UInt32 noteCommand = 0x80 | 0;
    
    MusicDeviceMIDIEvent(_synthUnit, noteCommand, (UInt32)note, 0, 0);
}

@end
