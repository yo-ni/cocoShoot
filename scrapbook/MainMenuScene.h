//
//  MainMenuScene.h
//  scrapbook
//
//  Created by yoni on 07/08/12.
//
//

#import <GameKit/GameKit.h>

#import "AppDelegate.h"
#import "cocos2d.h"
#import "GameScene.h"


@interface MainMenuScene : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>{
    
}

+ (CCScene *)scene;

@end
