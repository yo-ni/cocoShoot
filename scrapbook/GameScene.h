//
//  GameScene.h
//  scrapbook
//
//  Created by yoni on 15/08/12.
//
//

#import "cocos2d.h"
#import "AppDelegate.h"

@interface GameScene : CCLayerColor

@property (nonatomic, retain) CCSprite *player;
@property (nonatomic, assign) CGPoint touchLocation;

+(CCScene *) scene;

- (void)addTarget;
- (void)bulletToLocation:(ccTime)interval;
- (void)spriteMoveFinished:(id)sender;
- (void)gameLogic:(ccTime)interval;

@end
