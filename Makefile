VERSION		 		=	0.1.0

PREFIX		  		?=	/usr/local
DEST_BIN_DIR		=	$(PREFIX)/bin
SOURCE_BIN_DIR  	=	./bin/
SOURCE_SUPPORT_DIR	=	./support/
DEST_ZSH_DIR		=	$(PREFIX)/zsh/site-functions
LOADER		  		=	git-stream
COMMANDS			=	git-stream-init
COMMANDS			+=	git-stream-feature
COMMANDS			+=	git-stream-feature-start
COMMANDS			+=	git-stream-feature-finish
COMMANDS			+=	git-stream-feature-list
COMMANDS			+=	git-stream-hotfix
COMMANDS			+=	git-stream-hotfix-start
COMMANDS			+=	git-stream-hotfix-finish
COMMANDS			+=	git-stream-hotfix-list
COMMANDS			+=	git-stream-release
COMMANDS			+=	git-stream-release-start
COMMANDS			+=	git-stream-release-finish
COMMANDS			+=	git-stream-release-list

all:
	@echo "usage: make [test|install|uninstall]"

test:
	./tests/bats/bin/bats ./tests/specs/*

install:
	install -d -m 0755 $(DEST_BIN_DIR)
	install -d -m 0755 $(DEST_ZSH_DIR)
	cd $(SOURCE_BIN_DIR) && install -m 0755 $(LOADER) $(DEST_BIN_DIR)
	cd $(SOURCE_BIN_DIR) && install -m 0644 $(COMMANDS) $(DEST_BIN_DIR)
	cd $(SOURCE_SUPPORT_DIR) && install -m 0644 git-stream-completion.zsh $(DEST_ZSH_DIR)

uninstall:
	test -d $(DEST_BIN_DIR) && \
	cd $(DEST_BIN_DIR) && \
	rm -f $(LOADER) $(COMMANDS)