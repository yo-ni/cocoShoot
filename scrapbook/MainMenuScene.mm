//
//  MainMenuScene.m
//  scrapbook
//
//  Created by yoni on 07/08/12.
//
//

#import "MainMenuScene.h"

@implementation MainMenuScene

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    
    MainMenuScene *layer = [MainMenuScene node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    if( (self=[super init] )) {
        // create and initialize a Label
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"CocoShoot" fontName:@"Marker Felt" fontSize:64];
        
        // ask director for the window size
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // position the label on the center of the screen
        label.position =  ccp( size.width /2 , size.height/2 );
        
        // add the label as a child to this Layer
        [self addChild: label];
        
        
        
        //
        // Leaderboards and Achievements
        //
        
        // Default font size will be 28 points.
        [CCMenuItemFont setFontSize:28];
        
        // Achievement Menu Item using blocks
        CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
            
            
            GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
            achivementViewController.achievementDelegate = self;
            
            AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
            
            [[app navController] presentModalViewController:achivementViewController animated:YES];
            
            [achivementViewController release];
        }];
        
        // Leaderboard Menu Item using blocks
        CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
            
            
            GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
            leaderboardViewController.leaderboardDelegate = self;
            
            AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
            
            [[app navController] presentModalViewController:leaderboardViewController animated:YES];
            
            [leaderboardViewController release];
        }];
        
        CCMenuItem *itemStartGame = [CCMenuItemFont itemWithString:@"Start" block:^(id sender){
            [[CCDirector sharedDirector] replaceScene:[GameScene scene]];
        }];
        
        CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, itemStartGame, nil];
        
        [menu alignItemsHorizontallyWithPadding:20];
        [menu setPosition:ccp( size.width/2, size.height/2 - 50)];
        
        // Add the menu to the layer
        [self addChild:menu];
        
        
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
