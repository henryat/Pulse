//
//  SoundFilePlayer.h
//  Prototype
//
//  Created by Henry Thiemann on 2/28/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "AKFoundation.h"
#import "AKAudioAnalyzer.h"

@interface SoundFilePlayer : AKInstrument

- (instancetype)initWithInfoArray:(NSArray *)info;

@property AKInstrumentProperty *amplitude;
@property double scaleValue;
@property NSString *fileName;
@property (readonly) AKAudio *outputStream;
@property AKAudioAnalyzer *audioAnalyzer;

@end

@interface SoundFilePlayerNote : AKNote

@property AKNoteProperty *speed;
@property AKNoteProperty *pan;

@end