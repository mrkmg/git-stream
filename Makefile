VERSION     =   0.0.1

PREFIX      ?=  /usr/local
BIN_DIR     =   $(PREFIX)/bin
SOURCE_DIR  =   ./bin/
LOADER      =   git-stream
COMMANDS    =   git-stream-init
COMMANDS    +=  git-stream-feature
COMMANDS    +=  git-stream-feature-start
COMMANDS    +=  git-stream-feature-finish
COMMANDS    +=  git-stream-hotfix
COMMANDS    +=  git-stream-hotfix-start
COMMANDS    +=  git-stream-hotfix-finish
COMMANDS    +=  git-stream-release
COMMANDS    +=  git-stream-release-start
COMMANDS    +=  git-stream-release-finish

all:
	@echo "usage: make [install|uninstall]"

install:
	cd $(SOURCE_DIR) && \
	install -d -m 0755 $(BIN_DIR) && \
	install -m 0755 $(LOADER) $(BIN_DIR) && \
	install -m 0644 $(COMMANDS) $(BIN_DIR)

uninstall:
	test -d $(BIN_DIR) && \
	cd $(BIN_DIR) && \
	rm -f $(LOADER) $(COMMANDS)