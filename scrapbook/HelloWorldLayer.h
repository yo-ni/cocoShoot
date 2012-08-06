//
//  HelloWorldLayer.h
//  scrapbook
//
//  Created by yoni on 05/08/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void)addTarget;
- (void)spriteMoveFinished:(id)sender;
- (void)gameLogic:(ccTime)interval;

@end
