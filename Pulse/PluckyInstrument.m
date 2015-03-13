//
//  PluckyInstrument.m
//  Space Cannon
//
//  Created by Aurelius Prochazka and Nick Arner on 11/29/14.
//  Copyright (c) 2014 AudioKit. All rights reserved.
//

#import "PluckyInstrument.h"

@implementation PluckyInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        Pluck *note = [[Pluck alloc] init];
        [self addNoteProperty:note.frequency];
        [self addNoteProperty:note.amplitude];
        [self addNoteProperty:note.pan];
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"marmstk1" ofType:@"wav"];
        
        AKSoundFile *soundFile = [[AKSoundFile alloc] initWithFilename:file];
        [self addFunctionTable:soundFile];
        
        AKMonoSoundFileLooper *impulse = [AKMonoSoundFileLooper looperWithSoundFile:soundFile];
        impulse.loopMode = akp(0);
        [self connect:impulse];
        
        // Instrument Definition
        AKPluckedString *pluck = [AKPluckedString pluckWithExcitationSignal:impulse];
        pluck.frequency = note.frequency;
        [pluck setOptionalAmplitude:note.amplitude];
        [self connect:pluck];
        
        AKLowPassFilter *filter = [[AKLowPassFilter alloc] initWithAudioSource:pluck];
        [filter setOptionalHalfPowerPoint:akp(500)];
        [self connect:filter];
        
        AKReverb *reverb = [[AKReverb alloc] initWithInput:filter];
        reverb.feedback = akp(0.7);
        [self connect:reverb];
        
        // Output to global effects processing
//        _auxilliaryOutput = [AKStereoAudio globalParameter];
//        [self assignOutput:_auxilliaryOutput to:panner];
        
        AKAudioOutput *audioOutput = [[AKAudioOutput alloc] initWithAudioSource:reverb];
        [self connect:audioOutput];
    }
    return self;
}
@end


// -----------------------------------------------------------------------------
#  pragma mark - PluckyInstrument Note
// -----------------------------------------------------------------------------


@implementation Pluck

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [[AKNoteProperty alloc] initWithValue:440 minimum:300 maximum:1200];
        [self addProperty:_frequency];
        
        _amplitude = [[AKNoteProperty alloc] initWithValue:0.5 minimum:0.0 maximum:1.0];
        [self addProperty:_amplitude];
        
        _pan = [[AKNoteProperty alloc] initWithValue:0.0 minimum:-1 maximum:1];
        [self addProperty:_pan];
        
        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency pan:(float)pan amplitude:(float)amplitude;
{
    self = [self init];
    if (self) {
        _frequency.value = frequency;
        _pan.value = pan;
        _amplitude.value = amplitude;
    }
    return self;
}

@end
