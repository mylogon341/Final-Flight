


#import "cocos2d.h"
#import "Menu.h"
#import "AppDelegate.h"
#import "CCBuilderReader.h"
#import "GAI.h"


@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GameCenterManager sharedManager] setupManager];
    
    NSString *strFromInt = [NSString stringWithFormat:@"0"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"muted"];
    [defaults setObject:strFromInt forKey:@"difficulty"];
    [defaults setObject:strFromInt forKey:@"MUSIC"];
    [defaults setObject:strFromInt forKey:@"boot"];


    
    [defaults synchronize];
    
    
    
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"]; // TODO: add support for Published-Android support
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    NSMutableDictionary* cocos2dSetup = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    
    // Note: this needs to happen before configureCCFileUtils is called, because we need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
        else
            [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif
            
            // Configure CCFileUtils to work with SpriteBuilder
            [CCBReader configureCCFileUtils];
    
    // Do any extra configuration of Cocos2d here (the example line changes the pixel format for faster rendering, but with less colors)
    //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 30;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    id<GAITracker> tracker =[[GAI sharedInstance] trackerWithTrackingId:@"UA-48569871-1"];
    [GAI sharedInstance].defaultTracker = tracker;
    
    
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    Menu *menu = [[Menu alloc]init];
    [menu counter];
    [menu bootGame];
    NSString *strFromInt = [NSString stringWithFormat:@"0"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:strFromInt forKey:@"MUSIC"];
    [defaults synchronize];
    
}


- (CCScene*) startScene
{
    return [CCBReader loadAsScene:@"Game"];
}

@end