//
//  SoundInteractor.h
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/2/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SoundFilePlayer.h"

@interface SoundInteractor : SKShapeNode

- (void)initializeValues;
// set SoundFilePlayer object
- (void)setPlayer:(SoundFilePlayer *)player;
//
- (void)appearWithGrowAnimation;
- (BOOL)isReady;
// get on/off state
- (BOOL)getState;
// turn on with volume and color fade in
- (void)turnOn;
// turn off with volume and color fade out
- (void)turnOff;
// update size of interactor according to current sound amplitude
- (void)updateAppearance;

@end
