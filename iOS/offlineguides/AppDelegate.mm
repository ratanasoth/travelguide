#import "AppDelegate.h"
#import "ArticleVC.h"
#import "GuideVC.h"
#import "IPadSplitVC.h"
#import "MapsWithMeAPI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ArticleVC alloc] initWithStyle:UITableViewStylePlain]];
  else
    self.window.rootViewController = [[IPadSplitVC alloc] init];
  [self.window makeKeyAndVisible];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
  if ([sourceApplication rangeOfString:@"com.mapswithme."].length != 0)
  {
    MWMPin * pin = [MWMApi pinFromUrl:url];
    if (pin)
    {
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      {
        IPadSplitVC * spVC = (IPadSplitVC *)self.window.rootViewController;
        UINavigationController * navVC = (UINavigationController *)([spVC.viewControllers objectAtIndex:1]);
        GuideVC * guide = ((GuideVC *)navVC.topViewController);
        if ([[guide getCurrentUrl] rangeOfString:pin.idOrUrl].length != 0)
          return YES;
        GuideVC * g = [[GuideVC alloc] init];
        [g loadPage:pin.idOrUrl];
        g.navigationItem.leftBarButtonItem = nil;
        [spVC replaceGuide:g];
      }
      else
      {
        UINavigationController * navVC = (UINavigationController *)self.window.rootViewController;
        if ([navVC.topViewController isKindOfClass:[GuideVC class]])
        {
          GuideVC * guide = ((GuideVC *)navVC.topViewController);
          if ([[guide getCurrentUrl] rangeOfString:pin.idOrUrl].length != 0)
            return YES;
          else
            [navVC popToRootViewControllerAnimated:NO];
        }
        [(ArticleVC *)navVC.topViewController loadGuideAndPushToNavigationController:pin.idOrUrl];
      }
    }
    return YES;
  }
  return NO;
}

-(NSString *)getDataFolderName
{
  NSString * bundleRoot = [[NSBundle mainBundle] bundlePath];
  NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:nil];
  for (NSString * s in files)
    if ([s hasPrefix:@"data"])
      return s;
  return @"";
}

-(NSString *)getDataFolderNameWithSlashes
{
  NSString * dataPath = [self getDataFolderName];
  return [NSString stringWithFormat:@"/%@/", dataPath];
}

@end
