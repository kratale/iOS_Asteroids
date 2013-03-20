//
//  HelloWorldLayer.m
//  Cocos2DiOSTutorial
//
//  Created by Kratz, Alexander S on 11/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"



#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

bool isAsteroidFalling = NO;
CCSpriteBatchNode *spriteSheet;
SimpleAudioEngine *sae;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//adds people to the screen
-(void)addTarget{
    
    CCSprite *target = [CCSprite spriteWithFile:@"Target.png" rect:CGRectMake(0,0,27,40)];
    
    //add target to array
    target.tag = 1;
    [_targets addObject:target];
    
    int actualX;
    int actualY;
    Boolean doesIntersectBuilding = YES;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    while(doesIntersectBuilding == YES){
        //assume it does not spawn in a building
        doesIntersectBuilding = NO;
        //Determines where the target spawns along the Y axis
        int minY = target.contentSize.height/2;
        int maxY = winSize.height - target.contentSize.height/2;
        int rangeY = maxY - minY;
        actualY = (arc4random() % rangeY) + minY;
    
        //Determine where the target spawns along the X axis
        int minX = target.contentSize.width/2;
        int maxX = winSize.width - target.contentSize.width/2;
        int rangeX = maxX - minX;
        actualX = (arc4random() % rangeX) + minX;
        
        target.position = ccp(actualX, actualY);
        
        CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2),
                                       target.position.y - (target.contentSize.height/2),
                                       target.contentSize.width,
                                       target.contentSize.height);
        
        //check to see if target spawns in building, if it does repeat the loop
        for (CCSprite *building in _buildings) {
            CGRect buildingRect = CGRectMake(building.position.x - (building.contentSize.width/2),
                                           building.position.y - (building.contentSize.height/2),
                                           building.contentSize.width,
                                           building.contentSize.height);
            
            if(CGRectIntersectsRect(buildingRect, targetRect)){
                doesIntersectBuilding = YES;
            }
        }
    }
    
    //create target on screen
    [self addChild:target];
    
    //Determine speed of the target
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //create the actions
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualX, actualY)];
    //id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove, nil, nil]];
}

//adds 4 buildings in predefined locations
-(void)addBuildings{
    CCSprite *building1 = [CCSprite spriteWithFile:@"building.png" rect:CGRectMake(0,0,75,110)];
    CCSprite *building2 = [CCSprite spriteWithFile:@"building.png" rect:CGRectMake(0,0,75,110)];
    CCSprite *building3 = [CCSprite spriteWithFile:@"building.png" rect:CGRectMake(0,0,75,110)];
    CCSprite *building4 = [CCSprite spriteWithFile:@"building.png" rect:CGRectMake(0,0,75,110)];
    
    building1.position = ccp(100,100);
    building2.position = ccp(375,200);
    building3.position = ccp(50,250);
    building4.position = ccp(250,75);
    
    building1.tag = 3;
    building2.tag = 3;
    building3.tag = 3;
    building4.tag = 3;
    
    [_buildings addObject:building1];
    [_buildings addObject:building2];
    [_buildings addObject:building3];
    [_buildings addObject:building4];
    
    [self addChild:building1];
    [self addChild:building2];
    [self addChild:building3];
    [self addChild:building4];
}

//called when an asteroid lands;
-(void)spriteMoveFinished:(id)sender{
    CCSprite *sprite = (CCSprite *)sender;
    if (sprite.tag == 1) { // target
        [_targets removeObject:sprite];
    } 
    else if (sprite.tag == 2) { // projectile
        [_projectiles removeObject:sprite];
    }
    
    [self explodeAsteroid:[sprite position]];
    [self removeChild:sender cleanup:YES];
    [spriteSheet removeChild:sender cleanup:YES];
    isAsteroidFalling = NO;
}

//displays exploding asteroid and checks for collisions
-(void)explodeAsteroid:(CGPoint)location{
    CCSprite *projectile = [CCSprite spriteWithFile:@"AsteroidExploding.png" rect:CGRectMake(0,0,40,40)];
    projectile.position = location;

    [self addChild:projectile];
    
    //hit detection
    CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2),
                                       projectile.position.y - (projectile.contentSize.height/2),
                                       projectile.contentSize.width,
                                       projectile.contentSize.height);
    
    NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *target in _targets) {
        CGRect targetRect = CGRectMake(
                                       target.position.x - (target.contentSize.width/2),
                                       target.position.y - (target.contentSize.height/2),
                                       target.contentSize.width,
                                       target.contentSize.height);
        
        if (CGRectIntersectsRect(projectileRect, targetRect)) {
            [targetsToDelete addObject:target];
        }
    }
    
    for (CCSprite *building in _buildings) {
        CGRect buildingRect = CGRectMake(
                                       building.position.x - (building.contentSize.width/2),
                                       building.position.y - (building.contentSize.height/2),
                                       building.contentSize.width,
                                       building.contentSize.height);
        
        if (CGRectIntersectsRect(projectileRect, buildingRect)) {
            //if the building is undamaged then damage it
            if(building.tag == 3){
                [self damageBuilding:building];
                
                //[_buildings removeObject:building];
                [self removeChild:building cleanup:NO];
            }
        }
    }
    
    for (CCSprite *target in targetsToDelete) {
        [_targets removeObject:target];
        [self removeChild:target cleanup:YES];
    }
    [targetsToDelete release];
}

//replaces a building with its damaged sprite
-(void)damageBuilding:(CCSprite *)building{
    CCSprite *damagedBuilding = [CCSprite spriteWithFile:@"damagedBuilding.png" rect:CGRectMake(0,0,75,110)];
    damagedBuilding.position = building.position;
    damagedBuilding.tag = 4;
    building.tag = 4;
    

    //[_buildings addObject:damagedBuilding];
    [self addChild:damagedBuilding];
}

//movement for the people on the screen
-(void)updateTargetLocation{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *current;
    
    for(int i=0; i<[_targets count]; i++){
        current = [_targets objectAtIndex:i];
        
        float x = current.position.x;
        float y = current.position.y;
        
        int xDirection = (arc4random() % 2);
        int yDirection = (arc4random() % 2);
        
        float xModified = x * .2;
        float yModified = y * .2;
        
        if(xDirection == 0) xModified = xModified * (-1);
        if(yDirection == 0) yModified = yModified * (-1);
        
        //check for collisions with walls
        if(x + xModified > winSize.width || x + xModified < 0){
            xModified = xModified * (-1);
        }
        if(y + yModified > winSize.height || y + yModified < 0){
            yModified = yModified * (-1);
        }
        
        //check for collisions with buildings
        CGRect currentRect = CGRectMake(current.position.x + xModified - (current.contentSize.width/2),
                                           current.position.y + yModified - (current.contentSize.height/2),
                                           current.contentSize.width,
                                           current.contentSize.height);
        
        for (CCSprite *building in _buildings) {
            CGRect targetRect = CGRectMake(building.position.x - (building.contentSize.width/2),
                                           building.position.y - (building.contentSize.height/2),
                                           building.contentSize.width,
                                           building.contentSize.height);
            
            //if the current target would move into a building, move up to building
            if (CGRectIntersectsRect(currentRect, targetRect)) {
                //current target is to the left of building
                if(current.position.x < building.position.x){
                    xModified = 0;
                }
                //current target is under the building
                if(current.position.y < building.position.y){
                    yModified = 0;
                }
                //current target is to the right of the building
                if(current.position.x > building.position.x){
                    xModified = 0;
                }
                //current target is over the building
                if(current.position.y > building.position.y){
                    yModified = 0;
                }
            }
        }
        
        id actionMove = [CCMoveTo actionWithDuration:1.0f position:ccp(x + xModified, y + yModified)];
        [current runAction:[CCSequence actions:actionMove, nil, nil]];
    }
}

-(void)gameLogic:(ccTime)dt {
    //[self addTarget];
    [self updateTargetLocation];
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    sae = [SimpleAudioEngine sharedEngine];
    [sae playEffect:@"asteroid_impact.mp3"];
    
    if(isAsteroidFalling == NO){
        //choose one of the touches to work with
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
    
        //set up initial location of projectile
        CGSize winSize = [[CCDirector sharedDirector] winSize];
    
        isAsteroidFalling = YES;
        NSMutableArray *asteroidFrames = [NSMutableArray array];
        
        for(int i=1; i<3; i++){
            [asteroidFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"asteroid%d.png", i]]];
        }
        
        CCAnimation *asteroidAnimation = [CCAnimation animationWithSpriteFrames:asteroidFrames delay:0.1f];
        CCSprite *projectile = [CCSprite spriteWithSpriteFrameName:@"asteroid1.png"];
        
        //determine where the asteroid starts its drop
        projectile.position = ccp(arc4random() % (int)winSize.width, winSize.height);
        CCAction *asteroidDrop = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:asteroidAnimation]];
        [projectile runAction:asteroidDrop];
        [spriteSheet addChild:projectile];
    
        //add projectile to array
        projectile.tag = 2;
        [_projectiles addObject:projectile];
    
        //[self addChild:projectile];
        CGPoint realDest = ccp(location.x, location.y);
    
        //scales image down as it drops
        id actionScale = [CCScaleBy actionWithDuration:0.5f scaleX:.2 scaleY:.2];
        [projectile runAction:actionScale];
    
        //move asteroid to where the user pressed
        [projectile runAction:[CCSequence actions:
                               [CCMoveTo actionWithDuration:0.5f position:realDest],
                               [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                               nil]];
    }
}

- (void)update:(ccTime)dt {

}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(255,255,255,255)]) ) {
        

        
        _targets = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        _buildings = [[NSMutableArray alloc] init];
        
        //load sprite sheet containing animation data
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"asteroid.plist"];
        spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"asteroid.png"];
        [self addChild:spriteSheet];
        
        self.isTouchEnabled = YES;

        [self addBuildings];
        
        for(int i=0; i<25; i++){
            [self addTarget];
        }
        
        [self schedule:@selector(gameLogic:) interval:2.0];
        [self schedule:@selector(update:) interval:.5];
		
        
        sae = [SimpleAudioEngine sharedEngine];
        if (sae != nil) {
            [sae preloadBackgroundMusic:@"SburbanJungle.mp3"];
            if (sae.willPlayBackgroundMusic) {
                sae.backgroundMusicVolume = 0.5f;
            }
        }
        [sae playBackgroundMusic:@"SburbanJungle.mp3"];
		//
		// Leaderboards and Achievements
		//
		
        //CGSize size = [[CCDirector sharedDirector] winSize];
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
			
			
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:achivementViewController animated:YES];
			
			[achivementViewController release];
		}
									   ];
        [(CCMenuItemFont *)itemAchievement setColor:ccc3(0,0,0)];
        

		// Leaderboard Menu Item using blocks
		/*CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			
			
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
			[leaderboardViewController release];
		}
									   ];*/
		
		CCMenu *menu = [CCMenu menuWithItems:itemAchievement, nil];
		
		//[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp(80, 20)];
		
		// Add the menu to the layer
		[self addChild:menu];

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
    [_targets release];
    _targets = nil;
    [_projectiles release];
    _projectiles = nil;
    
	// don't forget to call "super dealloc"
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
