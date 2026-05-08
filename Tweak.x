#import <UIKit/UIKit.h>
#import <substrate.h>

BOOL enableInvincible = NO;
BOOL enableOneHit = NO;
BOOL enableBurst = NO;
BOOL enableDash = NO;

UIWindow *floatWindow = nil;

@interface FloatMenuView : UIView
@property (nonatomic, strong) UISwitch *swInvincible;
@property (nonatomic, strong) UISwitch *swOneHit;
@property (nonatomic, strong) UISwitch *swBurst;
@property (nonatomic, strong) UISwitch *swDash;
@end

@implementation FloatMenuView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.layer.cornerRadius = 12;
        self.layer.borderColor = UIColor.cyanColor.CGColor;
        self.layer.borderWidth = 1;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 160, 28)];
        title.text = @"雷霆战机 多功能菜单";
        title.textColor = UIColor.cyanColor;
        title.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:title];

        UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 40, 90, 28)];
        lab1.text = @"无敌模式";
        lab1.textColor = UIColor.whiteColor;
        [self addSubview:lab1];
        _swInvincible = [[UISwitch alloc] initWithFrame:CGRectMake(110, 40, 60, 28)];
        [_swInvincible addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_swInvincible];

        UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(12, 75, 90, 28)];
        lab2.text = @"怪物秒杀";
        lab2.textColor = UIColor.whiteColor;
        [self addSubview:lab2];
        _swOneHit = [[UISwitch alloc] initWithFrame:CGRectMake(110, 75, 60, 28)];
        [_swOneHit addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_swOneHit];

        UILabel *lab3 = [[UILabel alloc] initWithFrame:CGRectMake(12, 110, 90, 28)];
        lab3.text = @"无限暴走";
        lab3.textColor = UIColor.whiteColor;
        [self addSubview:lab3];
        _swBurst = [[UISwitch alloc] initWithFrame:CGRectMake(110, 110, 60, 28)];
        [_swBurst addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_swBurst];

        UILabel *lab4 = [[UILabel alloc] initWithFrame:CGRectMake(12, 145, 90, 28)];
        lab4.text = @"无限冲刺";
        lab4.textColor = UIColor.whiteColor;
        [self addSubview:lab4];
        _swDash = [[UISwitch alloc] initWithFrame:CGRectMake(110, 145, 60, 28)];
        [_swDash addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_swDash];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)onSwitchChanged:(UISwitch *)sender {
    if (sender == self.swInvincible) enableInvincible = sender.on;
    if (sender == self.swOneHit) enableOneHit = sender.on;
    if (sender == self.swBurst) enableBurst = sender.on;
    if (sender == self.swDash) enableDash = sender.on;
}

- (void)onPan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    floatWindow.center = CGPointMake(floatWindow.center.x + translation.x, floatWindow.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}
@end

void setupFloatWindow(void) {
    floatWindow = [[UIWindow alloc] initWithFrame:CGRectMake(25, 100, 180, 190)];
    floatWindow.windowLevel = UIWindowLevelAlert + 1000;
    floatWindow.hidden = NO;
    FloatMenuView *menu = [[FloatMenuView alloc] initWithFrame:floatWindow.bounds];
    [floatWindow addSubview:menu];
}

static int (*original_ptrace)(int, pid_t, void *, int);
int hooked_ptrace(int request, pid_t pid, void *addr, int data) {
    if (request == 31 || request == 0) return 0;
    return original_ptrace(request, pid, addr, data);
}

static void *(*original_dlopen)(const char *, int);
void *hooked_dlopen(const char *path, int mode) {
    if (path && (strstr(path, "libsubstrate") || strstr(path, "libellekit") || strstr(path, "cycript"))) {
        return NULL;
    }
    return original_dlopen(path, mode);
}

%hook PlayerFightObj
- (int)hp {
    int orig = %orig;
    return enableInvincible ? 999999 : orig;
}
- (void)setHp:(int)hp {
    if (enableInvincible) hp = 999999;
    %orig(hp);
}
%end

%hook EnemyFightObj
- (int)hp {
    int orig = %orig;
    return enableOneHit ? 0 : orig;
}
- (void)setHp:(int)hp {
    if (enableOneHit) hp = 0;
    %orig(hp);
}
%end

%hook FightManager
- (BOOL)isInBurst {
    BOOL orig = %orig;
    return enableBurst ? YES : orig;
}
- (int)burstRemainTime {
    int orig = %orig;
    return enableBurst ? 9999 : orig;
}
%end

%hook DashComponent
- (BOOL)canDash {
    BOOL orig = %orig;
    return enableDash ? YES : orig;
}
- (int)dashRemainTime {
    int orig = %orig;
    return enableDash ? 9999 : orig;
}
- (void)setDashRemainTime:(int)time {
    if (enableDash) time = 9999;
    %orig(time);
}
%end

%ctor {
    @autoreleasepool {
        MSHookFunction((void *)ptrace, (void *)hooked_ptrace, (void **)&original_ptrace);
        MSHookFunction((void *)dlopen, (void *)hooked_dlopen, (void **)&original_dlopen);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            setupFloatWindow();
        });
    }
}
