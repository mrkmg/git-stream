VERSION						=	0.8.1

PREFIX						?=	/usr/local
DEST_BIN_DIR				=	$(PREFIX)/bin
DEST_BASH_COMPLETION_DIR	=	/etc/bash_completion.d
DEST_ZSH_COMPLETION_DIR		=	/usr/share/zsh/site-functions
SOURCE_BIN_DIR				=	./bin/
SOURCE_SUPPORT_DIR			=	./support/
LOADER						=	git-stream
COMPLETION_BASH				=	git-stream-completion.bash
COMPLETION_ZSH				=	git-stream-completion.zsh
COMMANDS					=	git-stream-init
COMMANDS					+=	git-stream-feature
COMMANDS					+=	git-stream-feature-start
COMMANDS					+=	git-stream-feature-finish
COMMANDS					+=	git-stream-feature-list
COMMANDS					+=	git-stream-feature-update
COMMANDS					+=	git-stream-hotfix
COMMANDS					+=	git-stream-hotfix-start
COMMANDS					+=	git-stream-hotfix-finish
COMMANDS					+=	git-stream-hotfix-list
COMMANDS					+=	git-stream-release
COMMANDS					+=	git-stream-release-start
COMMANDS					+=	git-stream-release-finish
COMMANDS					+=	git-stream-release-list

all:
	@echo "usage: make [test|install|uninstall|install_completion|uninstall_completion]"

test:
	./tests/bats/bin/bats ./tests/specs/*

install:
	install -d -m 0755 $(DEST_BIN_DIR)
	cd $(SOURCE_BIN_DIR) && install -m 0755 $(LOADER) $(DEST_BIN_DIR)
	cd $(SOURCE_BIN_DIR) && install -m 0644 $(COMMANDS) $(DEST_BIN_DIR)

uninstall:
	test -d $(DEST_BIN_DIR) && \
	cd $(DEST_BIN_DIR) && \
	rm -f $(LOADER) $(COMMANDS)

install_completion:
	test -d $(DEST_BASH_COMPLETION_DIR) && \
	cd $(SOURCE_SUPPORT_DIR) && install -m 0644 -T $(COMPLETION_BASH) $(DEST_BASH_COMPLETION_DIR)/git-stream || true

	test -d $(DEST_ZSH_COMPLETION_DIR) && \
	cd $(SOURCE_SUPPORT_DIR) && install -m 0644 -T $(COMPLETION_ZSH) $(DEST_ZSH_COMPLETION_DIR)/_git-stream || true

uninstall_completion:
	test -d $(DEST_BASH_COMPLETION_DIR) && \
	rm -f $(DEST_BASH_COMPLETION_DIR)/git-stream

	test -d $(DEST_ZSH_COMPLETION_DIR) && \
	rm -f $(DEST_ZSH_COMPLETION_DIR)/_git-stream
