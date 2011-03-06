//
//  PreferencePaneController.m
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencePaneController.h"
#import <PreferencePanes/PreferencePanes.h>

NSString * const BinderToolbarGeneralItemIdentifier = @"BinderToolbarGeneralItemIdentifier";
NSString * const BinderToolbarGeneralItemLabel = @"General";
NSString * const BinderToolbarGeneralItemImageName = @"NSPreferencesGeneral";

NSString * const BinderToolbarAccountItemIdentifier = @"BinderToolbarAccountItemIdentifier";
NSString * const BinderToolbarAccountItemLabel = @"Account";
NSString * const BinderToolbarAccountItemImageName = @"NSUser";

@implementation PreferencePaneController

- (NSString *)mainNibName {
    return @"PrefPane";
}

- (void)mainViewDidLoad {
    //  NSLog(@"mainViewDidLoad  %@", [profileURL delegate]);
}

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

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects:
            BinderToolbarGeneralItemIdentifier,
            BinderToolbarAccountItemIdentifier,
            nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
            BinderToolbarGeneralItemIdentifier,
            BinderToolbarAccountItemIdentifier,
            nil];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
            BinderToolbarGeneralItemIdentifier,
            BinderToolbarAccountItemIdentifier,
            nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    return YES;
}

-(void) closePreferences {
    [self willUnselect];
    
    // displayPreferences checks for NULL to see whether pref window is currently open
    window = NULL;
    
    [self didUnselect];
}


- (IBAction)changeTab:(id)sender {
    NSLog(@"Change to %@", [sender itemIdentifier]);
    [prefTabs selectTabViewItemWithIdentifier:[sender itemIdentifier]];
}


- (void)willUnselect {

}

- (void)didUnselect {
    
}

- (void)willSelect {

}

- (void)windowDidResignKey:(NSNotification *)notification {
//    if ([notification object] == window) {
        // will also be invoked when window is closed, so check first
//        if (window != NULL) {
//            [self flushPreferences];
//        }
//    }
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
//    if (sender == profileInputWindow) {
//        return activity != FETCHING_USER_PROFILE;
//    }
    return TRUE;
}


@end
