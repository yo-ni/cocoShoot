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

+(CCScene *) scene;

- (void)addTarget;
- (void)spriteMoveFinished:(id)sender;
- (void)gameLogic:(ccTime)interval;

@end
