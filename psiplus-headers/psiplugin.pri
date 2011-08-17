TEMPLATE = lib
CONFIG += plugin
QT += xml

target.path = /usr/lib/psi-plus/plugins
INSTALLS += target

include(plugins.pri)
