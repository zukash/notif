#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

// Version
#define VERSION "1.2.0"

// Constants
static NSString * const PROCESS_NAME = @"Notification Center";
static NSString * const SUBROLE_ALERT = @"AXNotificationCenterAlert";
static NSString * const SUBROLE_STACK = @"AXNotificationCenterAlertStack";

// Get NotificationCenter window
AXUIElementRef getNotificationWindow(void) {
    NSArray *apps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSRunningApplication *app in apps) {
        if ([app.localizedName isEqualToString:PROCESS_NAME]) {
            AXUIElementRef appElement = AXUIElementCreateApplication(app.processIdentifier);
            CFArrayRef windows = NULL;
            AXError result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute, (CFTypeRef *)&windows);
            
            if (result == kAXErrorSuccess && windows && CFArrayGetCount(windows) > 0) {
                AXUIElementRef window = (AXUIElementRef)CFArrayGetValueAtIndex(windows, 0);
                CFRetain(window);
                CFRelease(windows);
                CFRelease(appElement);
                return window;
            }
            
            if (windows) CFRelease(windows);
            CFRelease(appElement);
            return NULL; // Found NotificationCenter but no window
        }
    }
    return NULL; // NotificationCenter process not found
}

// Get all buttons from window (depth-limited traversal)
NSMutableArray *getButtons(AXUIElementRef element, int depth) {
    NSMutableArray *buttons = [NSMutableArray array];
    
    if (depth > 4) return buttons;
    
    CFStringRef role = NULL;
    if (AXUIElementCopyAttributeValue(element, kAXRoleAttribute, (CFTypeRef *)&role) == kAXErrorSuccess) {
        if (role && CFStringCompare(role, CFSTR("AXButton"), 0) == kCFCompareEqualTo) {
            CFRetain(element); // Retain before bridging
            [buttons addObject:(__bridge_transfer id)element];
        }
        if (role) CFRelease(role);
    }
    
    CFArrayRef children = NULL;
    if (AXUIElementCopyAttributeValue(element, kAXChildrenAttribute, (CFTypeRef *)&children) == kAXErrorSuccess) {
        if (children) {
            CFIndex count = CFArrayGetCount(children);
            for (CFIndex i = 0; i < count; i++) {
                AXUIElementRef child = (AXUIElementRef)CFArrayGetValueAtIndex(children, i);
                NSArray *subButtons = getButtons(child, depth + 1);
                [buttons addObjectsFromArray:subButtons];
            }
            CFRelease(children);
        }
    }
    
    return buttons;
}

// Get subrole of element
NSString *getSubrole(AXUIElementRef element) {
    CFStringRef subrole = NULL;
    if (AXUIElementCopyAttributeValue(element, kAXSubroleAttribute, (CFTypeRef *)&subrole) == kAXErrorSuccess) {
        if (subrole) {
            NSString *result = (__bridge_transfer NSString *)subrole;
            return result;
        }
    }
    return nil;
}

// Check if notifications are expanded
BOOL isExpanded(NSArray *buttons) {
    for (id button in buttons) {
        AXUIElementRef elem = (__bridge AXUIElementRef)button;
        NSString *subrole = getSubrole(elem);
        if ([subrole isEqualToString:SUBROLE_ALERT]) {
            return YES;
        }
    }
    return NO;
}

// Click element
void clickElement(AXUIElementRef element) {
    AXUIElementPerformAction(element, kAXPressAction);
}

// Handle expand command
void handleExpand(void) {
    AXUIElementRef window = getNotificationWindow();
    if (!window) return;
    
    NSArray *buttons = getButtons(window, 0);
    
    // Check if already expanded
    if (isExpanded(buttons)) {
        CFRelease(window);
        return;
    }
    
    // Find and click stack button
    for (id button in buttons) {
        AXUIElementRef elem = (__bridge AXUIElementRef)button;
        NSString *subrole = getSubrole(elem);
        if ([subrole isEqualToString:SUBROLE_STACK]) {
            clickElement(elem);
            CFRelease(window);
            return;
        }
    }
    
    CFRelease(window);
}

// Handle collapse command
void handleCollapse(void) {
    AXUIElementRef window = getNotificationWindow();
    if (!window) return;
    
    NSArray *buttons = getButtons(window, 0);
    
    // Check if expanded
    if (!isExpanded(buttons)) {
        CFRelease(window);
        return;
    }
    
    // Find and click non-alert button
    for (id button in buttons) {
        AXUIElementRef elem = (__bridge AXUIElementRef)button;
        NSString *subrole = getSubrole(elem);
        if (!subrole || ![subrole isEqualToString:SUBROLE_ALERT]) {
            clickElement(elem);
            CFRelease(window);
            return;
        }
    }
    
    CFRelease(window);
}

// Handle toggle command
void handleToggle(void) {
    AXUIElementRef window = getNotificationWindow();
    if (!window) return;
    
    NSArray *buttons = getButtons(window, 0);
    
    if (isExpanded(buttons)) {
        // Collapse
        for (id button in buttons) {
            AXUIElementRef elem = (__bridge AXUIElementRef)button;
            NSString *subrole = getSubrole(elem);
            if (!subrole || ![subrole isEqualToString:SUBROLE_ALERT]) {
                clickElement(elem);
                CFRelease(window);
                return;
            }
        }
    } else {
        // Expand
        for (id button in buttons) {
            AXUIElementRef elem = (__bridge AXUIElementRef)button;
            NSString *subrole = getSubrole(elem);
            if ([subrole isEqualToString:SUBROLE_STACK]) {
                clickElement(elem);
                CFRelease(window);
                return;
            }
        }
    }
    
    CFRelease(window);
}

// Get first notification (lowest Y position)
AXUIElementRef getFirstNotification(NSArray *buttons) {
    AXUIElementRef target = NULL;
    CGFloat lowestY = CGFLOAT_MAX;
    
    for (id button in buttons) {
        AXUIElementRef elem = (__bridge AXUIElementRef)button;
        NSString *subrole = getSubrole(elem);
        
        if ([subrole isEqualToString:SUBROLE_ALERT]) {
            CFTypeRef posValue = NULL;
            if (AXUIElementCopyAttributeValue(elem, kAXPositionAttribute, &posValue) == kAXErrorSuccess) {
                if (posValue) {
                    CGPoint point;
                    if (AXValueGetValue(posValue, kAXValueCGPointType, &point)) {
                        if (point.y < lowestY) {
                            lowestY = point.y;
                            target = elem;
                        }
                    }
                    CFRelease(posValue);
                }
            }
        }
    }
    
    return target;
}

// Handle click command
void handleClick(void) {
    AXUIElementRef window = getNotificationWindow();
    if (!window) return;
    
    NSArray *buttons = getButtons(window, 0);
    AXUIElementRef notification = getFirstNotification(buttons);
    
    if (notification) {
        clickElement(notification);
    }
    
    CFRelease(window);
}

// Handle close command
void handleClose(void) {
    AXUIElementRef window = getNotificationWindow();
    if (!window) return;
    
    NSArray *buttons = getButtons(window, 0);
    AXUIElementRef notification = getFirstNotification(buttons);
    
    if (notification) {
        CFArrayRef actions = NULL;
        if (AXUIElementCopyActionNames(notification, &actions) == kAXErrorSuccess) {
            if (actions) {
                CFIndex count = CFArrayGetCount(actions);
                for (CFIndex i = 0; i < count; i++) {
                    CFStringRef action = CFArrayGetValueAtIndex(actions, i);
                    if (CFStringFind(action, CFSTR("Close"), 0).location != kCFNotFound) {
                        AXUIElementPerformAction(notification, action);
                        break;
                    }
                }
                CFRelease(actions);
            }
        }
    }
    
    CFRelease(window);
}

// Show version
void showVersion(void) {
    printf("notif version %s\n", VERSION);
}

// Show usage
void showUsage(void) {
    fprintf(stderr, 
        "notif - Minimal macOS Notification Center controller\n"
        "\n"
        "Usage: notif <command>\n"
        "\n"
        "Commands:\n"
        "    expand      Expand notification stack\n"
        "    collapse    Collapse notification stack\n"
        "    toggle      Toggle between expand/collapse\n"
        "    click       Click first notification\n"
        "    close       Close first notification\n"
        "\n"
        "Options:\n"
        "    -h, --help     Show this help message\n"
        "    -v, --version  Show version information\n"
    );
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            showUsage();
            return 1;
        }
        
        NSString *command = [NSString stringWithUTF8String:argv[1]];
        
        if ([command isEqualToString:@"expand"]) {
            handleExpand();
        } else if ([command isEqualToString:@"collapse"]) {
            handleCollapse();
        } else if ([command isEqualToString:@"toggle"]) {
            handleToggle();
        } else if ([command isEqualToString:@"click"]) {
            handleClick();
        } else if ([command isEqualToString:@"close"]) {
            handleClose();
        } else if ([command isEqualToString:@"-h"] || [command isEqualToString:@"--help"] || [command isEqualToString:@"help"]) {
            showUsage();
            return 0;
        } else if ([command isEqualToString:@"-v"] || [command isEqualToString:@"--version"]) {
            showVersion();
            return 0;
        } else {
            fprintf(stderr, "Error: Unknown command '%s'\n\n", argv[1]);
            showUsage();
            return 1;
        }
    }
    return 0;
}
