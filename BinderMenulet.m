//
//  BinderMenulet.m
//  Binder
//
//  Created by dialtone on 3/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BinderMenulet.h"


@implementation BinderMenulet
- (void)dealloc {
    [statusItem release];
    [prefPane release];
    [super dealloc];
}

- (void)awakeFromNib {
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
    
    // initialize preference pane for later use
    NSBundle *bundle = [NSBundle mainBundle];
    prefPane = [[PreferencePaneController alloc] initWithBundle:bundle];
    
}

- (IBAction)displayPreferences:(id)sender {
    NSLog(@"displayPreferences");
    [prefPane displayPreferences];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:self];
}

@end
