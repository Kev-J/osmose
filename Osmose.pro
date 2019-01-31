
QT += core gui opengl
TARGET = osmose
TEMPLATE = app

DEPENDPATH += . cpu emulator
INCLUDEPATH += . cpu emulator /usr/share/verilator/include obj_dir


LIBS += -lz -lasound -Lobj_dir -l:Vvdp315_5124__ALL.a

# verilator
VERILOG_VDP315_5124_SOURCES += emulator/verilog/315-5124/sn76489_cpu_interface.v \
				   emulator/verilog/315-5124/sn76489_noise_generator.v \
				   emulator/verilog/315-5124/sn76489_tone_generator.v \
				   emulator/verilog/315-5124/sn76489_volume_lut.v \
				   emulator/verilog/315-5124/sn76489.v \
				   emulator/verilog/315-5124/vdp315_5124.v
VERILOG_VDP315_5124_TOP_MODULE = vdp315_5124

# TODO
verilator_vdp315_5124.target = obj_dir/Vvdp315_5124.mk
verilator_vdp315_5124.commands = verilator -Wall -cc $$VERILOG_VDP315_5124_SOURCES --top-module $$VERILOG_VDP315_5124_TOP_MODULE

verilator_vdp315_5124_archive.target = obj_dir/Vvdp315_5124__ALL.a
verilator_vdp315_5124_archive.commands = make -C obj_dir -f Vvdp315_5124.mk
verilator_vdp315_5124_archive.depends = $$verilator_vdp315_5124.target

QMAKE_EXTRA_TARGETS += verilator_vdp315_5124 verilator_vdp315_5124_archive
PRE_TARGETDEPS += $$verilator_vdp315_5124_archive.target

extraclean.commands = rm -rf obj_dir
clean.depends = extraclean
QMAKE_EXTRA_TARGETS += clean extraclean

system-minizip {
    LIBS += -lminizip
    DEFINES += SYSTEM_MINIZIP
} else {
    DEPENDPATH += unzip
    INCLUDEPATH += unzip
    HEADERS += unzip/crypt.h \
               unzip/ioapi.h \
               unzip/unzip.h
    SOURCES += unzip/ioapi.c \
               unzip/unzip.c
}

FLAGS = -Wall -Wextra -Wunused -Wcast-qual
QMAKE_CXXFLAGS += -std=c++11 $$FLAGS
QMAKE_CFLAGS += -Wmissing-prototypes -Wshadow  $$FLAGS

# Input
HEADERS += EmulationThread.h \
           Joystick.h \
           KeyMapper.h \
           OsmoseConfigurationFile.h \
           OsmoseEmulationThread.h \
           OsmoseGUI.h \
           Pthreadcpp.h \
           QGLImage.h \
           QLogWindow.h \
           QOsmoseConfiguration.h \
           TGAWriter.h \
           WhiteNoiseEmulationThread.h \
           cpu/BasicTypes.h \
           cpu/Z80.h \
           emulator/AnsiColorTerminal.h \
           emulator/Bits.h \
           emulator/DebugEventListener.h \
           emulator/DebugEventThrower.h \
           emulator/Definitions.h \
           emulator/FIFOSoundBuffer.h \
           emulator/IOMapper.h \
           emulator/IOMapper_GG.h \
           emulator/MemoryMapper.h \
           emulator/Options.h \
           emulator/OsmoseCore.h \
           emulator/RomSpecificOption.h \
           emulator/SaveState.h \
           emulator/SmsDebugger.h \
           emulator/SmsEnvironment.h \
           emulator/SN76489.h \
           emulator/SoundThread.h \
           emulator/VDP.h \
           emulator/VDP_GG.h \
           emulator/Version.h \
           emulator/WaveWriter.h

SOURCES += EmulationThread.cpp \
           Joystick.cpp \
           KeyMapper.cpp \
           main.cpp \
           OsmoseConfigurationFile.cpp \
           OsmoseEmulationThread.cpp \
           OsmoseGUI.cpp \
           Pthreadcpp.cpp \
           QGLImage.cpp \
           QLogWindow.cpp \
           QOsmoseConfiguration.cpp \
           TGAWriter.cpp \
           WhiteNoiseEmulationThread.cpp \
           cpu/Opc_cbxx.cpp \
           cpu/Opc_dd.cpp \
           cpu/Opc_ddcb.cpp \
           cpu/Opc_ed.cpp \
           cpu/Opc_fd.cpp \
           cpu/Opc_fdcb.cpp \
           cpu/Opc_std.cpp \
           cpu/Z80.cpp \
           emulator/DebugEventThrower.cpp \
           emulator/FIFOSoundBuffer.cpp \
           emulator/IOMapper.cpp \
           emulator/IOMapper_GG.cpp \
           emulator/MemoryMapper.cpp \
           emulator/Options.cpp \
           emulator/OsmoseCore.cpp \
           emulator/RomSpecificOption.cpp \
           emulator/SmsEnvironment.cpp \
           emulator/SN76489.cpp \
           emulator/SoundThread.cpp \
           emulator/VDP.cpp \
           emulator/VDP_GG.cpp \
           emulator/WaveWriter.cpp \
		   /usr/share/verilator/include/verilated.cpp

FORMS += Configuration.ui LogWindow.ui

# Installation
isEmpty(PREFIX) {
    PREFIX = /usr/local
}

isEmpty(ICONDIR) {
    ICONDIR = $$PREFIX/share/icons/hicolor/128x128/apps
}
DEFINES += ICONDIR=\\\"$$ICONDIR\\\"

target.path = $$PREFIX/games/

icon.path = $$ICONDIR/
icon.files = osmose.png

desktop.path = $$PREFIX/share/applications/
desktop.files = osmose.desktop

INSTALLS += target icon desktop
