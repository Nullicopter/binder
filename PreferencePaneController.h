//
//  PreferencePaneController.h
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>
#import "ShortcutRecorder/ShortcutRecorder.h"

#import "DDHotKeyCenter.h"

@interface PreferencePaneController : NSPreferencePane <NSWindowDelegate, NSToolbarDelegate> {
    IBOutlet NSTabView *prefTabs;
    IBOutlet SRRecorderControl *globalSyncCombination;
    IBOutlet NSTextField *disallowReasonField;
    
   @private
    NSWindow *window;
    NSToolbar *theToolbar;
}

@property (nonatomic, retain) IBOutlet SRRecorderControl *globalSyncCombination;

- (IBAction)changeTab:(id)sender;
- (void)addToolbar;
- (void)displayPreferences;
- (void)closePreferences;
- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason;
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyComb;

@end
