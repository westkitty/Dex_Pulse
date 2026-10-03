.PHONY: all check test app install-user verify-fixtures clean

all: app

# Single deterministic pre-commit quality gate
check:
	@echo "=== [1/6] Validating Planning and Source Constitution ==="
	@sh scripts/validate_planning_source.sh
	@echo ""
	@echo "=== [2/6] Verifying Visual Reference Fixtures ==="
	@sh scripts/verify_fixtures.sh
	@echo ""
	@echo "=== [3/6] Building Swift Package ==="
	@swift build -c release
	@echo ""
	@echo "=== [4/6] Running Unit Test Suite ==="
	@sh scripts/run_tests.sh
	@echo ""
	@echo "=== [5/6] Running Deterministic Headless Verifier ==="
	@.build/release/PulseVerification
	@echo ""
	@echo "=== [6/6] Running Diagnostic Doctor ==="
	@.build/release/dexpulse doctor
	@echo ""
	@echo "✓ ALL VERIFICATION CHECKS PASSED CLEANLY"

test:
	@sh scripts/run_tests.sh

app:
	@sh scripts/build_app.sh

install-user: app
	@sh scripts/install_user.sh

verify-fixtures:
	@sh scripts/verify_fixtures.sh

clean:
	@swift package clean
	@rm -rf build .build
