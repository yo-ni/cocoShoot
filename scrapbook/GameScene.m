//
//  GameScene.m
//  scrapbook
//
//  Created by yoni on 15/08/12.
//
//

#import "GameScene.h"

@implementation GameScene

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
        CCSprite *player = [CCSprite spriteWithFile:@"plane_normal.png"
                                               rect:CGRectMake(0, 0, 48, 28.5)];
        player.scale = 2.0;
        player.position = ccp(player.boundingBox.size.width/2, winSize.height/2);
        [self addChild:player];
        [self schedule:@selector(gameLogic:) interval:1.0];
        
        //        float angle = 45;
        //        float speed = 50/60; // Move 50 pixels in 60 frames (1 second)
        //        float vx = cos(angle * M_PI / 180) * speed;
        //        float vy = sin(angle * M_PI / 180) * speed;
        //        CGPoint direction = ccp(vx,vy);
        //        player.position = ccpAdd(player.position, direction);
        
	}
	return self;
}

- (void)addTarget{
    CCSprite *target = [CCSprite spriteWithFile:@"enemy_1_normal.png" rect:CGRectMake(0, 0, 35.5, 26.5)];
    
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
    [self removeChild:sprite cleanup:YES];
}

- (void)gameLogic:(ccTime)interval{
    [self addTarget];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}



@end
