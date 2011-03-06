//
//  PreferencePaneController.h
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>


@interface PreferencePaneController : NSPreferencePane <NSWindowDelegate, NSToolbarDelegate> {
    IBOutlet NSTabView *prefTabs;
    IBOutlet NSWindow *originalWindow;

   @private
    NSWindow *window;
    NSToolbar *theToolbar;
}

- (IBAction)changeTab:(id)sender;
- (void)addToolbar;
- (void)displayPreferences;
- (void)closePreferences;

@end
