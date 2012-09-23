//
//  GameScene.h
//  scrapbook
//
//  Created by yoni on 15/08/12.
//
//

#import "cocos2d.h"
#import "AppDelegate.h"
#import "Box2D.h"
#import "MyContactListener.h"
#import "GLES-Render.h"
#import "GameOverScene.h"

//#import "BoxDebugLayer.h"


#define PTM_RATIO 32.0

@interface GameScene : CCLayerColor{
    b2World *_world;
    b2Body *_borderBody;
    b2Body *_borderScreenBody;
    b2Body *_playerBody;
    b2Fixture *_playerFixture;
    CCSprite *_playerSprite;
    CCSprite *_bg1;
    CCSprite *_bg2;
    CGFloat _gameVelocity;
    MyContactListener *_contactListener;
    GLESDebugDraw *_debugDraw;

}

@property (nonatomic, assign) CGPoint touchLocation;

+(CCScene *) scene;

- (void)addEnnemy;
- (void)bulletToLocation:(ccTime)interval;
- (void)gameLogic:(ccTime)interval;

@end
