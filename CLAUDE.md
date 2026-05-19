# FindTime - Project Context

## About the Project
FindTime is a Kotlin Multiplatform (KMP) app for finding overlapping time zones between people in different locations.

- **GitHub:** https://github.com/azizbibitov/find-time-kmp.git
- **Bundle ID:** com.azico.findtime

## Book Being Followed
**Kotlin Multiplatform by Tutorials - Second Edition** (Kodeco / Ray Wenderlich)

### Important notes about the book:
- The book was written in 2023 and its dependency versions are outdated - ignore all version numbers from the book
- The book uses **separate native UIs** (Jetpack Compose for Android, SwiftUI for iOS) - shared UI is only in Appendix C
- This project uses **Compose Multiplatform** for shared UI, which is newer than what the book teaches
- When the book adds Android UI code in Jetpack Compose, it can be used directly in the `sharedUI` module since Compose Multiplatform is compatible
- The book's `shared` module = this project's `sharedLogic` module
- The book's Android Gradle/dependency setup should be ignored - the project setup is already correct and more modern

## Project Structure
```
FindTime/
├── androidApp/          - Android app entry point
├── iosApp/              - iOS app (SwiftUI + Xcode project)
├── sharedLogic/         - Shared business logic (Kotlin, used by both platforms)
├── sharedUI/            - Shared UI (Compose Multiplatform, used by Android)
├── build.gradle.kts     - Root build file
└── gradle/
    └── libs.versions.toml - Version catalog for all dependencies
```

## Tech Stack
- **Language:** Kotlin (shared), Swift (iOS UI)
- **UI:** Compose Multiplatform (Android), SwiftUI (iOS)
- **Minimum Android SDK:** 24
- **iOS deployment target:** 18.2
- **Java:** Android Studio bundled JBR (at `/Applications/Android Studio.app/Contents/jbr/Contents/Home`)

## Key Dependency Versions
- Kotlin: 2.3.21
- Compose Multiplatform: 1.11.0
- AGP: 9.0.1
- kotlinxDateTime: 0.8.0
- Napier (logging): 2.6.1
- Navigation Compose: 2.9.2

## Libraries Added (ready to use, not yet used in code)
- `libs.kotlinx.datetime` - date/timezone calculations (in sharedLogic commonMain)
- `libs.napier` - multiplatform logging (in sharedLogic commonMain)
- `libs.navigation.compose` - navigation (in sharedUI commonMain)

## iOS Build Fix
The Xcode build phase script has `JAVA_HOME` hardcoded to Android Studio's JBR because Xcode's shell cannot find Java otherwise. This is set in `iosApp/iosApp.xcodeproj/project.pbxproj`.

## Current Progress
- Project structure set up and building on both platforms
- `TimeZoneHelper` interface created in `sharedLogic/src/commonMain/kotlin/com/azico/findtime/`
- Following Chapter 2 of the book (Getting Started)
