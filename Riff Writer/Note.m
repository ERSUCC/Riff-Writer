//
//  Note.m
//  Riff Writer
//
//  Created by Isaac Brown on 2/28/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import "Note.h"

@implementation Note

-(instancetype)initWithNote:(int)tag length:(NSNumber *)noteLength {
    self = [super init];
    
    _name = (NoteName)tag;
    _length = noteLength;
    
    return self;
}

-(double)getFrequencyValue {
    switch (_name) {
        case C:
            return 261.63;
        
        case Cs:
            return 277.18;
            
        case D:
            return 293.66;
            
        case Ds:
            return 311.13;
            
        case E:
            return 329.63;
            
        case F:
            return 349.23;
            
        case Fs:
            return 369.99;
            
        case G:
            return 392;
            
        case Gs:
            return 415.30;
            
        case A:
            return 440;
            
        case As:
            return 466.16;
            
        case B:
            return 493.88;
            
        case C2:
            return 523.25;
            
        case R:
            return 0;
    }
}

+(BOOL)isSharp:(NoteName)note {
    switch (note) {
        case C:
        case D:
        case E:
        case F:
        case G:
        case A:
        case B:
        case C2:
        case R:
            return NO;
            
        case Cs:
        case Ds:
        case Fs:
        case Gs:
        case As:
            return YES;
    }
}

@end
