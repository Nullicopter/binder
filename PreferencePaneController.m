
//
//  PreferencePaneController.m
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "PreferencePaneController.h"
#import "BinderConstants.h"

NSString * const BinderSyncHotKeyCodePreferencesKey = @"syncHotKeyCode";
NSString * const BinderSyncHotKeyFlagsPreferencesKey = @"syncHotKeyFlags";
NSString * const BinderProjectsDirectoryPreferencesKey = @"projectsDirectory";
NSString * const BinderAccountUsernamePreferencesKey = @"accountUsername";
NSString * const BinderAccountPasswordPreferencesKey = @"accountPassword";

// TODO: since the preferences are just a few I should have a dictionary that
// contains all of them and flush all of it to disk when one changes and then
// hook the values of the objects up to the dictionary keys or set fields and
// hook those up. Maybe set getters and setters for preferences that save
// to disk and hook the value of widgets up to this stuff.

@interface PreferencePaneController()
- (LSSharedFileListItemRef)findStartupItem:(NSString *)appPath;
@end

@implementation PreferencePaneController

@synthesize globalSyncCombination;
@synthesize projectsDirectory;
@synthesize accountPasswordField;
@synthesize accountUsernameField;
@synthesize startAtLoginSwitch;
@synthesize accountCredentials;

- (IBAction)changeTab:(id)sender {
    NSLog(@"Change to %@", [sender itemIdentifier]);
    [prefTabs selectTabViewItemWithIdentifier:[sender itemIdentifier]];
}
- (IBAction)linkAccount:(id)sender {
    NSString *username = [self.accountUsernameField stringValue];
    NSString *password = [self.accountPasswordField stringValue];
    // XXX This is so broken it's hard to believe, but for now it's cool
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:BinderAccountUsernamePreferencesKey];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:BinderAccountPasswordPreferencesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateAccountCredentials];
}

- (IBAction)changeDirectory:(id)sender {
    int result;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    
    [oPanel setCanChooseFiles:NO];
    [oPanel setCanChooseDirectories:YES];
    [oPanel setCanCreateDirectories:YES];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setTitle:@"Choose Folder"];
    [oPanel setMessage:@"Choose a Projects working directory."];
    [oPanel setDelegate:self];
    [oPanel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    result = [oPanel runModal];

    NSURL *url = [[oPanel URLs] objectAtIndex:0];
    if (![url isFileURL]) return;
    
    NSLog(@"Moved project location at %@", [url path]);
    [[NSUserDefaults standardUserDefaults] setObject:[url path] forKey:BinderProjectsDirectoryPreferencesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateProjectsDirectory];
    [projectsDirectoryField setStringValue:self.projectsDirectory];
}

- (IBAction)changeStartAtLoginStatus:(id)sender {
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        if ([startAtLoginSwitch state]) {
            //Insert an item to the list.
            LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
            if (item) {
                CFRelease(item);
            }
        } else {
            LSSharedFileListItemRef itemRef = [self findStartupItem:appPath];
            if (itemRef) {
                LSSharedFileListItemRemove(loginItems, itemRef);
            }
        }
        
        CFRelease(loginItems);
    }
}

- (LSSharedFileListItemRef)findStartupItem:(NSString *)appPath {
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems) {
		UInt32 seedValue;
		NSArray *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        CFRelease(loginItems);
        
		for (int i = 0; i < [loginItemsArray count]; ++i) {
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            
			//Resolve the item with URL
            CFURLRef url;
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString *urlPath = [(NSURL*)url path];
                CFRelease(url);
				if ([urlPath compare:appPath] == NSOrderedSame){
                    CFRetain(itemRef);
                    [loginItemsArray release];
                    return itemRef;
				}
			}
		}
		[loginItemsArray release];
    }
    
    return nil;
}


- (void)loadPreferences {
    [self updateProjectsDirectory];
    [self updateHotKeyCombo];
    [self updateAccountCredentials];
    [self updateStartAtLogin];
}

- (void)updateStartAtLogin {
    [startAtLoginSwitch setState:0];
    //[startAtLoginSwitch setTarget:self];
    //[startAtLoginSwitch setAction:@selector(updateStartupLaunchAction:)];
    
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    if ([self findStartupItem:appPath]) {
        [startAtLoginSwitch setState:1];
    }
}

- (void)updateProjectsDirectory {
    NSLog(@"Updating project directory location");
    
    NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:BinderProjectsDirectoryPreferencesKey];
    if (!directory) directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Projects"];
    self.projectsDirectory = directory;
    
    NSLog(@"Moved project location at %@", self.projectsDirectory);

}

- (void)updateAccountCredentials {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:BinderAccountUsernamePreferencesKey];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:BinderAccountPasswordPreferencesKey];

    if (!username) username = @"";
    if (!password) password = @"";

    NSArray *objects = [NSArray arrayWithObjects: username, password, nil];
    NSArray *keys = [NSArray arrayWithObjects: @"username", @"password", nil];
    NSDictionary *credentials = [NSDictionary dictionaryWithObjects: objects
                                                            forKeys: keys];
    self.accountCredentials = credentials;
}

- (void)updateHotKeyCombo {
    NSLog(@"Changed keyCombo.");
    
    DDHotKeyCenter *hotKeyCenter = [[DDHotKeyCenter alloc] init];
    [hotKeyCenter unregisterHotKeysWithTarget:[NSApp delegate] action:@selector(synchronize:)];
    
    unsigned short keyCode = [[NSUserDefaults standardUserDefaults] integerForKey:BinderSyncHotKeyCodePreferencesKey];
    if (!keyCode) keyCode = 53;
    
    NSUInteger modifierFlags = [[NSUserDefaults standardUserDefaults] integerForKey:BinderSyncHotKeyFlagsPreferencesKey];
    if (!modifierFlags) modifierFlags = NSControlKeyMask;
    
    if (![hotKeyCenter registerHotKeyWithKeyCode:keyCode 
                                   modifierFlags:modifierFlags 
                                          target:[NSApp delegate] 
                                          action:@selector(synchronize:) 
                                          object:nil]) {
		NSLog(@"Unable to register hotkey.");
	} else {
		NSLog(@"Registered: %@", [hotKeyCenter registeredHotKeys]);        
	}
    
    [hotKeyCenter release];
    
}



// NSWindowDelegate methods

- (NSString *)mainNibName {
    return @"PrefPane";
}

- (void)mainViewDidLoad {
    NSLog(@"Opened Preferences");
}

-(void) closePreferences {
    [self willUnselect];
    
    // displayPreferences checks for NULL to see whether pref window is currently open
    window = NULL;
    
    [self didUnselect];
}
- (void)didSelect {
    
    // Here fetch KeyCombo from the HotKeyCenter and set it in the view.
    unsigned short keyCode = [[NSUserDefaults standardUserDefaults] integerForKey:BinderSyncHotKeyCodePreferencesKey];
    if (!keyCode) keyCode = 53;
    
    NSUInteger modifierFlags = [[NSUserDefaults standardUserDefaults] integerForKey:BinderSyncHotKeyFlagsPreferencesKey];
    if (!modifierFlags) modifierFlags = NSControlKeyMask;
    
    KeyCombo combo;
    combo.code = keyCode;
    combo.flags = modifierFlags;
    [globalSyncCombination setKeyCombo:combo];
    
    // Set the directory of the project
    [projectsDirectoryField setStringValue:self.projectsDirectory];
    
    // Set the username/password stuff
    [self.accountUsernameField setStringValue: [self.accountCredentials objectForKey:@"username"]];
    [self.accountPasswordField setStringValue: [self.accountCredentials objectForKey:@"password"]];
    
    // Set the state of startAtLogin
    [self updateStartAtLogin];
}

- (void)willUnselect {
    
}

- (void)didUnselect {
    
}

- (void)willSelect {

}

- (void)windowDidResignKey:(NSNotification *)notification {

}

- (void)windowWillClose:(NSNotification *)notification {
    if ([notification object] == window) {
        [self closePreferences];
    }
    // If you have more than one window and this is the one that
    // got closed then bring back the other one.
    //    else if ([notification object] == profileInputWindow) {
    //        [NSApp stopModal];
    //        [window makeKeyAndOrderFront:NSApp];
    //        [NSApp activateIgnoringOtherApps:YES];
    //    }
}

- (BOOL)windowShouldClose:(id)sender {
    return TRUE;
}


// Helper functions

-(void) displayPreferences {
    if (window != NULL) {
        [window orderFrontRegardless];
        [NSApp activateIgnoringOtherApps:YES];
        return;
    }

    NSView *prefView;
    if ([self loadMainView]) {
        [self willSelect];
        prefView = [self mainView];
        
        // create preferences window
        NSSize prefSize = [prefView frame].size;
        NSRect frame = NSMakeRect(200, 200, prefSize.width, prefSize.height);

        window  = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:NSTitledWindowMask | NSClosableWindowMask | NSUnifiedTitleAndToolbarWindowMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];

        [window center];
        [window setContentView:prefView];
        [window setTitle:@"Binder Preferences"];
        [self addToolbar];
        [window setDelegate:self];
        [window makeKeyAndOrderFront:NSApp];
        [NSApp activateIgnoringOtherApps:YES];
        [self didSelect];
    } else {
        NSLog(@"load preferences error");
    }
}

-(void) addToolbar {
    
    theToolbar = [[[NSToolbar alloc] initWithIdentifier: @"theToolbar"] autorelease];
    [theToolbar setAllowsUserCustomization:NO];
    [theToolbar setAutosavesConfiguration:YES];
    [theToolbar setDelegate:self];
    [window setToolbar:theToolbar];
    [theToolbar setSelectedItemIdentifier:BinderToolbarGeneralItemIdentifier];

}


// NSToolbarDelegate methods

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willBeInsertedIntoToolbar {
    NSToolbarItem *item = nil;
    
    if ([itemIdentifier isEqualToString:BinderToolbarGeneralItemIdentifier]) {
        
        item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [item setPaletteLabel:BinderToolbarGeneralItemLabel];
        [item setLabel:BinderToolbarGeneralItemLabel];
        [item setImage:[NSImage imageNamed:BinderToolbarGeneralItemImageName]];
        [item setAction:@selector(changeTab:)];
        [item setToolTip:nil];
    }
    else if ([itemIdentifier isEqualToString:BinderToolbarAccountItemIdentifier]) {
        
        item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [item setPaletteLabel:BinderToolbarAccountItemLabel];
        [item setLabel:BinderToolbarAccountItemLabel];
        [item setImage:[NSImage imageNamed:BinderToolbarAccountItemImageName]];
        [item setAction:@selector(changeTab:)];
        [item setToolTip:nil];
    }
    return [item autorelease];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
            BinderToolbarGeneralItemIdentifier,
            BinderToolbarAccountItemIdentifier,
            nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:
            BinderToolbarGeneralItemIdentifier,
            BinderToolbarAccountItemIdentifier,
            nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar {
    return [NSArray arrayWithObjects:
            BinderToolbarGeneralItemIdentifier,
            BinderToolbarAccountItemIdentifier,
            nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    return YES;
}




// SRRecorderControl delegates

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason {
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyComb {
    NSLog(@"New combo setup.");
    
    [[NSUserDefaults standardUserDefaults] setInteger:newKeyComb.code forKey:BinderSyncHotKeyCodePreferencesKey ];
    [[NSUserDefaults standardUserDefaults] setInteger:newKeyComb.flags forKey:BinderSyncHotKeyFlagsPreferencesKey ];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateHotKeyCombo];
}

// NSOpenSavePanelDelegate
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    if (![url isFileURL]) return NO;
    
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:[url path] isDirectory:&isDir] && isDir)
        return YES;
    return NO;
}


@end
