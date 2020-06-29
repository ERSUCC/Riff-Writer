//
//  Note.h
//  Riff Writer
//
//  Created by Isaac Brown on 2/28/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Note : NSObject

typedef enum noteName {
    C,
    Cs,
    D,
    Ds,
    E,
    F,
    Fs,
    G,
    Gs,
    A,
    As,
    B,
    C2,
    R
} NoteName;

@property NoteName name;
@property NSNumber* length;

-(instancetype)initWithNote:(int)tag length:(NSNumber*)noteLength;
-(double)getFrequencyValue;

+(BOOL)isSharp:(NoteName)note;

@end

NS_ASSUME_NONNULL_END
