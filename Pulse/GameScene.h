//
//  GameScene.h
//  LoopLauncher
//

//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AKFoundation.h"
#import "SoundFilePlayer.h"
#import "SoundInteractor.h"

static const uint32_t edgeCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t borderCategory = 0x1 << 4; // 00000000000000000000000000010000

@interface GameScene : SKScene <UIGestureRecognizerDelegate, SKPhysicsContactDelegate>

@property NSMutableArray *soundLoopers;
@property NSMutableArray *soundInteractors;
@property double baseInteractorSize;
@property int loopCounter;
@property NSTimer *loopTimer;
@property NSTimer *clockTimer;
@property UISwipeGestureRecognizer *swipeRecognizer;
@property UIPanGestureRecognizer *panInteractorRecognizer;
@property UITapGestureRecognizer *tapInteractorRecognizer;
@property UILongPressGestureRecognizer *longPressRecognizer;
@property SoundInteractor *draggedInteractor;
@property int secondsRemaining;
@property SKLabelNode *timerLabel;

// smooth animation buffers
@property NSMutableArray *averagedAmplitudes;
@property NSMutableArray *smoothedAmplitudes;

@end
