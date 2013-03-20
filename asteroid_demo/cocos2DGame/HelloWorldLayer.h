//
//  HelloWorldLayer.h
//  Cocos2DiOSTutorial
//
//  Created by Kratz, Alexander S on 11/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "SimpleAudioEngine.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

NSMutableArray *_targets;
NSMutableArray *_projectiles;
NSMutableArray *_buildings;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void)addTarget;
-(void)addBuildings;
-(void)spriteMoveFinished:(id)sender;
-(void)gameLogic:(ccTime)dt;
-(void)updateTargetLocation;
-(void)explodeAsteroid:(CGPoint)location;
-(void)damageBuilding:(CCSprite*)building;

@end
