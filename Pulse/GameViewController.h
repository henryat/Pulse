//
//  GameViewController.h
//  LoopLauncher
//

//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : UIViewController

@property UILabel *goalNumberLabel;
@property UIStepper *goalCounter;
@property UIView *homeView;
@property UIView *gameViewContainer;
@property BOOL shouldHideStatusBar;

@end
