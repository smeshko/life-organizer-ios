#!/bin/bash

# Xcode Project Generator Script
# Regenerates the Xcode project file from the template

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check if we're in a project directory
if [ ! -f "Package.swift" ]; then
    print_error "Package.swift not found. This script must be run from the project root."
    echo ""
    echo "Usage: Run this script from your project root directory:"
    echo "  cd /path/to/your-project"
    echo "  ./scripts/generate-xcodeproj.sh"
    exit 1
fi

# Detect project name from directory
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
PROJECT_KIT="${PROJECT_NAME}Kit"

print_header "Xcode Project Regeneration"
print_info "Project: $PROJECT_NAME"
print_info "Location: $PROJECT_DIR"
echo ""

# Warn about destructive operation
print_warning "This will REPLACE your existing Xcode project!"
print_warning "Any custom Xcode project settings will be lost."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Operation cancelled"
    exit 0
fi

# Remove existing xcodeproj if it exists
if [ -d "$PROJECT_NAME.xcodeproj" ]; then
    print_info "Backing up existing project..."
    mv "$PROJECT_NAME.xcodeproj" "$PROJECT_NAME.xcodeproj.backup.$(date +%Y%m%d_%H%M%S)"
    print_success "Backup created"
fi

# Generate UUID function
generate_uuid() {
    uuidgen | tr -d '-' | cut -c 1-24 | tr '[:lower:]' '[:upper:]'
}

print_info "Creating new Xcode project structure..."

# Create directory structure
mkdir -p "$PROJECT_NAME.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/configuration"
mkdir -p "$PROJECT_NAME.xcodeproj/xcshareddata/xcschemes"

# Generate UUIDs
UUID_APPFEATURE_BUILDFILE=$(generate_uuid)
UUID_APPFEATURE_PRODUCTREF=$(generate_uuid)
UUID_CONTRIBUTING_BUILDFILE=$(generate_uuid)
UUID_CONTRIBUTING_FILEREF=$(generate_uuid)
UUID_APP_PRODUCT=$(generate_uuid)
UUID_KIT_FILEREF=$(generate_uuid)
UUID_APP_ROOTGROUP=$(generate_uuid)
UUID_FRAMEWORKS_PHASE=$(generate_uuid)
UUID_ROOT_GROUP=$(generate_uuid)
UUID_PRODUCTS_GROUP=$(generate_uuid)
UUID_FRAMEWORKS_GROUP=$(generate_uuid)
UUID_NATIVE_TARGET=$(generate_uuid)
UUID_TARGET_CONFIGLIST=$(generate_uuid)
UUID_SOURCES_PHASE=$(generate_uuid)
UUID_RESOURCES_PHASE=$(generate_uuid)
UUID_PROJECT=$(generate_uuid)
UUID_PROJECT_CONFIGLIST=$(generate_uuid)
UUID_DEBUG_CONFIG=$(generate_uuid)
UUID_RELEASE_CONFIG=$(generate_uuid)
UUID_TARGET_DEBUG=$(generate_uuid)
UUID_TARGET_RELEASE=$(generate_uuid)
UUID_LOCAL_PACKAGE_REF=$(generate_uuid)

# Create project.pbxproj (embedded here for portability)
cat > "$PROJECT_NAME.xcodeproj/project.pbxproj" << 'PBXPROJ_EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 77;
	objects = {

/* Begin PBXBuildFile section */
		__UUID_APPFEATURE_BUILDFILE__ /* AppFeature in Frameworks */ = {isa = PBXBuildFile; productRef = __UUID_APPFEATURE_PRODUCTREF__ /* AppFeature */; };
		__UUID_CONTRIBUTING_BUILDFILE__ /* CONTRIBUTING.md in Resources */ = {isa = PBXBuildFile; fileRef = __UUID_CONTRIBUTING_FILEREF__ /* CONTRIBUTING.md */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		__UUID_APP_PRODUCT__ /* __PROJECT_NAME__.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "__PROJECT_NAME__.app"; sourceTree = BUILT_PRODUCTS_DIR; };
		__UUID_KIT_FILEREF__ /* __PROJECT_KIT__ */ = {isa = PBXFileReference; lastKnownFileType = wrapper; path = "__PROJECT_KIT__"; sourceTree = "<group>"; };
		__UUID_CONTRIBUTING_FILEREF__ /* CONTRIBUTING.md */ = {isa = PBXFileReference; lastKnownFileType = net.daringfireball.markdown; path = CONTRIBUTING.md; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
		__UUID_APP_ROOTGROUP__ /* __PROJECT_NAME__ */ = {
			isa = PBXFileSystemSynchronizedRootGroup;
			path = "__PROJECT_NAME__";
			sourceTree = "<group>";
		};
/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
		__UUID_FRAMEWORKS_PHASE__ /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
				__UUID_APPFEATURE_BUILDFILE__ /* AppFeature in Frameworks */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		__UUID_ROOT_GROUP__ = {
			isa = PBXGroup;
			children = (
				__UUID_CONTRIBUTING_FILEREF__ /* CONTRIBUTING.md */,
				__UUID_KIT_FILEREF__ /* __PROJECT_KIT__ */,
				__UUID_APP_ROOTGROUP__ /* __PROJECT_NAME__ */,
				__UUID_FRAMEWORKS_GROUP__ /* Frameworks */,
				__UUID_PRODUCTS_GROUP__ /* Products */,
			);
			sourceTree = "<group>";
		};
		__UUID_PRODUCTS_GROUP__ /* Products */ = {
			isa = PBXGroup;
			children = (
				__UUID_APP_PRODUCT__ /* __PROJECT_NAME__.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		__UUID_FRAMEWORKS_GROUP__ /* Frameworks */ = {
			isa = PBXGroup;
			children = (
			);
			name = Frameworks;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		__UUID_NATIVE_TARGET__ /* __PROJECT_NAME__ */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = __UUID_TARGET_CONFIGLIST__ /* Build configuration list for PBXNativeTarget "__PROJECT_NAME__" */;
			buildPhases = (
				__UUID_SOURCES_PHASE__ /* Sources */,
				__UUID_FRAMEWORKS_PHASE__ /* Frameworks */,
				__UUID_RESOURCES_PHASE__ /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			fileSystemSynchronizedGroups = (
				__UUID_APP_ROOTGROUP__ /* __PROJECT_NAME__ */,
			);
			name = "__PROJECT_NAME__";
			packageProductDependencies = (
				__UUID_APPFEATURE_PRODUCTREF__ /* AppFeature */,
			);
			productName = "__PROJECT_NAME__";
			productReference = __UUID_APP_PRODUCT__ /* __PROJECT_NAME__.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		__UUID_PROJECT__ /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1620;
				LastUpgradeCheck = 1620;
				TargetAttributes = {
					__UUID_NATIVE_TARGET__ = {
						CreatedOnToolsVersion = 16.2;
					};
				};
			};
			buildConfigurationList = __UUID_PROJECT_CONFIGLIST__ /* Build configuration list for PBXProject "__PROJECT_NAME__" */;
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = __UUID_ROOT_GROUP__;
			minimizedProjectReferenceProxies = 1;
			preferredProjectObjectVersion = 77;
			productRefGroup = __UUID_PRODUCTS_GROUP__ /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				__UUID_NATIVE_TARGET__ /* __PROJECT_NAME__ */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		__UUID_RESOURCES_PHASE__ /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				__UUID_CONTRIBUTING_BUILDFILE__ /* CONTRIBUTING.md in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		__UUID_SOURCES_PHASE__ /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		__UUID_DEBUG_CONFIG__ /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 6.0;
			};
			name = Debug;
		};
		__UUID_RELEASE_CONFIG__ /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 6.0;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		__UUID_TARGET_DEBUG__ /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"__PROJECT_NAME__/Preview Content\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.example.__PROJECT_NAME__";
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		__UUID_TARGET_RELEASE__ /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"__PROJECT_NAME__/Preview Content\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 18.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = "com.example.__PROJECT_NAME__";
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		__UUID_PROJECT_CONFIGLIST__ /* Build configuration list for PBXProject "__PROJECT_NAME__" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				__UUID_DEBUG_CONFIG__ /* Debug */,
				__UUID_RELEASE_CONFIG__ /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		__UUID_TARGET_CONFIGLIST__ /* Build configuration list for PBXNativeTarget "__PROJECT_NAME__" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				__UUID_TARGET_DEBUG__ /* Debug */,
				__UUID_TARGET_RELEASE__ /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

/* Begin XCLocalSwiftPackageReference section */
		__UUID_LOCAL_PACKAGE_REF__ /* __PROJECT_KIT__ */ = {
			isa = XCLocalSwiftPackageReference;
			relativePath = "__PROJECT_KIT__";
		};
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		__UUID_APPFEATURE_PRODUCTREF__ /* AppFeature */ = {
			isa = XCSwiftPackageProductDependency;
			package = __UUID_LOCAL_PACKAGE_REF__ /* __PROJECT_KIT__ */;
			productName = AppFeature;
		};
/* End XCSwiftPackageProductDependency section */
	};
	rootObject = __UUID_PROJECT__ /* Project object */;
}
PBXPROJ_EOF

# Replace placeholders
print_info "Customizing project file..."
sed -i '' "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__PROJECT_KIT__/$PROJECT_KIT/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"

# Replace UUIDs
sed -i '' "s/__UUID_APPFEATURE_BUILDFILE__/$UUID_APPFEATURE_BUILDFILE/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_APPFEATURE_PRODUCTREF__/$UUID_APPFEATURE_PRODUCTREF/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_CONTRIBUTING_BUILDFILE__/$UUID_CONTRIBUTING_BUILDFILE/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_CONTRIBUTING_FILEREF__/$UUID_CONTRIBUTING_FILEREF/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_APP_PRODUCT__/$UUID_APP_PRODUCT/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_KIT_FILEREF__/$UUID_KIT_FILEREF/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_APP_ROOTGROUP__/$UUID_APP_ROOTGROUP/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_FRAMEWORKS_PHASE__/$UUID_FRAMEWORKS_PHASE/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_ROOT_GROUP__/$UUID_ROOT_GROUP/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_PRODUCTS_GROUP__/$UUID_PRODUCTS_GROUP/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_FRAMEWORKS_GROUP__/$UUID_FRAMEWORKS_GROUP/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_NATIVE_TARGET__/$UUID_NATIVE_TARGET/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_TARGET_CONFIGLIST__/$UUID_TARGET_CONFIGLIST/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_SOURCES_PHASE__/$UUID_SOURCES_PHASE/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_RESOURCES_PHASE__/$UUID_RESOURCES_PHASE/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_PROJECT__/$UUID_PROJECT/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_PROJECT_CONFIGLIST__/$UUID_PROJECT_CONFIGLIST/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_DEBUG_CONFIG__/$UUID_DEBUG_CONFIG/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_RELEASE_CONFIG__/$UUID_RELEASE_CONFIG/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_TARGET_DEBUG__/$UUID_TARGET_DEBUG/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_TARGET_RELEASE__/$UUID_TARGET_RELEASE/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"
sed -i '' "s/__UUID_LOCAL_PACKAGE_REF__/$UUID_LOCAL_PACKAGE_REF/g" "$PROJECT_NAME.xcodeproj/project.pbxproj"

# Create workspace content
cat > "$PROJECT_NAME.xcodeproj/project.xcworkspace/contents.xcworkspacedata" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
EOF

# Create Package.resolved stub
cat > "$PROJECT_NAME.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/configuration/Package.resolved" << 'EOF'
{
  "originHash" : "placeholder",
  "pins" : [],
  "version" : 3
}
EOF

# Create scheme
cat > "$PROJECT_NAME.xcodeproj/xcshareddata/xcschemes/$PROJECT_NAME.xcscheme" << SCHEME_EOF
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1620"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES"
      buildArchitectures = "Automatic">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "$UUID_NATIVE_TARGET"
               BuildableName = "$PROJECT_NAME.app"
               BlueprintName = "$PROJECT_NAME"
               ReferencedContainer = "container:$PROJECT_NAME.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "$UUID_NATIVE_TARGET"
            BuildableName = "$PROJECT_NAME.app"
            BlueprintName = "$PROJECT_NAME"
            ReferencedContainer = "container:$PROJECT_NAME.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "$UUID_NATIVE_TARGET"
            BuildableName = "$PROJECT_NAME.app"
            BlueprintName = "$PROJECT_NAME"
            ReferencedContainer = "container:$PROJECT_NAME.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME_EOF

print_success "Xcode project generated successfully!"

print_header "✓ Regeneration Complete!"
echo ""
echo "Your Xcode project has been regenerated with:"
echo "  • Fresh unique UUIDs"
echo "  • Embedded $PROJECT_KIT package reference"
echo "  • Standard build configuration"
echo "  • AppFeature dependency configured"
echo ""
echo "You can now open $PROJECT_NAME.xcodeproj in Xcode"
echo ""
