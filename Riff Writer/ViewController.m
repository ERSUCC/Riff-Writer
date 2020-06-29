//
//  ViewController.m
//  Riff Writer
//
//  Created by Isaac Brown on 2/26/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>

#import "ViewController.h"
#import "Riff.h"
#import "RiffViewer.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet UIButton *light;
@property (strong, nonatomic) IBOutlet UIView *saveView;
@property (strong, nonatomic) IBOutlet UIView *countdownView;
@property (weak, nonatomic) IBOutlet UILabel *countdownText;
@property (weak, nonatomic) IBOutlet UITextField *riffName;
@property (weak, nonatomic) IBOutlet UIView *keyboard;
@property (weak, nonatomic) IBOutlet UIStackView *riffView;
@property (strong, nonatomic) IBOutlet UIView *savedRiffView;
@property (weak, nonatomic) IBOutlet UILabel *riffTitle;
@property (weak, nonatomic) IBOutlet UIImageView *riffImage;
@property (weak, nonatomic) IBOutlet UITextField *riffName2;
@property (strong, nonatomic) IBOutlet UIView *renameRiffView;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (strong, nonatomic) IBOutlet UIView *exportView;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _currentRiff = [Riff new];
    _piano = [Piano new];
    _bpm = (NSInteger)120;
    _beats = [NSMutableArray<NSNumber*> new];
    _flashTime = 0.1;
    _lightTimer = [NSTimer timerWithTimeInterval:(float)60 / (int)_bpm target:self selector:@selector(flashMetronome) userInfo:nil repeats:YES];
    _popupAnimationTime = 0.3;
        
    _audioEngine = [AVAudioEngine new];
    _playerNodes = [[NSMutableArray alloc] initWithCapacity:5];
    _audioBuffers = [[NSMutableArray alloc] initWithCapacity:1];
    _currentNode = 0;
    
    for (NSString* fileName in @[@"metronome"]) {
        NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"]];
        AVAudioFile* file = [[AVAudioFile alloc] initForReading:url error:nil];
        AVAudioPCMBuffer* buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:file.processingFormat frameCapacity:(AVAudioFrameCount)file.length];
        
        [file readIntoBuffer:buffer error:nil];
        
        [_audioBuffers addObject:buffer];
    }
    
    for (int i = 0; i < 5; i++) {
        AVAudioPlayerNode* newNode = [AVAudioPlayerNode new];
        
        [_playerNodes addObject:newNode];
        
        [_audioEngine attachNode:newNode];
        [_audioEngine connect:newNode to:_audioEngine.mainMixerNode format:_audioBuffers[0].format];
    }
    
    @try {
        [_audioEngine startAndReturnError:nil];
    } @catch (NSException *exception) {
        NSLog(@"AHHH! ERROR!");
    } @finally {
    }
    
    _recording = NO;
    _playing = NO;
    
    for (UIView* view in _keyboard.subviews) {
        if ([view isKindOfClass:UIButton.class]) {
            [(UIButton*)view setImage:[UIImage imageNamed:@"White Key Highlighted"] forState:UIControlStateHighlighted];
        }
        
        else if (view.tag == 69) {
            for (UIView* view2 in view.subviews) {
                if ([view2 isKindOfClass:UIButton.class]) {
                    [(UIButton*)view2 setImage:[UIImage imageNamed:@"Black Key Highlighted"] forState:UIControlStateHighlighted];
                }
            }
        }
    }
    
    NSManagedObjectContext* context = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"RiffData"];
    
    NSArray* results = [context executeFetchRequest:request error:nil];
    
    if (results != nil) {
        for (NSManagedObject* result in results) {
            NSDictionary* values = [result dictionaryWithValuesForKeys:[[[result entity] attributesByName] allKeys]];
            Riff* riff = [[Riff alloc] initWithString:values[@"notes"]];
            
            RiffViewer* riffViewer = [[RiffViewer alloc] initWithName:values[@"name"] riff:riff image:[UIImage imageWithData:values[@"image"]] height:_riffView.frame.size.height];
                        
            [(UIButton*)riffViewer.subviews[0] addTarget:self action:@selector(viewRiff:) forControlEvents:UIControlEventTouchUpInside];
                
            [_riffView addArrangedSubview:riffViewer];
        }
    }
    
    _saveView.layer.cornerRadius = 10;
    _saveView.center = self.view.center;
    _savedRiffView.layer.cornerRadius = 10;
    _renameRiffView.layer.cornerRadius = 10;
    _renameRiffView.center = self.view.center;
    _countdownView.center = self.view.center;
    _exportView.layer.cornerRadius = 10;
    _exportView.center = self.view.center;
    _light.alpha = 0.2;
}

-(void)tickNoteTimer {
    if (_playing) {
        if (_holdTime == _clickedRiff.riff.notes[_playbackPos].length) {
            if (_playbackPos != 0 || _clickedRiff.riff.notes[_playbackPos].name != R) {
                [_piano noteOff:60 + _clickedRiff.riff.notes[_playbackPos].name];
            }
            
            _playbackPos += 1;
            
            if (_playbackPos >= _clickedRiff.riff.notes.count) {
                _playbackPos = 0;
                _playing = NO;
                
                [_timer invalidate];
            }
            
            else if (_clickedRiff.riff.notes[_playbackPos].name != R) {
                [_piano noteOn:60 + _clickedRiff.riff.notes[_playbackPos].name];
            }
            
            _holdTime = 0;
        }
    }
    
    _holdTime = [NSNumber numberWithInt:[_holdTime intValue] + 1];
}

-(void)tickMetronomeTimer {
    _holdTime = [NSNumber numberWithFloat:[_holdTime floatValue] + 0.01f];
}

-(void)calculateBpm {
    float total = 0;
    
    for (NSNumber* time in _beats) {
        total += [time floatValue];
    }
    
    _bpm = (NSInteger)round((float)60 / (total / (float)_beats.count));
    
    _bpmLabel.text = [NSString stringWithFormat:@"BPM: %d", (int)_bpm];
}

-(void)flashMetronome {
    [UIView animateWithDuration:_flashTime animations:^{
        self->_light.alpha = 1;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self->_flashTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            AVAudioPlayerNode* node = self->_playerNodes[self->_currentNode];
            
            self->_currentNode = (self->_currentNode + 1) % self->_playerNodes.count;
            
            [node scheduleBuffer:self->_audioBuffers[0] completionHandler:nil];
            [node play];
            
            [UIView animateWithDuration:self->_flashTime animations:^{
                self->_light.alpha = 0.2;
            }];
        });
    }];
}

-(void)viewRiff:(UIButton*)sender {
    if (![self.view.subviews containsObject:_savedRiffView]) {
        _clickedRiff = (RiffViewer*)sender.superview;
        
        _riffTitle.text = _clickedRiff.name;
        [_riffImage setImage:_clickedRiff.image];
        ((UIScrollView*)_riffImage.superview).contentSize = _riffImage.image.size;
        
        _savedRiffView.center = [_clickedRiff.superview convertPoint:_clickedRiff.center toView:self.view];
        _savedRiffView.transform = CGAffineTransformMakeScale(1, 1);
        _savedRiffView.transform = CGAffineTransformMakeScale(_clickedRiff.frame.size.width / _savedRiffView.frame.size.width, _clickedRiff.frame.size.height / _savedRiffView.frame.size.height);
        _savedRiffView.layer.cornerRadius = 10;
        
        [self.view addSubview:_savedRiffView];
        
        [UIView animateWithDuration:_popupAnimationTime animations:^{
            self->_savedRiffView.center = self.view.center;
            self->_savedRiffView.transform = CGAffineTransformMakeScale(1, 1);
            self->_savedRiffView.layer.cornerRadius = 10;
        }];
    }
}

-(void)persistRiff:(RiffViewer*)riff {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
        
    NSManagedObject* riffEntity = [NSEntityDescription insertNewObjectForEntityForName:@"RiffData" inManagedObjectContext:context];
    
    [riffEntity setValue:riff.name forKey:@"name"];
    [riffEntity setValue:[NSData dataWithData:UIImagePNGRepresentation(riff.image)] forKey:@"image"];
    [riffEntity setValue:[riff.riff stringRepresentation] forKey:@"notes"];
    
    [context save:nil];
}

-(void)unpersistRiff:(NSString*)name {
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext* context = [appDelegate managedObjectContext];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"RiffData"];
    
    NSArray* results = [context executeFetchRequest:request error:nil];
    
    for (NSManagedObject* result in results) {
        if ([[result dictionaryWithValuesForKeys:[[[result entity] attributesByName] allKeys]][@"name"] isEqual:name]) {
            [context deleteObject:result];
            [context save:nil];
            
            break;
        }
    }
}

-(void)addImageWithName:(NSString*)name x:(int)x y:(int)y {
    if (UIGraphicsGetCurrentContext() != nil) {
        UIImage* image = [UIImage imageNamed:name];
        
        [image drawInRect:CGRectMake(x, y, image.size.width, image.size.height)];
    }
}

- (IBAction)setMetronome:(UIButton*)sender {
    if (!_recording) {
        if ([_holdTime floatValue] > 4) {
            [_beats removeAllObjects];
            
            _holdTime = 0;
        }
        
        else if (_holdTime != 0) {
            [_beats addObject:_holdTime];
            
            [self calculateBpm];
            
            _holdTime = 0;
        }
        
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(tickMetronomeTimer) userInfo:nil repeats:YES];
    }
}

- (IBAction)buttonDown:(UIButton*)sender {
    [_piano noteOn:60 + sender.tag];
    
    if (_recording) {
        if (_beats.count > 0) {
            [_beats removeAllObjects];
        }
        
        [_currentRiff addNote:13 withLength:_holdTime];
                
        _holdTime = 0;
        
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:(float)60 / (int)_bpm / 8 target:self selector:@selector(tickNoteTimer) userInfo:nil repeats:YES];
    }
}

- (IBAction)buttonUp:(UIButton*)sender {
    [_piano noteOff:60 + sender.tag];
    
    if (_recording) {
        [_currentRiff addNote:(int)sender.tag withLength:_holdTime];
        
        _holdTime = 0;
        
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:(float)60 / (int)_bpm / 8 target:self selector:@selector(tickNoteTimer) userInfo:nil repeats:YES];
    }
}

- (IBAction)toggleRecording:(UIButton *)sender {
    if (self.view.subviews.count <= 4) {
        if (_recording) {
            _recording = NO;
            
            _recordLabel.text = @"RECORD";
            
            [_lightTimer invalidate];
            
            _saveView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            
            [self.view addSubview:_saveView];
            
            [UIView animateWithDuration:_popupAnimationTime animations:^{
                self->_saveView.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }
        
        else {
            _recordLabel.text = @"STOP";
            _bpm = [_bpmLabel.text componentsSeparatedByString:@" "][1].integerValue;
            
            [_lightTimer invalidate];
            _lightTimer = [NSTimer scheduledTimerWithTimeInterval:(float)60 / (int)_bpm target:self selector:@selector(flashMetronome) userInfo:nil repeats:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((float)60 / (int)_bpm * NSEC_PER_SEC + _flashTime)), dispatch_get_main_queue(), ^{
                self->_countdownText.text = @"4";
                
                [self.view addSubview:self->_countdownView];
            });
            
            for (int i = 3; i > 0; i--) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((5 - i) * (float)60 / (int)_bpm * NSEC_PER_SEC + _flashTime)), dispatch_get_main_queue(), ^{
                    self->_countdownText.text = [NSString stringWithFormat:@"%d", i];
                });
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * (float)60 / (int)_bpm * NSEC_PER_SEC + _flashTime)), dispatch_get_main_queue(), ^{
                [self->_countdownView removeFromSuperview];
                
                self->_recording = YES;
                
                [self->_timer invalidate];
                self->_timer = [NSTimer scheduledTimerWithTimeInterval:(float)60 / (int)self->_bpm / 8 target:self selector:@selector(tickNoteTimer) userInfo:nil repeats:YES];
            });
        }
    }
}

- (IBAction)saveAlternate:(id)sender {
    [self saveRiff:sender];
}

- (IBAction)saveRiff:(id)sender {
    if (![_riffName.text isEqual:@""]) {
        [_currentRiff quantize:NO];
        
        _currentRiff.bpm = [_bpmLabel.text componentsSeparatedByString:@" "][1].integerValue;
                
        UIImage* templateImage = [UIImage imageNamed:@"Quarter Note"];
        
        CGFloat xStart = [UIImage imageNamed:@"Treble Clef"].size.width + 100;
        CGSize imageSize = CGSizeMake(xStart + (templateImage.size.width + 100) * _currentRiff.notes.count + [_currentRiff.notes indexesOfObjectsPassingTest:^BOOL(Note* note, NSUInteger i, BOOL* stop) {
            return [Note isSharp:note.name];
        }].count * 123 + [_currentRiff numberOfTiedNotes] * 223 + [_currentRiff numberOfCompoundRests] * 200 + 50, (templateImage.size.height / 4) * 8);
        CGFloat space = imageSize.height / 8;
        CGFloat noteHeight = templateImage.size.height;
        CGFloat lineHeight = 6;
        
        UIGraphicsBeginImageContext(imageSize);
        
        [UIColor.whiteColor setFill];
        
        UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
        
        [UIColor.blackColor setFill];
        
        for (CGFloat i = space * 2 - lineHeight / 2; i < space * 6; i += space) {
            UIRectFill(CGRectMake(0, i, imageSize.width, lineHeight));
        }
        
        [self addImageWithName:@"Treble Clef" x:50 y:imageSize.height / 2 - [UIImage imageNamed:@"Treble Clef"].size.height / 2];
        
        int x = xStart;
        int y = 0;
        
        for (Note* note in _currentRiff.notes) {
            if (note.name != R) {
                switch (note.name) {
                    case C:
                        y = space * 7.5 - noteHeight;
                        
                        UIRectFill(CGRectMake(x - 50, 700, templateImage.size.width + 100, lineHeight));
                        
                        break;
                        
                    case Cs:
                        y = space * 7.5 - noteHeight;
                        
                        [self addImageWithName:@"Sharp" x:x y:space * 7 - 140];
                        
                        x += 123;
                        
                        UIRectFill(CGRectMake(x - 50, 700, templateImage.size.width + 100, lineHeight));
                        
                        break;
                        
                    case D:
                        y = space * 7 - noteHeight;
                        
                        break;
                        
                    case Ds:
                        y = space * 7 - noteHeight;
                        
                        [self addImageWithName:@"Sharp" x:x y:space * 6.5 - 140];
                        
                        x += 123;
                        
                        break;
                        
                    case E:
                        y = space * 6.5 - noteHeight;
                        
                        break;
                        
                    case F:
                        y = space * 6 - noteHeight;
                        
                        break;
                        
                    case Fs:
                        y = space * 6 - noteHeight;
                        
                        [self addImageWithName:@"Sharp" x:x y:space * 5.5 - 140];
                        
                        x += 123;
                        
                        break;
                        
                    case G:
                        y = space * 5.5 - noteHeight;
                        
                        break;
                        
                    case Gs:
                        y = space * 5.5 - noteHeight;
                        
                        [self addImageWithName:@"Sharp" x:x y:space * 5 - 140];
                        
                        x += 123;
                        
                        break;
                        
                    case A:
                        y = space * 5 - noteHeight;
                        
                        break;
                        
                    case As:
                        y = space * 5 - noteHeight;
                        
                        [self addImageWithName:@"Sharp" x:x y:space * 5 - 140];
                                              
                        x += 123;
                        
                        break;
                        
                    case B:
                        y = space * 4.5 - noteHeight;
                        
                        break;
                        
                    case C2:
                        y = space * 4 - noteHeight;
                        
                        break;
                        
                    case R:
                        break;
                }
                
                switch ([note.length intValue]) {
                    case 2:
                        [self addImageWithName:@"Sixteenth Note" x:x y:y];
                        
                        break;
                                                                        
                    case 4:
                        [self addImageWithName:@"Eighth Note" x:x y:y];
                        
                        break;
                        
                    case 6:
                        [self addImageWithName:@"Dotted Eighth Note" x:x y:y];
                        
                        break;
                        
                    case 8:
                        [self addImageWithName:@"Quarter Note" x:x y:y];
                        
                        break;
                        
                    case 12:
                        [self addImageWithName:@"Dotted Quarter Note" x:x y:y];
                        
                        break;
                        
                    case 16:
                        [self addImageWithName:@"Half Note" x:x y:y];
                        
                        break;
                        
                    case 20:
                        [self addImageWithName:@"Half Note" x:x y:y];
                        [self addImageWithName:@"Tie" x:x + 50 y:y + templateImage.size.height + 25];
                        
                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Eighth Note" x:x y:y];
                        
                        break;
                        
                    case 24:
                        [self addImageWithName:@"Dotted Half Note" x:x y:y];
                        
                        break;
                        
                    case 28:
                        [self addImageWithName:@"Dotted Half Note" x:x y:y];
                        
                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Eighth Note" x:x y:y];
                        
                        break;
                        
                    case 32:
                        [self addImageWithName:@"Whole Note" x:x y:650 - note.name * 25];
                        
                        break;
                }
            }
            
            else {
                switch ([note.length intValue]) {
                    case 2:
                        [self addImageWithName:@"Sixteenth Rest" x:x y:imageSize.height / 2 - 100];
                        
                        break;
                        
                    case 4:
                        [self addImageWithName:@"Eighth Rest" x:x y:imageSize.height / 2 - 100];
                        
                        break;
                        
                    case 6:
                        [self addImageWithName:@"Eighth Rest" x:x y:imageSize.height / 2 - 100];
                        
                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Sixteenth Rest" x:x y:imageSize.height / 2 - 100];
                        
                        break;
                        
                    case 8:
                        [self addImageWithName:@"Quarter Rest" x:x y:imageSize.height / 2 - 150];
                        
                        break;
                        
                    case 12:
                        [self addImageWithName:@"Quarter Rest" x:x y:imageSize.height / 2 - 150];
                        
                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Eighth Rest" x:x y:imageSize.height / 2 - 100];
                        
                        break;
                        
                    case 16:
                        [self addImageWithName:@"Half Rest" x:x y:imageSize.height / 2 - 50];
                        
                        break;
                        
                    case 20:
                        [self addImageWithName:@"Half Rest" x:x y:imageSize.height / 2 - 50];

                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Eighth Rest" x:x y:imageSize.height / 2 - 100];
                        
                        break;
                        
                    case 24:
                        [self addImageWithName:@"Half Rest" x:x y:imageSize.height / 2 - 50];
                        
                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Quarter Rest" x:x y:imageSize.height / 2 - 150];
                        
                        break;
                        
                    case 28:
                        [self addImageWithName:@"Half Rest" x:x y:imageSize.height / 2 - 50];
                        
                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Quarter Rest" x:x y:imageSize.height / 2 - 150];
                        
                        x += templateImage.size.width + 100;
                        
                        [self addImageWithName:@"Eighth Rest" x:x y:imageSize.height / 2 - 100];
                                                
                        break;
                        
                    case 32:
                        [self addImageWithName:@"Whole Rest" x:x y:imageSize.height / 2];
                        
                        break;
                }
            }
            
            x += templateImage.size.width + 100;
        }
        
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        RiffViewer* riffViewer = [[RiffViewer alloc] initWithName:_riffName.text riff:_currentRiff image:image height:_riffView.frame.size.height];
        
        [(UIButton*)riffViewer.subviews[0] addTarget:self action:@selector(viewRiff:) forControlEvents:UIControlEventTouchUpInside];
        
        [self persistRiff:riffViewer];
        
        [_currentRiff reset];
        
        riffViewer.transform = CGAffineTransformMakeScale(0.01, 0.01);
            
        [_riffView addArrangedSubview:riffViewer];
        
        [UIView animateWithDuration:_popupAnimationTime animations:^{
            self->_saveView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            riffViewer.transform = CGAffineTransformMakeScale(1, 1);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_saveView removeFromSuperview];
        });
    }
}

- (IBAction)cancelSave:(UIButton *)sender {
    [_currentRiff reset];
    
    [UIView animateWithDuration:_popupAnimationTime animations:^{
        self->_saveView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_saveView removeFromSuperview];
    });
}

- (IBAction)deleteRiff:(UIButton *)sender {
    if (![self.view.subviews containsObject:_renameRiffView]) {
        [self unpersistRiff:_clickedRiff.name];
        
        [UIView animateWithDuration:_popupAnimationTime animations:^{
            self->_savedRiffView.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self->_clickedRiff.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self->_savedRiffView.layer.cornerRadius = 10;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_savedRiffView removeFromSuperview];
            [self->_clickedRiff removeFromSuperview];
        });
    }
}

- (IBAction)renameRiff:(UIButton *)sender {
    _renameRiffView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
    [self.view addSubview:_renameRiffView];
    
    [UIView animateWithDuration:_popupAnimationTime animations:^{
        self->_renameRiffView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (IBAction)closeSavedView:(UIButton *)sender {
    if (![self.view.subviews containsObject:_renameRiffView]) {
        [UIView animateWithDuration:_popupAnimationTime animations:^{
            self->_savedRiffView.center = [self->_clickedRiff.superview convertPoint:self->_clickedRiff.center toView:self.view];
            self->_savedRiffView.transform = CGAffineTransformMakeScale(self->_clickedRiff.frame.size.width / self->_savedRiffView.frame.size.width, self->_clickedRiff.frame.size.height / self->_savedRiffView.frame.size.height);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_savedRiffView removeFromSuperview];
        });
    }
}

- (IBAction)cancelRename:(UIButton *)sender {
    [UIView animateWithDuration:_popupAnimationTime animations:^{
        self->_renameRiffView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_renameRiffView removeFromSuperview];
    });
}

- (IBAction)finalizeRenameAlternate:(id)sender {
    [self finalizeRename:sender];
}

- (IBAction)finalizeRename:(id)sender {
    if (![_riffName2.text  isEqual: @""]) {
        [self unpersistRiff:_clickedRiff.name];
        
        _riffTitle.text = [_clickedRiff changeName:_riffName2.text];
        
        [self persistRiff:_clickedRiff];
        
        [UIView animateWithDuration:_popupAnimationTime animations:^{
            self->_renameRiffView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_renameRiffView removeFromSuperview];
        });
    }
}

- (IBAction)startPlayback:(UIButton *)sender {
    if (!_playing) {
        _holdTime = 0;
        _playbackPos = 0;
        _bpm = _clickedRiff.riff.bpm;
        _playing = YES;
        
        if (_clickedRiff.riff.notes[0].name != R) {
            [_piano noteOn:60 + _clickedRiff.riff.notes[0].name];
        }
        
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:(float)60 / (int)_bpm / 8 target:self selector:@selector(tickNoteTimer) userInfo:nil repeats:YES];
    }
}

- (IBAction)stopPlayback:(UIButton *)sender {
    _playbackPos = 0;
    _playing = NO;
    
    [_timer invalidate];
}

- (IBAction)showExportView:(UIButton *)sender {
    if (![self.view.subviews containsObject:_exportView]) {
        _exportView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    
        [self.view addSubview:_exportView];
        
        [UIView animateWithDuration:_popupAnimationTime animations:^{
            self->_exportView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
}

- (IBAction)cancelExport:(UIButton *)sender {
    [UIView animateWithDuration:_popupAnimationTime animations:^{
        self->_exportView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_exportView removeFromSuperview];
    });
}

- (IBAction)exportAudio:(UIButton *)sender {
    AudioFileID recordFile;

    AudioStreamBasicDescription audioFormat;
    
    audioFormat.mSampleRate = 44100;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = sizeof(Float32) * 8;
    audioFormat.mBytesPerPacket = sizeof(Float32);
    audioFormat.mBytesPerFrame = sizeof(Float32);
    
    NSURL* fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[_clickedRiff.name stringByAppendingString:@".wav"]]];
        
    AudioFileCreateWithURL((__bridge CFURLRef)fileURL, kAudioFileWAVEType, &audioFormat, kAudioFileFlags_EraseFile, &recordFile);

    double intervalInSamples = audioFormat.mSampleRate * audioFormat.mChannelsPerFrame;
    
    double totalBeats = 0;
    
    for (Note* note in _clickedRiff.riff.notes) {
        totalBeats += ([note.length doubleValue] / 32) * ((double)_clickedRiff.riff.bpm / 60);
    }
    
    int inNumberFrames = intervalInSamples * totalBeats;
    
    Float32 frameBuffer[inNumberFrames];
    
    int pos = 0;
    
    for (Note* note in _clickedRiff.riff.notes) {
        double frequency = [note getFrequencyValue];
        double currentPhase = 0;
                
        double beats = ([note.length doubleValue] / 32) * ((double)_clickedRiff.riff.bpm / 60);
        int frames = intervalInSamples * beats;
        
        for (int i = pos; i < frames + pos; i++) {
            if (frequency == 0) {
                frameBuffer[i] = 0;
            }
            
            else {
                frameBuffer[i] = tan(sin(currentPhase));
                
                currentPhase += (frequency / audioFormat.mSampleRate) * M_PI * 2;
            }
        }
        
        pos += frames;
    }

    UInt32 bytesToWrite = inNumberFrames * sizeof(uint32_t);
        
    AudioFileWriteBytes(recordFile, false, 0, &bytesToWrite, &frameBuffer);
    AudioFileClose(recordFile);
    
    UIActivityViewController* controller = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
            
    [self presentViewController:controller animated:YES completion:nil];
            
    [UIView animateWithDuration:_popupAnimationTime animations:^{
        self->_exportView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_exportView removeFromSuperview];
    });
}

- (IBAction)exportImage:(UIButton *)sender {
    UIImageWriteToSavedPhotosAlbum(_clickedRiff.image, self, nil, nil);
    
    [UIView animateWithDuration:_popupAnimationTime animations:^{
        self->_exportView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_popupAnimationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_exportView removeFromSuperview];
    });
}


@end
