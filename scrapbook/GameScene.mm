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
player,
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
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)]) ) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        self.player = [CCSprite spriteWithFile:@"plane_normal.png"
                                          rect:CGRectMake(0, 0, 47.5, 28.5)];
        self.player.scale = 2.0;
        self.player.position = ccp(player.boundingBox.size.width/2, winSize.height/2);
        [self addChild:self.player];
        [self schedule:@selector(gameLogic:) interval:1.0];
        
        self.isTouchEnabled = YES;
        
        //        float angle = 45;
        //        float speed = 50/60; // Move 50 pixels in 60 frames (1 second)
        //        float vx = cos(angle * M_PI / 180) * speed;
        //        float vy = sin(angle * M_PI / 180) * speed;
        //        CGPoint direction = ccp(vx,vy);
        //        player.position = ccpAdd(player.position, direction);
        _enemies = [[NSMutableArray alloc] init];
        _bullets = [[NSMutableArray alloc] init];
	}
	return self;
}


#pragma mark - Scheduled functions

- (void)gameLogic:(ccTime)interval{
    [self addTarget];
}

- (void)bulletToLocation:(ccTime)interval{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *projectile = [CCSprite spriteWithFile:@"missile_final.png"
                                               rect:CGRectMake(0, 0, 16, 2.5)];
    projectile.tag = 2;
    [_bullets addObject:projectile];
    
    projectile.scale = 2.0;
    projectile.position = ccp(self.player.boundingBox.size.width - projectile.boundingBox.size.width/2, self.player.position.y);
    
    int offX = self.touchLocation.x - projectile.position.x;
    int offY = self.touchLocation.y - projectile.position.y;
    //no backward shot
    if (offX <= 0) return;
    
    CGFloat angle = ccpAngleSigned(ccp(1.0, 0.0), ccpSub(self.touchLocation, projectile.position));
    projectile.rotation = -angle*180/M_PI;
    
    [self addChild:projectile];
    
    int realX = winSize.width + (projectile.boundingBox.size.width/2);
    float ratio = (float) offY / (float) offX;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480; // px/sec
    float realMoveDuration = length/velocity;
    
    [projectile runAction:[CCSequence actions:
                           [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
}

#pragma mark - CallBack functions

- (void)addTarget{
    CCSprite *target = [CCSprite spriteWithFile:@"enemy_1_normal.png" rect:CGRectMake(0, 0, 32, 23.5)];
    target.tag = 1;
    [_enemies addObject:target];
    
    int minDuration = 2.0;
    int durationRange = 2.0;
    CGFloat actualDuration = (arc4random()%durationRange) + minDuration;
    
    target.scale = actualDuration;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = target.boundingBox.size.height/2;
    int rangeY = winSize.height - 2*minY;
    CGFloat actualY = (arc4random()%rangeY)+minY;
    
    target.position = ccp(winSize.width + target.boundingBox.size.width/2, actualY);
    [self addChild:target];
    
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-target.boundingBox.size.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

- (void)spriteMoveFinished:(id)sender{
    CCSprite *sprite = (CCSprite *)sender;
    
    if (sprite.tag == 1) {
        [_enemies removeObject:sprite];
    }
    else if(sprite.tag == 2){
        [_bullets removeObject:sprite];
    }
    [self removeChild:sprite cleanup:YES];
}


#pragma mark - Touch handlers

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    self.touchLocation = [[CCDirector sharedDirector] convertToGL:location];
    [self bulletToLocation:0.0];
    [self schedule:@selector(bulletToLocation:) interval:0.1];

}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:touch.view];
    self.touchLocation = [[CCDirector sharedDirector] convertToGL:location];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self unschedule:@selector(bulletToLocation:)];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [_enemies release];
    _enemies = nil;
    [_bullets release];
    _bullets = nil;
	[super dealloc];
}



@end
