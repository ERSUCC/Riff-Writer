//
//  Piano.h
//  Riff Writer
//
//  Created by Isaac Brown on 4/17/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Piano : NSObject

@property AudioUnit synthUnit;
@property AUGraph audioGraph;
@property AUNode midiSynthNode;
@property AUNode ioNode;

-(void)noteOn:(UInt8)note;
-(void)noteOff:(UInt8)note;

@end

NS_ASSUME_NONNULL_END
