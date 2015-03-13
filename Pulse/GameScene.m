//
//  GameScene.m
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/1/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()

@property(nonatomic) AKOrchestra *orchestra;

@end

@implementation GameScene

double introduceLoopTimerDuration = 7.0;

-(void)didMoveToView:(SKView *)view {
    
    /* Setup your scene here */
    self.backgroundColor = [SKColor colorWithRed:10.0/255 green:55.0/255 blue:70.0/255 alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsWorld.contactDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupScene) name:@"SetupScene" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetScene) name:@"ResetScene" object:nil];
    
    // create all the loopers
    [self createSoundLoopers];
    [self createInteractors];
    //    [self bringInNewLoop];
    _swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goHome)];
    _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_swipeRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(haltCell:)];
    panRecognizer.delegate = self;
    tapRecognizer.delegate = self;
    longPressRecognizer.delegate = self;
    longPressRecognizer.minimumPressDuration = .2;
    [[self view] addGestureRecognizer:panRecognizer];
    [[self view] addGestureRecognizer:tapRecognizer];
    [[self view] addGestureRecognizer:longPressRecognizer];
    
    _draggedInteractor = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return YES;
    else if([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return YES;
    return NO;
}

- (void)bringInNewLoop {
    if (_loopCounter == 0) {
        for(int i = 0; i <= 3; i++){
            [self addNextInteractor];
        }
    } else {
        [self addNextInteractor];
    }
}

-(void)addNextInteractor
{
    SoundInteractor *interactor = _soundInteractors[_loopCounter];
    [self addChild:interactor];
    [interactor appearWithGrowAnimation];
    [self moveInteractor:interactor];
    
    _loopCounter ++;
    
    if (_loopCounter > _soundInteractors.count - 1) {
        [_timer invalidate];
        return;
    }
}

-(void)moveInteractor:(SoundInteractor *)interactor
{
    CGVector velocityVector = CGVectorMake((CGFloat) random()/(CGFloat) RAND_MAX * 50, (CGFloat) random()/(CGFloat) RAND_MAX * 50);
    if(rand() > RAND_MAX/2) velocityVector.dx = -velocityVector.dx;
    if(rand() > RAND_MAX/2) velocityVector.dy = -velocityVector.dy;
    [interactor.physicsBody setVelocity:velocityVector];
}

-(void)willMoveFromView:(SKView *)view{
    [self.view removeGestureRecognizer:_swipeRecognizer];
}

// create audio looper and interaction object for each sound file
-(void)createSoundLoopers {
    
    // load file names from plist into array
    NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:@"relaxation" ofType:@"plist"];
    NSMutableArray *soundFiles = [[NSMutableArray alloc] initWithContentsOfFile:pathToPlist];
    
    _soundLoopers = [[NSMutableArray alloc] init];
    _soundInteractors = [[NSMutableArray alloc] init];
    
    // create sound file player for each file
    for (NSArray *soundFile in soundFiles) {
        SoundFilePlayer *player = [[SoundFilePlayer alloc] initWithInfoArray:soundFile];
        [_soundLoopers addObject:player];
    }
}

-(void)createInteractors {
    
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat rectSize = (windowWidth * 0.75) / 4.0;
    
    _baseInteractorSize = rectSize * .7;
    _loopCounter = 0;
    
    for (int i = 0; i < _soundLoopers.count; i++) {
        
        CGFloat x = (random()/(CGFloat)RAND_MAX) * windowWidth;
        CGFloat y = (random()/(CGFloat)RAND_MAX) * windowHeight;
        if(x > windowWidth - _baseInteractorSize/2) x -= _baseInteractorSize/2;
        if(x <  _baseInteractorSize/2) x += _baseInteractorSize/2;
        if(y > windowHeight - _baseInteractorSize/2) y -= _baseInteractorSize/2;
        if(y < _baseInteractorSize/2) y += _baseInteractorSize/2;
        
        SoundInteractor *interactor = [SoundInteractor shapeNodeWithCircleOfRadius:_baseInteractorSize/2];
        interactor.position = CGPointMake(x, y);
        
        SoundFilePlayer *player = [_soundLoopers objectAtIndex:i];
        [interactor setPlayer:player];
        
        [_soundInteractors addObject:interactor];
        
        [interactor setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:interactor.frame.size.width/2]];
        interactor.physicsBody.affectedByGravity = NO;
        interactor.physicsBody.allowsRotation = YES;
        interactor.physicsBody.dynamic = YES;
        interactor.physicsBody.friction = 0.0f;
        interactor.physicsBody.restitution = 1.0f;
        interactor.physicsBody.linearDamping = 0.0f;
        interactor.physicsBody.angularDamping = 0.0f;
        
        interactor.physicsBody.categoryBitMask = ballCategory;
        interactor.physicsBody.collisionBitMask = ballCategory | edgeCategory;
        interactor.physicsBody.contactTestBitMask = edgeCategory | ballCategory;
        
        [interactor initializeValues];
    }
}

- (void)setupScene {
    for (SoundFilePlayer *player in _soundLoopers) {
        [AKOrchestra addInstrument:player];
        [AKOrchestra addInstrument:player.audioAnalyzer];
    }
    [AKOrchestra start];
    for (SoundFilePlayer *player in _soundLoopers) {
        [player play];
        [player.audioAnalyzer play];
    }
    
    // randomize order
    NSUInteger count = [_soundInteractors count];
    for (int i = 0; i < count; ++i) {
        NSUInteger nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [_soundInteractors exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:introduceLoopTimerDuration target:self selector:@selector(bringInNewLoop) userInfo:nil repeats:YES];
    [_timer fire];
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // THIS IS NECESSARY TO DEAL WITH LAME BUG IN APPLE CODE THAT IGNORES IMPULSES LESS THAN 20 OR SOME BS LIKE THAT
    SKPhysicsBody *bodyA = contact.bodyA;
    SKPhysicsBody *bodyB = contact.bodyB;
    CGVector contactNormal = contact.contactNormal;
    CGFloat contactImpulse = contact.collisionImpulse;
    
    if((bodyA.categoryBitMask == edgeCategory && bodyB.categoryBitMask == ballCategory)){
        if(contactImpulse < 15 && contactImpulse > 0){
            if(contactNormal.dx == -1 && contactNormal.dy == 0){ // right wall
                //                NSLog(@"rightWall");
                
                [bodyB applyImpulse:CGVectorMake(-contactImpulse, 0)];
                if(abs(bodyB.velocity.dx) + abs(bodyB.velocity.dy) < 25){
                    bodyB.velocity = CGVectorMake(bodyB.velocity.dx * 1.5, bodyB.velocity.dy * 1.5);
                }
                if(abs(bodyB.velocity.dx) + abs(bodyB.velocity.dy) < 15){
                    bodyB.velocity = CGVectorMake(bodyB.velocity.dx * 3, bodyB.velocity.dy * 3);
                }
            } else if(contactNormal.dx == 1 && contactNormal.dy == 0){ // left wall
                //                NSLog(@"leftWall");
                [bodyB applyImpulse:CGVectorMake(contactImpulse, 0)];
            } else if(contactNormal.dx == 0 && contactNormal.dy == -1){ // top wall
                [bodyB applyImpulse:CGVectorMake(0, -contactImpulse)];
                //                NSLog(@"topWall");
            } else if(contactNormal.dx == 0 && contactNormal.dy == 1){ // bottom wall
                //                NSLog(@"bottomWall");
                [bodyB applyImpulse:CGVectorMake(0, contactImpulse)];
            }
        }
    } else if((bodyA.categoryBitMask == ballCategory && bodyB.categoryBitMask == ballCategory)){
        if((SoundInteractor *)bodyA.node == _draggedInteractor){
            bodyA.velocity = CGVectorMake(0, 0);
        } else if((SoundInteractor *)bodyB.node == _draggedInteractor){
            bodyB.velocity = CGVectorMake(0, 0);
        }
        if(contactImpulse < 15){
            bodyB.velocity = CGVectorMake(bodyB.velocity.dx * 1.05, bodyB.velocity.dy * 1.05);
            bodyA.velocity = CGVectorMake(bodyA.velocity.dx * 1.05, bodyA.velocity.dy * 1.05);
        }
    }
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    if ([touchedNode isKindOfClass:[SoundInteractor class]]) {
        SoundInteractor *interactor = (SoundInteractor *)touchedNode;
        if ([interactor getState] == NO) {
            [interactor turnOn];
        } else {
            [interactor turnOff];
        }
    }
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if(_draggedInteractor) return;
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        [self setPanNodeForTouch:touchLocation];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        [self panForLocation:touchLocation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_draggedInteractor) {
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            _draggedInteractor.physicsBody.velocity = CGVectorMake(velocity.x, -velocity.y);
            double totalVelocity = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y));
            if(totalVelocity > 200){
                double scale = [self chooseScale:totalVelocity];
                [UIView animateWithDuration:1 animations:^{
                    _draggedInteractor.physicsBody.velocity = CGVectorMake(velocity.x/scale, -velocity.y/scale);
                }];
            }
            
            _draggedInteractor = nil;
        }
        
    }
}

- (void)setPanNodeForTouch:(CGPoint)location
{
    SKNode *touchedNode = [self nodeAtPoint:location];
    
    if ([touchedNode isKindOfClass:[SoundInteractor class]]) {
        SoundInteractor *interactor = (SoundInteractor *)touchedNode;
        _draggedInteractor = interactor;
        _draggedInteractor.physicsBody.velocity = CGVectorMake(0, 0);
    }
}

- (void)panForLocation:(CGPoint)location{
    if(!_draggedInteractor) return;
    [_draggedInteractor setPosition:location];
}

- (double)chooseScale:(double)totalVelocity{
    if(totalVelocity < 150)
        return 1.2;
    else if(totalVelocity < 300)
        return 1.5;
    else if(totalVelocity < 500)
        return 2;
    else if(totalVelocity < 1000)
        return 3;
    else if(totalVelocity < 2000)
        return 5;
    return 20;
}

- (void)haltCell:(UILongPressGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        SKNode *touchedNode = [self nodeAtPoint:touchLocation];
        
        if ([touchedNode isKindOfClass:[SoundInteractor class]]) {
            SoundInteractor *interactor = (SoundInteractor *)touchedNode;
            interactor.physicsBody.velocity = CGVectorMake(0, 0);
        }
    }
}

- (void)goHome
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GoHome" object:nil];
    for(SoundInteractor *interactor in _soundInteractors){
        //        [interactor turnOff];
        interactor.physicsBody.velocity = CGVectorMake(0, 0);
    }
    [_timer invalidate];
    _draggedInteractor = nil;
}

- (void)resetScene
{
    _loopCounter = 0;
    [self removeAllChildren];
    for (SoundInteractor *interactor in _soundInteractors) {
        [interactor initializeValues];
    }
    [AKOrchestra reset];
    //    [self bringInNewLoop];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    for (SoundInteractor *interactor in _soundInteractors) {
        if ([interactor isReady]) {
            [interactor updateAppearance];
        }
    }
}

@end
