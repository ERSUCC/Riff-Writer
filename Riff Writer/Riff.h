//
//  Riff.h
//  Riff Writer
//
//  Created by Isaac Brown on 2/27/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Riff : NSObject

@property NSMutableArray<Note*>* rawNotes;
@property NSMutableArray<Note*>* notes;
@property NSInteger bpm;

-(instancetype)initWithString:(NSString*)string;
-(void)addNote:(int)tag withLength:(NSNumber*)noteLength;
-(void)addNoteDirectWithName:(int)tag length:(NSNumber*)noteLength;
-(void)quantize:(BOOL)swing;
-(void)reset;
-(NSString*)stringRepresentation;
-(int)numberOfTiedNotes;
-(int)numberOfCompoundRests;

@end

NS_ASSUME_NONNULL_END
