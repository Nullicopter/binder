//
//  BinderMenulet.m
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BinderMenulet.h"
#import "DDHotKeyCenter.h"

@implementation BinderMenulet
- (void)dealloc {
    [statusItem release];
    [prefPane release];
    [super dealloc];
}

- (void)awakeFromNib 
{
    // init everything here
    NSImage *menuIconOn = [NSImage imageNamed:@"menu.tiff"];

    statusItem = [[[NSStatusBar systemStatusBar] 
                   statusItemWithLength:NSVariableStatusItemLength] 
                  retain];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:menuIconOn];
    [statusItem setEnabled:YES];
    [statusItem setToolTip:@"Binder!!"];
    [statusItem setMenu:theMenu];

    prefPane = [[PreferencePaneController alloc] initWithWindowNibName:@"PrefPane"];
    [prefPane updateHotKeyCombo];

}

- (NSString *) pathForData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/Binder/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath:folder] == NO)
    {
        BOOL created = [fileManager createDirectoryAtPath:folder
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
        if (created == NO) {
            NSLog(@"Couldn't create directory");
        }
    }
    
    return folder;
}

- (IBAction)synchronize:(id)event
{
    NSLog(@"Received event");
    NSUInteger isLaunched = [[NSRunningApplication
                             runningApplicationsWithBundleIdentifier:@"com.nullicopter.syncer"] count];

    if (isLaunched > 0)
    {
        NSLog(@"Already launched waiting for it to finish");
        return;
    }

    NSWorkspace *shared = [NSWorkspace sharedWorkspace];    
    NSError *launchError = nil;
    
    NSArray *syncPaths = [NSArray arrayWithObjects:@"/some/syncing/path", @"/some/other/syncing", nil];
    
    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:@"API_TOKEN", @"BINDER_API_TOKEN", 
                                                                           @"/some/path", @"BINDER_DB",
                                                                           nil];

    NSDictionary *configuration = [NSDictionary
        dictionaryWithObjectsAndKeys:environment, NSWorkspaceLaunchConfigurationEnvironment,
                                     syncPaths, NSWorkspaceLaunchConfigurationArguments, nil];

    NSLog(@"%@", [shared URLForApplicationWithBundleIdentifier:@"com.nullicopter.syncer"]);
    [shared launchApplicationAtURL:[shared URLForApplicationWithBundleIdentifier:@"com.nullicopter.syncer"]
                           options:(NSWorkspaceLaunchWithoutActivation|NSWorkspaceLaunchAsync)
                     configuration:configuration
                             error:&launchError];
    
}

- (IBAction)displayPreferences:(id)sender 
{
    [prefPane display];
}

- (IBAction)quit:(id)sender 
{
    [NSApp terminate:self];
}

@end
