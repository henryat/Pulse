//
//  SoundFilePlayer.m
//  Prototype
//
//  Created by Henry Thiemann on 2/28/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundFilePlayer.h"

@implementation SoundFilePlayer

- (instancetype)initWithInfoArray:(NSArray *)info
{
    self = [super init];
    if (self) {
        SoundFilePlayerNote *note = [[SoundFilePlayerNote alloc] init];
        [self addNoteProperty:note.speed];
        [self addNoteProperty:note.pan];
        _fileName = info[0];
        _scaleValue = ((NSNumber *) info[2]).doubleValue;
        
        NSString *pathToSoundFile;
        pathToSoundFile = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"aiff"];
        
        AKSoundFile *soundFile;
        soundFile = [[AKSoundFile alloc] initWithFilename: pathToSoundFile];
        [self addFunctionTable:soundFile];
        
        AKStereoSoundFileLooper *looper = [[AKStereoSoundFileLooper alloc] initWithSoundFile:soundFile];
        float maximumAmplitude = ((NSNumber *) info[1]).doubleValue;
        _amplitude = [[AKInstrumentProperty alloc] initWithValue:0.0 minimum:0.0 maximum:maximumAmplitude];
        [self addProperty:_amplitude];
        looper.amplitude = _amplitude;
        [self connect:looper];
        
        AKAudioOutput *audioOutput = [[AKAudioOutput alloc] initWithAudioSource:looper];
        [self connect:audioOutput];
        // Output to global effects processing or analysis
        AKMix *mono = [[AKMix alloc] initWithInput1:looper.leftOutput input2:looper.rightOutput balance:akp(0.5)];
        [self connect:mono];
        _outputStream = [AKAudio globalParameter];
        [self assignOutput:_outputStream to:mono];
        
        // THIS IS WHERE WE WOULD HOOK UP AUDIOANALYZER TO SOURCE
        AKAudioAnalyzer *audioAnalyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:_outputStream];
        self.audioAnalyzer = audioAnalyzer;
    }
    
    return self;
}

@end


// -----------------------------------------------------------------------------
#  pragma mark - Instrument Note
// -----------------------------------------------------------------------------

@implementation SoundFilePlayerNote

- (instancetype)init;
{
    self = [super init];
    if(self) {
        _speed = [[AKNoteProperty alloc] initWithValue:1.0
                                               minimum:1.0
                                               maximum:6.0];
        [self addProperty:_speed];
        
        _pan = [[AKNoteProperty alloc] initWithValue:0.0
                                             minimum:-1.0
                                             maximum:1.0];
        [self addProperty:_pan];
        
        
        self.duration.value = 4.0;
    }
    return self;
}


@end
