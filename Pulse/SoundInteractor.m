//
//  SoundInteractor.m
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/2/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundInteractor.h"

@interface SoundInteractor ()

@property(nonatomic) SoundFilePlayer *player;
@property BOOL state;
@property BOOL ready;
@property double averagedAmplitude;

@property(nonatomic) AKSequence *volumeUpSequence;
@property(nonatomic) AKSequence *volumeDownSequence;
@property(nonatomic) AKEvent *volumeDownEvent;
@property(nonatomic) AKEvent *volumeUpEvent;
@property(nonatomic) SKAction *volumeUpAction;
@property(nonatomic) SKAction *volumeDownAction;

@property(nonatomic) NSTimer *increaseSizeTimer;

@end


@implementation SoundInteractor

// shape properties
double beginningStrokeGray = 0.05;
double endingStrokeGray = 0.6;
double grayScaleValueOff = 0.2;
double grayScaleValueOn = 1.0;
double alphaValue = 0.4;

// animation timings
double volumeFadeTimeInSeconds = 1.0;
double appearAnimationTimeInSeconds = 2.5;
double ringFadeTimeInSeconds = 0.2;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.lineWidth = 3;
        self.blendMode = SKBlendModeAdd;
        self.glowWidth = 5;
    }
    
    return self;
}


- (void)initializeValues {
    [_player stop];
    [_player.audioAnalyzer stop];
    _player.amplitude.value = 0.0;
    
    _state = NO;
    _ready = NO;
    _averagedAmplitude = 0.0;
    
    self.xScale = 0;
    self.yScale = 0;
    
    self.alpha = 0;
    self.fillColor = [SKColor colorWithWhite:grayScaleValueOff alpha:1.0];
    self.strokeColor = [SKColor colorWithWhite:beginningStrokeGray alpha:1.0];
}

- (void)setPlayer:(SoundFilePlayer *)player {
    _player = player;
    self.name = _player.fileName;
    
    _volumeUpAction = [SKAction customActionWithDuration:volumeFadeTimeInSeconds actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double endValue = (elapsedTime / volumeFadeTimeInSeconds);
        double beginValue = 1 - endValue;
        
        double grayValue = beginValue * grayScaleValueOff + endValue * grayScaleValueOn;
        self.fillColor = [SKColor colorWithWhite:grayValue alpha:1.0];
        
        double amplitudeValue = beginValue * _player.amplitude.minimum + endValue * _player.amplitude.maximum;
        _player.amplitude.value = amplitudeValue;
    }];
    
    _volumeDownAction = [SKAction customActionWithDuration:volumeFadeTimeInSeconds actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double endValue = (elapsedTime / volumeFadeTimeInSeconds);
        double beginValue = 1 - endValue;
        
        double grayValue = beginValue * grayScaleValueOn + endValue * grayScaleValueOff;
        self.fillColor = [SKColor colorWithWhite:grayValue alpha:1.0];
        
        double amplitudeValue = beginValue * _player.amplitude.maximum + endValue * _player.amplitude.minimum;
        _player.amplitude.value = amplitudeValue;
    }];
}

- (void)appearWithGrowAnimation {
    [self runAction:[SKAction scaleTo:1.0 duration:appearAnimationTimeInSeconds] completion:^{
        _ready = YES;
    }];
    
    // fade alpha in, then fade outer ring in
    [self runAction:[SKAction fadeAlphaTo:alphaValue duration:appearAnimationTimeInSeconds - ringFadeTimeInSeconds] completion:^{
        [self runAction:[SKAction customActionWithDuration:ringFadeTimeInSeconds actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            double grayValue = beginningStrokeGray * ((ringFadeTimeInSeconds - elapsedTime) / ringFadeTimeInSeconds) + endingStrokeGray * (elapsedTime / ringFadeTimeInSeconds);
            self.strokeColor = [SKColor colorWithWhite:grayValue alpha:1.0];
        }]];
    }];
}

- (BOOL)isReady {
    return _ready;
}

- (BOOL)getState {
    return _state;
}

- (void)turnOn {
    if (_ready) {
        [self removeActionForKey:@"VolumeDown"];
        [self runAction:[SKAction scaleTo:0.9 duration:0.1] completion:^{
            [self runAction:[SKAction scaleTo:1.0 duration:0.1]];
        }];
        [self runAction:_volumeUpAction withKey:@"VolumeUp"];
        _state = YES;
    }
}

- (void)turnOff {
    [self removeActionForKey:@"VolumeUp"];
    [self runAction:_volumeDownAction withKey:@"VolumeDown"];
    _state = NO;
}

- (void)updateAppearance {
    double bias = 0.84;
    double soundAmplitude = _player.audioAnalyzer.trackedAmplitude.value;
    _averagedAmplitude = bias * _averagedAmplitude + (1 - bias) * soundAmplitude;
    double scaleFactor = 1 + (_averagedAmplitude * _player.scaleValue);
    self.xScale = scaleFactor;
    self.yScale = scaleFactor;
}

@end
