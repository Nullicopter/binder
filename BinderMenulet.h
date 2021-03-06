//
//  BinderMenulet.h
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PreferencePaneController.h"
#import "DDHotKeyCenter.h"

@interface BinderMenulet : NSObject {
    IBOutlet NSMenu *theMenu;
    
   @private
    NSStatusItem *statusItem;
    PreferencePaneController *prefPane;
}

- (IBAction)synchronize:(id)event;
- (IBAction)displayPreferences:(id)sender;
- (IBAction)quit:(id)sender;

@end
