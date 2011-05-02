import os
import sys
import traceback
from Cocoa import *
import bindocol

def getSyncer():
    api_token = os.environ.get("BINDER_API_TOKEN", "")
    db_file = os.environ.get("BINDER_DB", "")
    return bindocol.Syncer(api_token, db_file)

def get_paths():
    return sys.argv[1:]

class SyncerAppDelegate(NSObject):
    label = objc.IBOutlet()
    window = objc.IBOutlet()

    def applicationDidFinishLaunching_(self, sender):
        NSLog("Application did finish launching.")
        try:
            syncer = getSyncer()
            syncer.sync(get_paths())
        except:
            NSLog(traceback.format_exc())
        NSLog("And terminate...")
        NSApp.terminate_(self)
    
    def awakeFromNib(self):
        NSLog("Awoken from nib.")
