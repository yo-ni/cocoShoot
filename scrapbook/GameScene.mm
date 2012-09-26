//
//  GameScene.m
//  scrapbook
//
//  Created by yoni on 15/08/12.
//
//

#import "GameScene.h"

@implementation GameScene

@synthesize
touchLocation;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
    
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)]) ) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = true;
        _world = new b2World(gravity);
        _world->SetAllowSleeping(doSleep);
        
        //create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        // Create edges around the entire screen
        b2BodyDef borderBodyDef;
        borderBodyDef.position.Set(0,0);
        _borderBody = _world->CreateBody(&borderBodyDef);
        b2EdgeShape edgeShape;
        b2FixtureDef borderFixtureDef;
        borderFixtureDef.shape = &edgeShape;
        edgeShape.Set(b2Vec2(-200/PTM_RATIO,-200/PTM_RATIO), b2Vec2((winSize.width+200)/PTM_RATIO, -200/PTM_RATIO));
        _borderBody->CreateFixture(&borderFixtureDef);
        edgeShape.Set(b2Vec2(-200/PTM_RATIO,-200/PTM_RATIO), b2Vec2(-200/PTM_RATIO, (winSize.height+200)/PTM_RATIO));
        _borderBody->CreateFixture(&borderFixtureDef);
        edgeShape.Set(b2Vec2(-200/PTM_RATIO, (winSize.height+200)/PTM_RATIO), b2Vec2((winSize.width+200)/PTM_RATIO,
                                                                                     (winSize.height+200)/PTM_RATIO));
        _borderBody->CreateFixture(&borderFixtureDef);
        edgeShape.Set(b2Vec2((winSize.width+200)/PTM_RATIO, (winSize.height+200)/PTM_RATIO),
                      b2Vec2((winSize.width+200)/PTM_RATIO, -200/PTM_RATIO));
        _borderBody->CreateFixture(&borderFixtureDef);
        
        
        //create edge to fit the screen
        b2BodyDef borderScreenBodyDef;
        borderScreenBodyDef.position.Set(0,0);
        _borderScreenBody = _world->CreateBody(&borderScreenBodyDef);
        b2FixtureDef borderScreenFixtureDef;
        b2EdgeShape screenEdgeShape;
        borderScreenFixtureDef.shape = &screenEdgeShape;
        screenEdgeShape.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        _borderScreenBody->CreateFixture(&borderScreenFixtureDef);
        screenEdgeShape.Set(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _borderScreenBody->CreateFixture(&borderScreenFixtureDef);
        screenEdgeShape.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,
                                                                        winSize.height/PTM_RATIO));
        _borderScreenBody->CreateFixture(&borderScreenFixtureDef);
        screenEdgeShape.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                            b2Vec2(winSize.width/PTM_RATIO,0));
        _borderScreenBody->CreateFixture(&borderScreenFixtureDef);
        
        
        // Player
        _playerSprite = [CCSprite spriteWithFile:@"plane_normal.png"];
        _playerSprite.scale = 2.0;
        _playerSprite.tag = 1;
        _playerSprite.position = ccp(_playerSprite.boundingBox.size.width/2, winSize.height/2);
        [self addChild:_playerSprite z:100];
        
        b2BodyDef playerBodyDef;
        playerBodyDef.type = b2_dynamicBody;
        playerBodyDef.userData = _playerSprite;
        playerBodyDef.position = b2Vec2(_playerSprite.position.x/PTM_RATIO, _playerSprite.position.y/PTM_RATIO);
        _playerBody = _world->CreateBody(&playerBodyDef);
        _playerFixture = NULL;
        [self setPlayerScale:_playerSprite.scale];
        
        //background
        _bg1 = [CCSprite spriteWithFile:@"bg.png"];
        [_bg1 setPosition:ccp(winSize.width / 2, winSize.height/2)];
        [_bg1.textureAtlas.texture setAntiAliasTexParameters];
        [self addChild:_bg1 z:1];
        _gameVelocity = 1.0;
        
        _bg2 = [CCSprite spriteWithFile:@"bg.png"];
        [_bg2 setPosition:ccp(winSize.width + winSize.width/2, winSize.height/2)];
        [_bg2.textureAtlas.texture setAntiAliasTexParameters];
        [self addChild:_bg2 z:2];
        
        //rescale for iPhone 5 resolution:
        if (_bg1.contentSize.width < winSize.width){
            _bg1.scale = winSize.width/_bg1.contentSize.width;
            _bg2.scale = _bg1.scale;
        }

        
        // Game logic
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(tick:)];
        
        //for debuging
//        
//        _debugDraw = new GLESDebugDraw( PTM_RATIO );
//        _world->SetDebugDraw(_debugDraw);
//        
//        uint32 flags = 0;
//        flags += b2Draw::e_shapeBit;
//        _debugDraw->SetFlags(flags);
        
	}
	return self;
}


#pragma mark - Game logic dan tick

- (void)gameLogic:(ccTime)interval{
    [self addEnnemy];
}

- (void)tick:(ccTime) dt {
    _world->Step(dt, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
    
    // scroll our background
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _bg1.position = ccp( _bg1.position.x - _gameVelocity, _bg1.position.y);
    _bg2.position = ccp( _bg2.position.x - _gameVelocity, _bg1.position.y);
    
    //reset it's position if needed
    if (_bg1.position.x < -winSize.width/2)
    {
        [_bg1 setPosition:ccp(_bg2.position.x + winSize.width, _bg1.position.y)];
    }
    if (_bg2.position.x < -winSize.width/2)
    {
        [_bg2 setPosition:ccp(_bg1.position.x + winSize.width, _bg2.position.y)];
    }
    

    
    //if player is hit
    bool playerHit = NO;
    
    // checking all contact listed by Contact listener
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin();
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        
        if(bodyA == _borderBody){
            if (std::find(toDestroy.begin(), toDestroy.end(), bodyB)
                == toDestroy.end()) {
                toDestroy.push_back(bodyB);
            }
        }
        else if(bodyB == _borderBody){
            if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                == toDestroy.end()) {
                toDestroy.push_back(bodyA);
            }
        }
        else{
            
            if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
                CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
                CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
                
                
                // bullet and ennemy
                if ( (spriteA.tag == 2 && spriteB.tag == 3) || (spriteA.tag == 3 && spriteB.tag == 2) ) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), bodyB)
                        == toDestroy.end()) {
                        toDestroy.push_back(bodyB);
                    }
                    if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                        == toDestroy.end()) {
                        toDestroy.push_back(bodyA);
                    }
                }
                
                // SpriteA = player and spriteB = ennemy
                else if ( spriteA.tag == 1 && spriteB.tag == 3 ) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), bodyB)
                        == toDestroy.end()) {
                        toDestroy.push_back(bodyB);
                        playerHit  =YES;
                    }
                }
                // SpriteA = ennemy and spriteB = player
                else if ( spriteA.tag == 3 && spriteB.tag == 1 ) {
                    if (std::find(toDestroy.begin(), toDestroy.end(), bodyA)
                        == toDestroy.end()) {
                        toDestroy.push_back(bodyA);
                        playerHit = YES;
                    }
                }
            }
        }
    }
    
    if(playerHit){
        if (_playerSprite.scale > 0.5) {
            [self setPlayerScale:_playerSprite.scale-0.5];
        }
        else {
            if (std::find(toDestroy.begin(), toDestroy.end(), _playerBody)
                == toDestroy.end()) {
                toDestroy.push_back(_playerBody);
                [self runAction:[CCSequence actions:
                                 [CCDelayTime actionWithDuration:1],
                                 [CCCallFunc actionWithTarget:self selector:@selector(displayGameOver)],
                                 nil]];

            }
        }
    }

    
    //delete actually all bodies touching the edges
    std::vector<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        _world->DestroyBody(body);
    }
    
    
}


#pragma mark - CallBack functions


- (void)setPlayerScale:(CGFloat)scale{
    _playerSprite.scale = scale;
    //    b2PolygonShape shape;
    //    shape.SetAsBox(2, 2);
    //    b2FixtureDef def;
    //    def.shape = &shape;
    //    _playerBody->CreateFixture(&def);
    //    _playerBody->CreateFixture(&def);
    //    _playerBody->CreateFixture(&def);
    //    b2Fixture *list = _playerBody->GetFixtureList();
    if(NULL != _playerFixture){
        _playerBody->DestroyFixture(_playerFixture);
    }
    b2PolygonShape playerShape;
    
    CGFloat shapeRatio = 2*PTM_RATIO/scale;
    
    int vectCount = 7;
    b2Vec2 verts[] = {
        b2Vec2(47.0f / shapeRatio, 0.5f / shapeRatio),
        b2Vec2(-18.4f / shapeRatio, 28.5f / shapeRatio),
        b2Vec2(-30.9f / shapeRatio, 28.5f / shapeRatio),
        b2Vec2(-46.4f / shapeRatio, 16.0f / shapeRatio),
        b2Vec2(-46.2f / shapeRatio, -14.0f / shapeRatio),
        b2Vec2(-30.9f / shapeRatio, -28.5f / shapeRatio),
        b2Vec2(-16.4f / shapeRatio, -28.5f / shapeRatio)
    };
    
    playerShape.Set(verts, vectCount);
    
    b2FixtureDef playerFixtureDef;
    playerFixtureDef.shape = &playerShape;
    playerFixtureDef.filter.groupIndex = -2;
    
    _playerFixture = _playerBody->CreateFixture(&playerFixtureDef);
    
}

- (void)bulletToLocation:(ccTime)interval{
    CCSprite *bulletSprite = [[CCSprite alloc] initWithFile:@"missile_final.png"];
    bulletSprite.tag = 2;
    
    bulletSprite.scale = 2;
    
    bulletSprite.position = _playerSprite.position;
    
    CGPoint direction = ccpSub(self.touchLocation, bulletSprite.position);
    direction = ccp(direction.x/ccpLength(direction), direction.y/ccpLength(direction));
    CGFloat angle = ccpAngleSigned(ccp(1.0, 0.0), direction);
    bulletSprite.rotation = -1*CC_RADIANS_TO_DEGREES(angle);
    
    [self addChild:bulletSprite z:99];
    
    b2BodyDef bulletBodyDef;
    bulletBodyDef.type = b2_dynamicBody;
    bulletBodyDef.bullet = YES;
    bulletBodyDef.userData = bulletSprite;
    bulletBodyDef.position = b2Vec2(bulletSprite.position.x/PTM_RATIO, bulletSprite.position.y/PTM_RATIO);
    bulletBodyDef.angle = angle;
    b2Body *bulletBody = _world->CreateBody(&bulletBodyDef);
    
    b2PolygonShape bulletShape;
    bulletShape.SetAsBox(bulletSprite.contentSize.width/PTM_RATIO/2*bulletSprite.scale, bulletSprite.contentSize.height/PTM_RATIO/2*bulletSprite.scale);
    
    b2FixtureDef bulletFixtureDef;
    bulletFixtureDef.shape = &bulletShape;
    bulletFixtureDef.isSensor = YES;
    bulletFixtureDef.filter.groupIndex = -2;
    bulletFixtureDef.friction = 10.0f;
    bulletFixtureDef.density = 0.0f;
    bulletFixtureDef.restitution = 0.1f;
    
    bulletBody->CreateFixture(&bulletFixtureDef);
    
    CGFloat forceCoeff = 10.0f;
    b2Vec2 force = b2Vec2(forceCoeff*direction.x, forceCoeff*direction.y);
    bulletBody->ApplyLinearImpulse(force, bulletBodyDef.position);
}


- (void)addEnnemy{
    
    //creates a sprite and add it to the layer
    CCSprite *ennemySprite = [[CCSprite alloc] initWithFile:@"enemy_1_normal.png"];
    ennemySprite.tag = 3;
    
    int minScale = 2.0;
    int scaleRange = 2.0;
    CGFloat actualScale = (arc4random()%scaleRange) + minScale;
    
    ennemySprite.scale = actualScale;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = ennemySprite.boundingBox.size.height/2;
    int rangeY = winSize.height - 2*minY;
    CGFloat actualY = (arc4random()%rangeY)+minY;
    
    ennemySprite.position = ccp(winSize.width + ennemySprite.boundingBox.size.width/2, actualY);
    [self addChild:ennemySprite z:100];
    
    b2BodyDef ennemyBodyDef;
    ennemyBodyDef.type = b2_dynamicBody;
    ennemyBodyDef.userData = ennemySprite;
    ennemyBodyDef.position = b2Vec2(ennemySprite.position.x/PTM_RATIO, ennemySprite.position.y/PTM_RATIO);
    b2Body *ennemyBody = _world->CreateBody(&ennemyBodyDef);
    
    b2PolygonShape ennemyShape;
    //    ennemyShape.SetAsBox(ennemySprite.boundingBox.size.width/PTM_RATIO/2, ennemySprite.boundingBox.size.height/PTM_RATIO/2);
    
    CGFloat shapeRatio = 2*PTM_RATIO/ennemySprite.scale;
    int vertCount = 7;
    b2Vec2 verts[] = {
        b2Vec2(10.3f / shapeRatio, 23.2f / shapeRatio),
        b2Vec2(-30.7f / shapeRatio, -0.2f / shapeRatio),
        b2Vec2(9.7f / shapeRatio, -22.4f / shapeRatio),
        b2Vec2(17.3f / shapeRatio, -22.3f / shapeRatio),
        b2Vec2(31.5f / shapeRatio, -12.7f / shapeRatio),
        b2Vec2(31.3f / shapeRatio, 13.1f / shapeRatio),
        b2Vec2(17.1f / shapeRatio, 23.0f / shapeRatio)
    };
    
    
    ennemyShape.Set(verts, vertCount);
    
    
    b2FixtureDef ennemyFixtureDef;
    ennemyFixtureDef.shape = &ennemyShape;
    ennemyFixtureDef.isSensor = YES;
    ennemyFixtureDef.filter.groupIndex = -3;
    ennemyFixtureDef.friction = 10.0f;
    ennemyFixtureDef.density = 0.0f;
    ennemyFixtureDef.restitution = 0.1f;
    
    ennemyBody->CreateFixture(&ennemyFixtureDef);
    
    b2Vec2 force = b2Vec2(-20/actualScale*_gameVelocity, 0);
    ennemyBody->ApplyLinearImpulse(force, ennemyBodyDef.position);
}


- (void)displayGameOver {
    GameOverScene *gameOverScene = [GameOverScene node];
    [gameOverScene.layer.label setString:@"You Lose :("];
    [[CCDirector sharedDirector] replaceScene:gameOverScene];	
}


#pragma mark - Touch handlers

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    self.touchLocation = [[CCDirector sharedDirector] convertToGL:location];
    [self bulletToLocation:0.0];
    [self schedule:@selector(bulletToLocation:) interval:0.2];
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    self.touchLocation = [[CCDirector sharedDirector] convertToGL:location];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self unschedule:@selector(bulletToLocation:)];
}


#pragma mark - Accelerometer handler

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    //    NSLog(@"%f  %f", acceleration.y, -acceleration.x);
    b2Vec2 force = b2Vec2(150*acceleration.y, -150*(acceleration.x-0.5));
    _playerBody->ApplyForceToCenter(force);
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	delete _world;
    delete _contactListener;
    delete _debugDraw;
	_world = NULL;
    _borderBody = NULL;
    _borderScreenBody = NULL;
    _playerBody = NULL;
    _playerFixture = NULL;
    _playerSprite = NULL;
	[super dealloc];
}


#pragma mark - Debug methods

//-(void) draw
//{
//    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
//    
//	glDisable(GL_TEXTURE_2D);
//    //	glDisableClientState(GL_COLOR_ARRAY);
//    //	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//    
//	_world->DrawDebugData();
//    
//	glEnable(GL_TEXTURE_2D);
//    //	glEnableClientState(GL_COLOR_ARRAY);
//    //	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//}



@end
