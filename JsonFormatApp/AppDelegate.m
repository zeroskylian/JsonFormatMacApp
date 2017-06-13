//
//  AppDelegate.m
//  JsonFormatApp
//
//  Created by 廉鑫博 on 2017/6/12.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "AppDelegate.h"
#import "ESSettingController.h"
@interface AppDelegate ()
@property (strong, nonatomic)ESSettingController *settingCtrl;
@end

@implementation AppDelegate
- (IBAction)ShowSetting:(id)sender {
    
    self.settingCtrl = [[ESSettingController alloc] initWithWindowNibName:@"ESSettingController"];
    [self.settingCtrl showWindow:self.settingCtrl];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
-(BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    
    
    if (!flag){
        [[NSApplication sharedApplication].windows.firstObject makeKeyAndOrderFront:self];
        return YES;
    }
    return NO;
    
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    
    return false;
}


@end
