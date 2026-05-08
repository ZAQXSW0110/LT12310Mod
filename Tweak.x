#import <substrate.h>
#import "CCWindow.h"

static BOOL godMode = NO;

%hook GamePlayer
- (void)takeDamage:(int)damage {
    if (godMode) damage = 0;
    %orig(damage);
}
%end

%ctor {
    @autoreleasepool {
        createOverlay();  // 创建悬浮窗
        MSHookMessageEx(objc_getClass("GamePlayer"), @selector(takeDamage:), 
                       (IMP)hooked_takeDamage, (IMP*)&original_takeDamage);
    }
}
