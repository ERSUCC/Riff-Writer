//
//  ViewController.h
//  Riff Writer
//
//  Created by Isaac Brown on 2/26/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Riff.h"
#import "Piano.h"
#import "RiffViewer.h"

@interface ViewController : UIViewController

@property Riff* currentRiff;
@property NSNumber* holdTime;
@property NSInteger bpm;
@property NSMutableArray<NSNumber*>* beats;
@property NSTimer* timer;
@property NSTimer* lightTimer;
@property AVAudioEngine* audioEngine;
@property NSMutableArray<AVAudioPlayerNode*>* playerNodes;
@property NSMutableArray<AVAudioPCMBuffer*>* audioBuffers;
@property int currentNode;
@property BOOL recording;
@property Piano* piano;
@property double flashTime;
@property RiffViewer* clickedRiff;
@property double popupAnimationTime;
@property int playbackPos;
@property BOOL playing;

-(void)tickNoteTimer;
-(void)tickMetronomeTimer;
-(void)calculateBpm;
-(void)flashMetronome;
-(void)viewRiff:(UIButton*)sender;
-(void)persistRiff:(RiffViewer*)riff;
-(void)unpersistRiff:(NSString*)name;
-(void)addImageWithName:(NSString*)name x:(int)x y:(int)y;

- (IBAction)setMetronome:(UIButton *)sender;
- (IBAction)buttonDown:(UIButton *)sender;
- (IBAction)buttonUp:(UIButton *)sender;
- (IBAction)toggleRecording:(UIButton *)sender;
- (IBAction)saveAlternate:(id)sender;
- (IBAction)saveRiff:(id)sender;
- (IBAction)cancelSave:(UIButton *)sender;
- (IBAction)deleteRiff:(UIButton *)sender;
- (IBAction)renameRiff:(UIButton *)sender;
- (IBAction)closeSavedView:(UIButton *)sender;
- (IBAction)cancelRename:(UIButton *)sender;
- (IBAction)finalizeRenameAlternate:(id)sender;
- (IBAction)finalizeRename:(id)sender;
- (IBAction)startPlayback:(UIButton *)sender;
- (IBAction)stopPlayback:(UIButton *)sender;
- (IBAction)showExportView:(UIButton *)sender;
- (IBAction)cancelExport:(UIButton *)sender;
- (IBAction)exportAudio:(UIButton *)sender;
- (IBAction)exportImage:(UIButton *)sender;

@end

