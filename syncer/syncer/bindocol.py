from Cocoa import *

class Syncer(object):
    def __init__(self, api_token, binder_db):
        NSLog(api_token)
        NSLog(binder_db)


    def sync(self, paths):
        for path in paths:
            NSLog("Syncing " + path)