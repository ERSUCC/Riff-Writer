//
//  RiffViewer.m
//  Riff Writer
//
//  Created by Isaac Brown on 4/19/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import "RiffViewer.h"

@implementation RiffViewer

-(instancetype)initWithName:(NSString*)name riff:(Riff*)riff image:(UIImage*)image height:(CGFloat)height {
    self = [super init];
    
    _name = name;
    _riff = [Riff new];
    _riff.bpm = riff.bpm;
    
    for (Note* note in riff.notes) {
        [_riff addNoteDirectWithName:note.name length:note.length];
    }
    
    _image = image;
    
    UIButton* button = [UIButton new];
    UILabel* label = [UILabel new];
    
    [self addSubview:button];
    [self addSubview:label];
    
    button.frame = CGRectMake(0, 0, height, height);
    label.frame = CGRectMake(0, 0, height, height);
    
    NSLayoutConstraint* leading = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    NSLayoutConstraint* heightC = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    [button setImage:[UIImage imageNamed:@"Saved Riff"] forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
    [button setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
    [button setImageEdgeInsets:UIEdgeInsetsMake(-13, -13, -13, -13)];
    
    [label setText:name];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [self addConstraints:@[leading, top, width, heightC, centerX, centerY]];
        
    return self;
}

- (NSString*)changeName:(NSString*)name {
    _name = name;
    
    ((UILabel*)self.subviews[1]).text = name;
    
    return name;
}

@end
