ARCHS = arm64
TARGET = iphone:clang:15.0:15.0
INSTALL_TARGET_PROCESSES = 雷霆战机:集结

# 关键：强制指定SDK路径，避免Theos找不到
SYSROOT = $(THEOS)/sdks/iPhoneOS15.0.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LT12310Mod
LT12310Mod_FILES = Tweak.x
LT12310Mod_CFLAGS = -fobjc-arc -w
LT12310Mod_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
