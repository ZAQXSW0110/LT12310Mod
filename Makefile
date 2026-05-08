export THEOS = /opt/theos
include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e
TARGET = iphone:clang:17.6.1:17.0

TWEAK_NAME = ThunderHack
ThunderHack_FILES = Tweak/Tweak.xm Tweak/CCWindow.m
ThunderHack_CFLAGS = -fno-objc-arc -I./include
ThunderHack_LDFLAGS = -lsubstrate -L./lib

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
    install.exec "killall -9 SpringBoard"
