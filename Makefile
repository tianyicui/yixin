########################################
# USER VARIABLES
EXE = yixin.exe
ifdef SystemRoot
	RUN_CMD = $(EXE)
else
	RUN_CMD = ./$(EXE)
endif

PACKNAME =
SRC =
PCKDIR = ./plugins/
PCK =
PLUGIN =
PLUGINDIR =
OTHER_DEPENDS = resources/*
CONF_FILE = opa.conf

#Compiler variables
OPACOMPILER ?= opa
FLAG = --opx-dir _build
PORT = 5005

RUN_OPT = -p $(PORT)

default: exe

run: exe
	$(RUN_CMD) $(RUN_OPT) || true

include Makefile.common
