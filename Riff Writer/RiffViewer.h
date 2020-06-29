//
//  RiffViewer.h
//  Riff Writer
//
//  Created by Isaac Brown on 4/19/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Riff.h"

NS_ASSUME_NONNULL_BEGIN

@interface RiffViewer : UIView

@property NSString* name;
@property Riff* riff;
@property UIImage* image;

-(instancetype)initWithName:(NSString*)name riff:(Riff*)riff image:(UIImage*)image height:(CGFloat)height;
-(NSString*)changeName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
