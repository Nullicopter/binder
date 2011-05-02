
//
//  PreferencePaneController.m
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import "PreferencePaneController.h"

NSString * const BinderSyncHotKeyCodePreferencesKey = @"syncHotKeyCode";
NSString * const BinderSyncHotKeyFlagsPreferencesKey = @"syncHotKeyFlags";
NSString * const BinderProjectsDirectoryPreferencesKey = @"projectsDirectory";
NSString * const BinderStartAtLoginPreferencesKey = @"startAtLogin";
NSString * const BinderAccountUsernamePreferencesKey = @"accountUsername";
NSString * const BinderAccountPasswordPreferencesKey = @"accountPassword";

@interface PreferencePaneController()
- (LSSharedFileListItemRef)findStartupItem:(NSString *)appPath;
@end

@implementation PreferencePaneController

@synthesize globalSyncCombination;
@synthesize accountPasswordField;
@synthesize accountUsernameField;
@synthesize startAtLoginSwitch;

- (IBAction)linkAccount:(id)sender {
    NSString *username = [self.accountUsernameField stringValue];
    NSString *password = [self.accountPasswordField stringValue];
    // XXX This is so broken it's hard to believe, but for now it's cool
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:BinderAccountUsernamePreferencesKey];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:BinderAccountPasswordPreferencesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)changeTab:(id)sender {
    [prefTabs selectTabViewItemWithIdentifier:[sender itemIdentifier]];
}

- (IBAction)performClose:(id)sender {
    NSLog(@"Close was called");
    [self close];
    [self setWindow:nil];
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
}

- (IBAction)changeStartAtLoginStatus:(id)sender {
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        if ([startAtLoginSwitch state]) {
            //Insert an item to the list.
            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                    forKey:BinderStartAtLoginPreferencesKey];
            LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);

            if (item) {
                CFRelease(item);
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO
                                                    forKey:BinderStartAtLoginPreferencesKey];
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

// Helper functions
-(void) display {
    NSLog(@"Window loaded? %@", ([self isWindowLoaded]) ? @"YES" : @"NO");
    [[self window] center];
    
    // Here fetch KeyCombo from the HotKeyCenter and set it in the view.
    unsigned short keyCode = [[NSUserDefaults standardUserDefaults] integerForKey:BinderSyncHotKeyCodePreferencesKey];
    if (!keyCode) keyCode = 53;
    
    NSUInteger modifierFlags = [[NSUserDefaults standardUserDefaults] integerForKey:BinderSyncHotKeyFlagsPreferencesKey];
    if (!modifierFlags) modifierFlags = NSControlKeyMask;
    
    KeyCombo combo;
    combo.code = keyCode;
    combo.flags = modifierFlags;
    [globalSyncCombination setKeyCombo:combo];

    
    [self showWindow:self];
    [[self window] orderFrontRegardless];
    [NSApp activateIgnoringOtherApps:YES];
    [theToolbar setSelectedItemIdentifier:[[[theToolbar items] objectAtIndex:0] itemIdentifier]];
}



// SRRecorderControl delegates
- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder 
               isKeyCode:(NSInteger)keyCode
           andFlagsTaken:(NSUInteger)flags
                  reason:(NSString **)aReason {
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder
       keyComboDidChange:(KeyCombo)newKeyComb {
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
