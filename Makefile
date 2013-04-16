test:
	xcodebuild \
		-sdk iphonesimulator \
		-workspace FakeWeb.xcworkspace \
		-scheme FakeWebTests \
		-configuration Debug \
		clean build \
		ONLY_ACTIVE_ARCH=NO \
		TEST_AFTER_BUILD=YES
