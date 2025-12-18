#!/usr/bin/env python3
"""
Generate Xcode project for AI Agent Coordinator visionOS app
"""

import os
import uuid
import json

# Generate UUIDs for project elements
def gen_uuid():
    return uuid.uuid4().hex[:24].upper()

# File references
file_refs = {}
group_refs = {}

# Collect all Swift files
swift_files = []
for root, dirs, files in os.walk('AIAgentCoordinator'):
    # Skip Tests directory in main target
    if 'Tests' in root.split(os.sep):
        continue
    for file in files:
        if file.endswith('.swift'):
            rel_path = os.path.join(root, file)
            swift_files.append(rel_path)

test_files = []
for root, dirs, files in os.walk('AIAgentCoordinator/Tests'):
    for file in files:
        if file.endswith('.swift'):
            rel_path = os.path.join(root, file)
            test_files.append(rel_path)

# Generate file references
for f in swift_files:
    file_refs[f] = gen_uuid()

for f in test_files:
    file_refs[f] = gen_uuid()

# Generate group references
groups = ['App', 'Models', 'Views', 'Services', 'Utilities', 'Views/Windows', 'Views/Volumes', 'Views/ImmersiveViews', 'Tests']
for g in groups:
    group_refs[g] = gen_uuid()

# Main project references
MAINGROUP = gen_uuid()
PROJECT_REF = gen_uuid()
PRODUCTS_GROUP = gen_uuid()
TARGET_REF = gen_uuid()
TEST_TARGET_REF = gen_uuid()
APP_PRODUCT_REF = gen_uuid()
TEST_PRODUCT_REF = gen_uuid()
BUILD_CONFIG_LIST_PROJECT = gen_uuid()
BUILD_CONFIG_LIST_TARGET = gen_uuid()
BUILD_CONFIG_LIST_TEST = gen_uuid()
DEBUG_CONFIG_PROJECT = gen_uuid()
RELEASE_CONFIG_PROJECT = gen_uuid()
DEBUG_CONFIG_TARGET = gen_uuid()
RELEASE_CONFIG_TARGET = gen_uuid()
DEBUG_CONFIG_TEST = gen_uuid()
RELEASE_CONFIG_TEST = gen_uuid()
SOURCES_BUILD_PHASE = gen_uuid()
FRAMEWORKS_BUILD_PHASE = gen_uuid()
RESOURCES_BUILD_PHASE = gen_uuid()
TEST_SOURCES_BUILD_PHASE = gen_uuid()
TEST_FRAMEWORKS_BUILD_PHASE = gen_uuid()

# Build file references
build_file_refs = {}
for f in swift_files:
    build_file_refs[f] = gen_uuid()

test_build_file_refs = {}
for f in test_files:
    test_build_file_refs[f] = gen_uuid()

# Generate project.pbxproj content
pbxproj_content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 60;
	objects = {{

/* Begin PBXBuildFile section */
"""

# Add build files for sources
for f in swift_files:
    pbxproj_content += f"		{build_file_refs[f]} /* {os.path.basename(f)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[f]} /* {os.path.basename(f)} */; }};\n"

# Add build files for test sources
for f in test_files:
    pbxproj_content += f"		{test_build_file_refs[f]} /* {os.path.basename(f)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[f]} /* {os.path.basename(f)} */; }};\n"

pbxproj_content += """/* End PBXBuildFile section */

/* Begin PBXFileReference section */
"""

# Add file references
pbxproj_content += f"		{APP_PRODUCT_REF} /* AIAgentCoordinator.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = AIAgentCoordinator.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
pbxproj_content += f"		{TEST_PRODUCT_REF} /* AIAgentCoordinatorTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = AIAgentCoordinatorTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};\n"

for f in swift_files + test_files:
    pbxproj_content += f"		{file_refs[f]} /* {os.path.basename(f)} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{os.path.basename(f)}\"; sourceTree = \"<group>\"; }};\n"

pbxproj_content += f"""/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{FRAMEWORKS_BUILD_PHASE} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{TEST_FRAMEWORKS_BUILD_PHASE} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{MAINGROUP} = {{
			isa = PBXGroup;
			children = (
				{group_refs['App']} /* App */,
				{group_refs['Models']} /* Models */,
				{group_refs['Views']} /* Views */,
				{group_refs['Services']} /* Services */,
				{group_refs['Utilities']} /* Utilities */,
				{group_refs['Tests']} /* Tests */,
				{PRODUCTS_GROUP} /* Products */,
			);
			path = AIAgentCoordinator;
			sourceTree = "<group>";
		}};
		{PRODUCTS_GROUP} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{APP_PRODUCT_REF} /* AIAgentCoordinator.app */,
				{TEST_PRODUCT_REF} /* AIAgentCoordinatorTests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
"""

# Add group for App
app_files = [f for f in swift_files if 'App/' in f]
pbxproj_content += f"		{group_refs['App']} /* App */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in app_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = App;\n			sourceTree = \"<group>\";\n		};\n"

# Add group for Models
model_files = [f for f in swift_files if 'Models/' in f]
pbxproj_content += f"		{group_refs['Models']} /* Models */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in model_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = Models;\n			sourceTree = \"<group>\";\n		};\n"

# Add group for Services
service_files = [f for f in swift_files if 'Services/' in f]
pbxproj_content += f"		{group_refs['Services']} /* Services */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in service_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = Services;\n			sourceTree = \"<group>\";\n		};\n"

# Add group for Utilities
utility_files = [f for f in swift_files if 'Utilities/' in f]
pbxproj_content += f"		{group_refs['Utilities']} /* Utilities */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in utility_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = Utilities;\n			sourceTree = \"<group>\";\n		};\n"

# Add group for Views
pbxproj_content += f"		{group_refs['Views']} /* Views */ = {{\n			isa = PBXGroup;\n			children = (\n"
pbxproj_content += f"				{group_refs['Views/Windows']} /* Windows */,\n"
pbxproj_content += f"				{group_refs['Views/Volumes']} /* Volumes */,\n"
pbxproj_content += f"				{group_refs['Views/ImmersiveViews']} /* ImmersiveViews */,\n"
pbxproj_content += "			);\n			path = Views;\n			sourceTree = \"<group>\";\n		};\n"

# Add subgroups for Views
windows_files = [f for f in swift_files if 'Views/Windows/' in f]
pbxproj_content += f"		{group_refs['Views/Windows']} /* Windows */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in windows_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = Windows;\n			sourceTree = \"<group>\";\n		};\n"

volumes_files = [f for f in swift_files if 'Views/Volumes/' in f]
pbxproj_content += f"		{group_refs['Views/Volumes']} /* Volumes */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in volumes_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = Volumes;\n			sourceTree = \"<group>\";\n		};\n"

immersive_files = [f for f in swift_files if 'Views/ImmersiveViews/' in f]
pbxproj_content += f"		{group_refs['Views/ImmersiveViews']} /* ImmersiveViews */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in immersive_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = ImmersiveViews;\n			sourceTree = \"<group>\";\n		};\n"

# Add group for Tests
pbxproj_content += f"		{group_refs['Tests']} /* Tests */ = {{\n			isa = PBXGroup;\n			children = (\n"
for f in test_files:
    pbxproj_content += f"				{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += "			);\n			path = Tests;\n			sourceTree = \"<group>\";\n		};\n"

pbxproj_content += f"""/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{TARGET_REF} /* AIAgentCoordinator */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {BUILD_CONFIG_LIST_TARGET} /* Build configuration list for PBXNativeTarget "AIAgentCoordinator" */;
			buildPhases = (
				{SOURCES_BUILD_PHASE} /* Sources */,
				{FRAMEWORKS_BUILD_PHASE} /* Frameworks */,
				{RESOURCES_BUILD_PHASE} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = AIAgentCoordinator;
			productName = AIAgentCoordinator;
			productReference = {APP_PRODUCT_REF} /* AIAgentCoordinator.app */;
			productType = "com.apple.product-type.application";
		}};
		{TEST_TARGET_REF} /* AIAgentCoordinatorTests */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {BUILD_CONFIG_LIST_TEST} /* Build configuration list for PBXNativeTarget "AIAgentCoordinatorTests" */;
			buildPhases = (
				{TEST_SOURCES_BUILD_PHASE} /* Sources */,
				{TEST_FRAMEWORKS_BUILD_PHASE} /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = AIAgentCoordinatorTests;
			productName = AIAgentCoordinatorTests;
			productReference = {TEST_PRODUCT_REF} /* AIAgentCoordinatorTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{PROJECT_REF} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1610;
				LastUpgradeCheck = 1610;
				TargetAttributes = {{
					{TARGET_REF} = {{
						CreatedOnToolsVersion = 16.1;
					}};
				}};
			}};
			buildConfigurationList = {BUILD_CONFIG_LIST_PROJECT} /* Build configuration list for PBXProject "AIAgentCoordinator" */;
			compatibilityVersion = "Xcode 15.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {MAINGROUP};
			productRefGroup = {PRODUCTS_GROUP} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{TARGET_REF} /* AIAgentCoordinator */,
				{TEST_TARGET_REF} /* AIAgentCoordinatorTests */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{RESOURCES_BUILD_PHASE} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{SOURCES_BUILD_PHASE} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
"""

# Add source build files
for f in swift_files:
    pbxproj_content += f"				{build_file_refs[f]} /* {os.path.basename(f)} in Sources */,\n"

pbxproj_content += f"""			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{TEST_SOURCES_BUILD_PHASE} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
"""

# Add test source build files
for f in test_files:
    pbxproj_content += f"				{test_build_file_refs[f]} /* {os.path.basename(f)} in Sources */,\n"

pbxproj_content += f"""			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{DEBUG_CONFIG_PROJECT} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
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
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = xros;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 6.0;
				XROS_DEPLOYMENT_TARGET = 2.0;
			}};
			name = Debug;
		}};
		{RELEASE_CONFIG_PROJECT} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
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
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = xros;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 6.0;
				VALIDATE_PRODUCT = YES;
				XROS_DEPLOYMENT_TARGET = 2.0;
			}};
			name = Release;
		}};
		{DEBUG_CONFIG_TARGET} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.aiagent.coordinator;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = xros;
				SUPPORTED_PLATFORMS = "xros xrsimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = 7;
				XROS_DEPLOYMENT_TARGET = 2.0;
			}};
			name = Debug;
		}};
		{RELEASE_CONFIG_TARGET} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.aiagent.coordinator;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = xros;
				SUPPORTED_PLATFORMS = "xros xrsimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = 7;
				XROS_DEPLOYMENT_TARGET = 2.0;
			}};
			name = Release;
		}};
		{DEBUG_CONFIG_TEST} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.aiagent.coordinator.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = xros;
				SUPPORTED_PLATFORMS = "xros xrsimulator";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = 7;
				XROS_DEPLOYMENT_TARGET = 2.0;
			}};
			name = Debug;
		}};
		{RELEASE_CONFIG_TEST} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.aiagent.coordinator.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = xros;
				SUPPORTED_PLATFORMS = "xros xrsimulator";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 6.0;
				TARGETED_DEVICE_FAMILY = 7;
				XROS_DEPLOYMENT_TARGET = 2.0;
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{BUILD_CONFIG_LIST_PROJECT} /* Build configuration list for PBXProject "AIAgentCoordinator" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{DEBUG_CONFIG_PROJECT} /* Debug */,
				{RELEASE_CONFIG_PROJECT} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{BUILD_CONFIG_LIST_TARGET} /* Build configuration list for PBXNativeTarget "AIAgentCoordinator" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{DEBUG_CONFIG_TARGET} /* Debug */,
				{RELEASE_CONFIG_TARGET} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{BUILD_CONFIG_LIST_TEST} /* Build configuration list for PBXNativeTarget "AIAgentCoordinatorTests" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{DEBUG_CONFIG_TEST} /* Debug */,
				{RELEASE_CONFIG_TEST} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {PROJECT_REF} /* Project object */;
}}
"""

# Create the .xcodeproj directory structure
os.makedirs('AIAgentCoordinator.xcodeproj', exist_ok=True)

# Write the project file
with open('AIAgentCoordinator.xcodeproj/project.pbxproj', 'w') as f:
    f.write(pbxproj_content)

# Create xcschemes directory
os.makedirs('AIAgentCoordinator.xcodeproj/xcshareddata/xcschemes', exist_ok=True)

# Create scheme file
scheme_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1610"
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
               BlueprintIdentifier = "{TARGET_REF}"
               BuildableName = "AIAgentCoordinator.app"
               BlueprintName = "AIAgentCoordinator"
               ReferencedContainer = "container:AIAgentCoordinator.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{TEST_TARGET_REF}"
               BuildableName = "AIAgentCoordinatorTests.xctest"
               BlueprintName = "AIAgentCoordinatorTests"
               ReferencedContainer = "container:AIAgentCoordinator.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
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
            BlueprintIdentifier = "{TARGET_REF}"
            BuildableName = "AIAgentCoordinator.app"
            BlueprintName = "AIAgentCoordinator"
            ReferencedContainer = "container:AIAgentCoordinator.xcodeproj">
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
            BlueprintIdentifier = "{TARGET_REF}"
            BuildableName = "AIAgentCoordinator.app"
            BlueprintName = "AIAgentCoordinator"
            ReferencedContainer = "container:AIAgentCoordinator.xcodeproj">
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
"""

with open('AIAgentCoordinator.xcodeproj/xcshareddata/xcschemes/AIAgentCoordinator.xcscheme', 'w') as f:
    f.write(scheme_content)

print("✅ Successfully generated AIAgentCoordinator.xcodeproj")
print(f"   - Project file: AIAgentCoordinator.xcodeproj/project.pbxproj")
print(f"   - Scheme: AIAgentCoordinator")
print(f"   - Source files: {len(swift_files)}")
print(f"   - Test files: {len(test_files)}")
print(f"   - Platform: visionOS 2.0")
print(f"   - Swift version: 6.0")
