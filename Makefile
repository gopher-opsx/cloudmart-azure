.PHONY: help status

help:
	@echo "CloudMart development commands"
	@echo ""
	@echo "  make status    Show repository status"

status:
	git status --short
