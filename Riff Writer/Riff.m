//
//  Riff.m
//  Riff Writer
//
//  Created by Isaac Brown on 2/27/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import "Riff.h"

@implementation Riff

-(instancetype)init {
    self = [super init];
    
    _rawNotes = [NSMutableArray<Note*> new];
    _notes = [NSMutableArray<Note*> new];
    
    return self;
}

-(instancetype)initWithString:(NSString*)string {
    self = [super init];
    
    _rawNotes = [NSMutableArray<Note*> new];
    _notes = [NSMutableArray<Note*> new];
    _bpm = [string componentsSeparatedByString:@"-"][0].integerValue;
    
    for (NSString* note in [[string substringFromIndex:[string rangeOfString:@"-"].location + 1] componentsSeparatedByString:@"-"]) {
        NSArray* sections = [note componentsSeparatedByString:@":"];
        
        [self addNoteDirectWithName:[sections[0] intValue] length:[NSNumber numberWithInt:[sections[1] intValue]]];
    }
    
    return self;
}

-(void)addNote:(int)tag withLength:(NSNumber*)noteLength {
    [_rawNotes addObject:[[Note alloc] initWithNote:tag length:noteLength]];
}

-(void)addNoteDirectWithName:(int)tag length:(NSNumber*)noteLength {
    [_notes addObject:[[Note alloc] initWithNote:tag length:noteLength]];
}

-(void)quantize:(BOOL)swing {
    if (swing) {
        //TODO: Implement swing/triplets
    }
    
    else {
        for (Note* note in _rawNotes) {
            int length = 0;
            
            switch ([note.length intValue]) {
                case 1:
                case 2:
                    if ([_rawNotes indexOfObject:note] != 0 || note.name != R) {
                        length = 2;
                    }
                    
                    break;
                    
                case 3:
                case 4:
                    length = 4;
                    
                    break;
                    
                case 5:
                case 6:
                    length = 6;
                    
                    break;
                    
                case 7:
                case 8:
                case 9:
                case 10:
                    length = 8;
                    
                    break;
                    
                case 11:
                case 12:
                case 13:
                case 14:
                    length = 12;
                    
                    break;
                    
                case 15:
                case 16:
                case 17:
                case 18:
                    length = 16;
                    
                    break;
                    
                case 19:
                case 20:
                case 21:
                case 22:
                    length = 20;
                    
                    break;
                    
                case 23:
                case 24:
                case 25:
                case 26:
                    length = 24;
                    
                    break;
                    
                case 27:
                case 28:
                case 29:
                case 30:
                    length = 28;
                    
                    break;
                    
                case 31:
                case 32:
                    length = 32;
                    
                    break;
            }
            
            if (length != 0) {
                [_notes addObject:[[Note alloc] initWithNote:note.name length:[NSNumber numberWithInt:length]]];
            }
        }
    }
}

-(void)reset {
    _rawNotes = [NSMutableArray<Note*> new];
    _notes = [NSMutableArray<Note*> new];
}

-(NSString*)stringRepresentation {
    NSString* string = [NSString stringWithFormat:@"%lu", (unsigned long)_bpm];
    
    for (Note* note in _notes) {
        string = [string stringByAppendingFormat:@"-%i:%i", note.name, [note.length intValue]];
    }
    
    return string;
}

-(int)numberOfTiedNotes {
    int n = 0;
    
    for (Note* note in _notes) {
        if (note.name != R && ([note.length intValue] == 24 || [note.length intValue] == 28)) {
            n += 1;
        }
    }
    
    return n;
}

-(int)numberOfCompoundRests {
    int n = 0;
    
    for (Note* note in _notes) {
        if (note.name == R && ([note.length intValue] == 6 || [note.length intValue] == 12 || [note.length intValue] == 20 || [note.length intValue] == 24 || [note.length intValue] == 28)) {
            n += 1;
        }
    }
    
    return n;
}

@end
