.PHONY: baseline-test build check lint tasks test verify

override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ANDROID_HOME ?= /home/gjones/android-sdk
GRADLE ?= $(ROOT)gradlew

lint:
	$(ROOT)scripts/check-baseline.sh
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" lint --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle lint skipped."; \
	fi

test:
	$(ROOT)scripts/test-data-layer-deadline.sh
	$(ROOT)scripts/test-uncaught-handler-delegation.sh
	$(ROOT)scripts/test-uncaught-handler-delegation-mutations.sh
	$(ROOT)scripts/test-crashlytics-cold-start.sh
	$(ROOT)scripts/test-crashlytics-cold-start-mutations.sh
	$(ROOT)scripts/test-wear-node-discovery-status.sh
	$(ROOT)scripts/test-wear-node-discovery-status-mutations.sh
	$(ROOT)scripts/test-wear-event-snapshots.sh
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" check --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle check skipped."; \
	fi

tasks:
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" tasks --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle tasks skipped."; \
	fi

build:
	@if [ -d "$(ANDROID_HOME)" ]; then \
		ANDROID_HOME="$(ANDROID_HOME)" $(GRADLE) --project-dir "$(ROOT)" assembleDebug --no-daemon; \
	else \
		echo "Android SDK not found at $(ANDROID_HOME); Gradle build skipped."; \
	fi

verify: lint test tasks build

baseline-test:
	$(ROOT)scripts/test-check-baseline.sh

check: verify baseline-test
