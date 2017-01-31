# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-droplet

QT += dbus gui-private

CONFIG += sailfishapp c++11

HEADERS += \
    src/appletview.h \
    src/droplethelper.h

SOURCES += src/harbour-droplet.cpp \
    src/appletview.cpp \
    src/droplethelper.cpp

OTHER_FILES += \
    rpm/harbour-droplet.changes \
    rpm/harbour-droplet.spec \
    rpm/harbour-droplet.yaml \
    translations/*.ts \
    harbour-droplet.desktop \
    open-url-droplet.desktop \
    net.garageresearch.droplet.service \

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-droplet-de.ts

DISTFILES += \
    qml/droplet-browser-overlay.qml \
    qml/harbour-droplet.qml \
    qml/cover/CoverPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/AboutPage.qml \
    qml/components/Bubble.qml \
    qml/js/devicePixelRatioHack.js \
    qml/js/userscript.js \
    qml/js/favicon.js \
    qml/images/Logo.svg \
    qml/components/TrashCan.qml \
    qml/components/Tab.qml \
    qml/components/TabHeaderButton.qml \
    qml/components/BubbleStack.qml \
    qml/models/SettingsModel.qml \
    qml/pages/FirstRunPage.qml \
    qml/models/HistoryModel.qml \
    qml/pages/MainPage.qml \
    qml/components/Toast.qml \
    qml/models/BookmarksModel.qml \
    qml/models/TabModel.qml \
    qml/pages/HistoryPage.qml

urlhandler.files = open-url-droplet.desktop
urlhandler.path = /usr/share/harbour-droplet/

dbus.files = net.garageresearch.droplet.service
dbus.path = /usr/share/dbus-1/services/

INSTALLS += dbus urlhandler
