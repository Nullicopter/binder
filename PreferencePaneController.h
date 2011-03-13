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

@interface PreferencePaneController : NSPreferencePane <NSWindowDelegate, NSToolbarDelegate, NSOpenSavePanelDelegate> {
    IBOutlet NSTabView *prefTabs;
    IBOutlet SRRecorderControl *globalSyncCombination;
    IBOutlet NSTextField *projectsDirectoryField;
    IBOutlet NSButton *startAtLoginSwitch;
    IBOutlet NSTextField *accountUsernameField;
    IBOutlet NSSecureTextField *accountPasswordField;
    NSDictionary *accountCredentials;
    NSString *projectsDirectory;

   @private
    NSWindow *window;
    NSToolbar *theToolbar;
}

@property (nonatomic, retain) IBOutlet SRRecorderControl *globalSyncCombination;
@property (nonatomic, retain) NSString *projectsDirectory;
@property (nonatomic, retain) IBOutlet NSButton *startAtLoginSwitch;
@property (nonatomic, retain) IBOutlet NSTextField *accountUsernameField;
@property (nonatomic, retain) IBOutlet NSSecureTextField *accountPasswordField;
@property (nonatomic, retain) NSDictionary *accountCredentials;

- (IBAction)changeTab:(id)sender;
- (IBAction)changeDirectory:(id)sender;
- (IBAction)linkAccount:(id)sender;
- (IBAction)changeStartAtLoginStatus:(id)sender;
- (void)addToolbar;
- (void)displayPreferences;
- (void)loadPreferences;
- (void)closePreferences;
- (void)updateHotKeyCombo;
- (void)updateProjectsDirectory;
- (void)updateAccountCredentials;
- (void)updateStartAtLogin;
- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason;
- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyComb;

@end
