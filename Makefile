ARCHS = arm64
TARGET = iphone:clang:16.0:15.0
INSTALL_TARGET_PROCESSES = 雷霆战机:集结

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LT12310Mod
LT12310Mod_FILES = Tweak.x
LT12310Mod_CFLAGS = -fobjc-arc -w
LT12310Mod_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
