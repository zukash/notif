# Makefile for notif - macOS Notification Center controller

CC = clang
CFLAGS = -framework Foundation -framework ApplicationServices -framework AppKit -fobjc-arc
ARCH_FLAGS = -arch arm64 -arch x86_64
TARGET = notif
SOURCE = notif.m
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin

.PHONY: all clean install uninstall test

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) -o $(TARGET) $(SOURCE) $(CFLAGS) $(ARCH_FLAGS)

clean:
	rm -f $(TARGET)

install: $(TARGET)
	install -d $(BINDIR)
	install -m 755 $(TARGET) $(BINDIR)/$(TARGET)

uninstall:
	rm -f $(BINDIR)/$(TARGET)

test: $(TARGET)
	@echo "Testing notif binary..."
	@./$(TARGET) --version
	@./$(TARGET) --help > /dev/null 2>&1 && echo "✓ Help display works"
	@echo "✓ All tests passed"
