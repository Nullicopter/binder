//
//  main.m
//  syncer
//
//  Created by dialtone on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Python/Python.h>
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourcePath = [mainBundle resourcePath];

    NSArray *pythonPathArray = [NSArray
                                arrayWithObjects:resourcePath, [resourcePath stringByAppendingPathComponent:@"PyObjC"], nil];

    setenv("PYTHONPATH", "/Users/dialtone/dev/Null/binder/syncer:/Users/dialtone/dev/Null/binder/syncer/syncer:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python26.zip:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6/plat-darwin:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6/plat-mac:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6/plat-mac/lib-scriptpackages:/System/Library/Frameworks/Python.framework/Versions/2.6/Extras/lib/python:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6/lib-tk:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6/lib-old:/System/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6/lib-dynload:/Library/Python/2.6/site-packages:/System/Library/Frameworks/Python.framework/Versions/2.6/Extras/lib/python/PyObjC:/System/Library/Frameworks/Python.framework/Versions/2.6/Extras/lib/python/wx-2.8-mac-unicode", 1);
    
    NSArray *keys = [NSArray arrayWithObjects:@"BINDER_API_TOKEN", @"BINDER_DB", nil];
    int i=0;
    char *keyValue;
    char *currentKey;
    for (i=0; i < [keys count]; i++) {
        keyValue = NULL;
        currentKey = (char *)[[keys objectAtIndex:i] UTF8String];
        
        keyValue = getenv(currentKey);
        if (keyValue != NULL) {
            NSLog(@"Forwarding %s=>%s to application", currentKey, keyValue);
            setenv(currentKey, keyValue, 1);
        } else {
            NSLog(@"%s was not provided, not forwarded", currentKey);
        }
    }

    NSArray *possibleMainExtensions = [NSArray arrayWithObjects: @"py", @"pyc", @"pyo", nil];
    NSString *mainFilePath = nil;
    for (NSString *possibleMainExtension in possibleMainExtensions) {
        mainFilePath = [mainBundle pathForResource: @"main" ofType: possibleMainExtension];
        if ( mainFilePath != nil ) break;
    }
    
    if ( !mainFilePath ) {
        [NSException raise: NSInternalInconsistencyException format: @"%s:%d main() Failed to find the main.{py,pyc,pyo} file in the application wrapper's Resources directory.", __FILE__, __LINE__];
    }
    
    Py_SetProgramName("/usr/bin/python");
    Py_Initialize();
    NSLog(@"Ready...");
    PySys_SetArgv(argc, (char **)argv);
    
    const char *mainFilePathPtr = [mainFilePath UTF8String];
    FILE *mainFile = fopen(mainFilePathPtr, "r");
    int result = PyRun_SimpleFile(mainFile, (char *)[[mainFilePath lastPathComponent] UTF8String]);
    
    if ( result != 0 )
        [NSException raise: NSInternalInconsistencyException
                    format: @"%s:%d main() PyRun_SimpleFile failed with file '%@'.  See console for errors.", __FILE__, __LINE__, mainFilePath];
    
    [pool drain];
    
    return result;
}
