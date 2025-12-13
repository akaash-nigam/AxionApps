# Android Build Test Results

**Date**: Fri 12 Dec 2025 14:47:25 EST
**Total Projects**: 36
**Success**: 0 (0%)
**Failed**: 30 (83%)
**Skipped**: 6 (16%)

---

## Results by Status

### Successful Builds (0 projects)


### Failed Builds by Error Type

#### Missing Dependencies


#### Kotlin Compilation Errors


#### Resource Linking Errors


#### Deprecated Configuration


#### Repository Configuration


#### Timeout


#### Other Errors


---

## Detailed Results

```csv
Project,Status,BuildTime,ErrorType,ErrorCount,Notes
android_analysis,SKIPPED,0,EMPTY_DIR,0,Empty or tool directory
android_shared,SKIPPED,0,EMPTY_DIR,0,Empty or tool directory
android_tools,SKIPPED,0,EMPTY_DIR,0,Empty or tool directory
device_testing_screenshots_session2,SKIPPED,0,NO_GRADLE,0,No Gradle build files found
device_testing_screenshots,SKIPPED,0,NO_GRADLE,0,No Gradle build files found
TobeDeletedLater,SKIPPED,0,NO_GRADLE,0,No Gradle build files found
```

---

## Next Steps

Based on error types:
1. **Missing Dependencies**: Add JitPack or other repositories to settings.gradle.kts
2. **Kotlin Compilation**: Fix code-level type mismatches and missing parameters
3. **Resource Linking**: Fix theme/resource references in XML
4. **Deprecated Config**: Remove deprecated Gradle properties
5. **Repository Config**: Update settings.gradle.kts repository mode

---

**Report Generated**: Fri 12 Dec 2025 14:47:25 EST
