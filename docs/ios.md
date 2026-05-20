# iOS Documentation

## Overview

The iOS app is built entirely with **SwiftUI**. It uses the `SharedLogic` Kotlin Multiplatform framework for all business logic (timezone math, search). The UI is 100% native Swift - there is no shared UI module used on iOS.

---

## File Structure

```
iosApp/iosApp/
  iOSApp.swift           - App entry point, UITabBar appearance setup
  ContentView.swift      - Root view: TabView with two tabs
  TimezoneItems.swift    - ObservableObject: shared state for selected timezones

  Screens:
    TimezoneView.swift   - "World Clocks" tab
    FindMeeting.swift    - "Find Meeting" tab

  Dialogs / Sheets:
    TimezoneDialog.swift - Full-screen timezone search/select sheet
    HourSheet.swift      - Sheet showing found meeting hours

  Components:
    TimeCard.swift       - Gradient card for local time
    NumberTimeCard.swift - Card for selected timezones
    Searchbar.swift      - Custom search bar (kept for reference, unused)

  Utilities:
    Utils.swift          - DateFormatter extensions
    CardModifier.swift   - cornerRadius + shadow ViewModifier
    ListModifier.swift   - List row insets/separator ViewModifier
    PresentationSettings.swift - Legacy ObservableObjects (unused)
```

---

## Entry Point: iOSApp

**File:** `iosApp/iosApp/iOSApp.swift`

```swift
@main
struct iOSApp: App {
    init() {
        // Customize tab bar to match the blue brand color
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes   = [.foregroundColor: UIColor.black]
        tabBarItemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabBarItemAppearance.normal.iconColor   = .black
        tabBarItemAppearance.selected.iconColor = .white

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBlue
        appearance.stackedLayoutAppearance = tabBarItemAppearance

        UITabBar.appearance().standardAppearance    = appearance
        UITabBar.appearance().scrollEdgeAppearance  = appearance
    }
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

`UITabBar.appearance()` is a UIKit proxy that applies the style to every tab bar in the app. SwiftUI's `.tint` modifier only tints icons; for a fully colored tab bar background you still need the UIKit appearance API.

---

## Root View: ContentView

**File:** `iosApp/iosApp/ContentView.swift`

```swift
struct ContentView: View {
    @StateObject private var timezoneItems = TimezoneItems()

    var body: some View {
        TabView {
            TimezoneView()
                .tabItem { Label("Time Zones", systemImage: "network") }
            FindMeeting()
                .tabItem { Label("Find Meeting", systemImage: "clock") }
        }
        .tint(.white)
        .environmentObject(timezoneItems)
    }
}
```

`@StateObject` creates and owns the `TimezoneItems` instance for the lifetime of the app. `.environmentObject(timezoneItems)` injects it into the SwiftUI environment so every child view can access it with `@EnvironmentObject` without passing it explicitly through every layer.

---

## Shared State: TimezoneItems

**File:** `iosApp/iosApp/TimezoneItems.swift`

```swift
class TimezoneItems: ObservableObject {
    @Published var timezones: [String] = []          // all available IANA timezone IDs
    @Published var selectedTimezones = Set<String>() // timezones the user has added

    init() {
        self.timezones = TimeZoneHelperImpl().getTimeZoneStrings()
    }
}
```

`ObservableObject` + `@Published` is the SwiftUI equivalent of Kotlin's `MutableState`. Any view that holds a reference via `@EnvironmentObject` or `@ObservedObject` automatically re-renders when a `@Published` property changes.

`Set<String>` is used for `selectedTimezones` so that membership checks (`.contains`) and removals are O(1) and duplicates are impossible by design.

`TimeZoneHelperImpl()` is called here to populate the timezone list from the shared Kotlin framework.

---

## Screens

### TimezoneView - "World Clocks"

**File:** `iosApp/iosApp/TimezoneView.swift`

Shows the device's local time in a gradient `TimeCard` at the top, then a `List` of the user's selected timezones using `NumberTimeCard`. A "+" toolbar button opens `TimezoneDialog`.

**Live clock (updates every second):**
```swift
let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

// inside body:
.onReceive(timer) { input in currentDate = input }
```

`Timer.publish` creates a Combine publisher that fires on the main thread every 1 second. `.onReceive` subscribes to it and updates `currentDate`, which triggers a re-render of the time/date labels.

**Delete by swiping:**
```swift
ForEach(Array(timezoneItems.selectedTimezones), id: \.self) { timezone in
    NumberTimeCard(...)
}
.onDelete(perform: deleteItems)
```

```swift
func deleteItems(at offsets: IndexSet) {
    let timezoneArray = Array(timezoneItems.selectedTimezones)
    for index in offsets {
        timezoneItems.selectedTimezones.remove(timezoneArray[index])
    }
}
```

`Set` is unordered, so it is converted to an `Array` first to get stable indices for the `IndexSet` that SwiftUI passes to `onDelete`.

**Add timezones:**
```swift
.fullScreenCover(isPresented: $showTimezoneDialog) {
    TimezoneDialog().environmentObject(timezoneItems)
}
```

`fullScreenCover` is used instead of `sheet` to match the full-screen modal that the Android version uses.

### FindMeeting - "Find Meeting"

**File:** `iosApp/iosApp/FindMeeting.swift`

Lets the user pick a start and end time using iOS native `DatePicker` wheels, then tap "Search" to find overlapping hours.

```swift
@State private var startDate = Calendar.current.date(
    bySettingHour: 8, minute: 0, second: 0, of: Date()
)!
@State private var endDate = Calendar.current.date(
    bySettingHour: 17, minute: 0, second: 0, of: Date()
)!
```

The `DatePicker` uses `.hourAndMinute` display mode so only the time wheel appears, not a calendar. The actual date part is irrelevant - only the hour component is extracted in `search()`.

```swift
func search() {
    meetingHours.removeAll()
    let startHour = Calendar.current.component(.hour, from: startDate)
    let endHour   = Calendar.current.component(.hour, from: endDate)
    let hours = timezoneHelper.search(
        startHour: Int32(startHour),
        endHour: Int32(endHour),
        timezoneStrings: Array(timezoneItems.selectedTimezones)
    )
    meetingHours += hours.map { Int(truncating: $0) }
    showHoursDialog = true
}
```

`timezoneHelper.search(...)` returns `[KotlinInt]` from the Kotlin framework. Each element is converted to a native Swift `Int` via `Int(truncating: $0)`.

Results are shown in `HourSheet` presented as a `.sheet`.

---

## Dialogs and Sheets

### TimezoneDialog

**File:** `iosApp/iosApp/TimezoneDialog.swift`

Full-screen cover for searching and selecting timezones to add to the world clocks list.

```swift
// Makes String work as List item ID without a wrapper type
extension String: @retroactive Identifiable {
    public var id: String { return self }
}
```

`@retroactive` is required in Swift 5.7+ when you add protocol conformance to a type you don't own (here, `String` from the standard library). Without it, the compiler emits a warning about retroactive conformance.

**Search filtering:**
```swift
List(
    timezoneItems.timezones.filter {
        searchText.isEmpty ? true : $0.lowercased().contains(searchText.lowercased())
    }
) { timezone in ... }
.searchable(text: $searchText, prompt: "Search timezones")
```

`.searchable` automatically adds a search bar to the navigation bar and manages the keyboard. The filter runs on every keystroke because `searchText` is `@State` and changing it invalidates the view.

**Selection toggling:**
```swift
func selectTimezone(timezone: String) {
    if timezoneItems.selectedTimezones.contains(timezone) {
        timezoneItems.selectedTimezones.remove(timezone)
    } else {
        timezoneItems.selectedTimezones.insert(timezone)
    }
}
```

Because `selectedTimezones` is `@Published`, toggling it immediately re-renders the checkmark icons in the list.

### HourSheet

**File:** `iosApp/iosApp/HourSheet.swift`

Modal sheet showing the list of valid meeting hours as `"8:00"`, `"9:00"`, etc. Dismissed with a "Done" button in the navigation bar.

```swift
List(hours, id: \.self) { hour in
    Text("\(hour):00")
}
```

---

## Components

### TimeCard

**File:** `iosApp/iosApp/TimeCard.swift`

Gradient card for the user's local time. Uses a diagonal gradient from `Color(red: 30/255, green: 136/255, blue: 229/255)` (lighter blue, top-leading) to `Color(red: 0/255, green: 92/255, blue: 178/255)` (darker blue, bottom-trailing).

All text uses `.foregroundStyle(.white)` / `.foregroundStyle(.white.opacity(0.8))` for secondary labels. The card uses `.clipShape(RoundedRectangle(cornerRadius: 12))` (the modern replacement for the deprecated `.cornerRadius` modifier).

Layout:
- Left column: "Your Location" caption (top) + timezone ID (bottom)
- Right column: time in large font (top) + date string (bottom)

### NumberTimeCard

**File:** `iosApp/iosApp/NumberTimeCard.swift`

Card for each timezone added to the world clocks list. Adapts to light/dark mode using semantic colors:

- Background: `Color(uiColor: .secondarySystemGroupedBackground)` - automatically light/dark
- Text: `.foregroundStyle(.primary)` / `.foregroundStyle(.secondary)` - system adaptive
- Border: `Color(uiColor: .separator)` at 0.5pt

Layout:
- Left column: timezone ID (top) + "X hours from local" (bottom)
- Right column: current time in that zone (top) + date (bottom)

---

## Utilities

### Utils.swift

```swift
extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short   // e.g. "1:39 PM"
        return formatter
    }()

    static let long: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long    // e.g. "May 20, 2026"
        formatter.timeStyle = .none
        return formatter
    }()
}
```

Static lazy-initialized formatters are used because `DateFormatter` is expensive to instantiate - creating one per render would degrade scrolling performance.

### CardModifier.swift

```swift
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 0)
    }
}
```

Applied via `.modifier(CardModifier())`. Not currently used on `TimeCard` or `NumberTimeCard` directly - they manage their own shape.

### ListModifier.swift

```swift
struct ListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(.init())        // remove default list row padding
            .listRowSeparator(.hidden)     // hide separator lines
    }
}

extension View {
    func withListModifier() -> some View { modifier(ListModifier()) }
}
```

Used on `NumberTimeCard` rows inside `TimezoneView`'s list. `.listRowInsets(.init())` resets padding to zero so the card's own `.padding` controls all spacing.

---

## Using the SharedLogic Framework

The `SharedLogic` Kotlin framework is imported in Swift files as:
```swift
import SharedLogic
```

The framework exposes `TimeZoneHelperImpl` which is instantiated directly:
```swift
private var timezoneHelper = TimeZoneHelperImpl()
```

Kotlin `Int` parameters are bridged as `Int32` in Swift, so call sites cast:
```swift
timezoneHelper.search(
    startHour: Int32(startHour),
    endHour:   Int32(endHour),
    timezoneStrings: Array(timezoneItems.selectedTimezones)
)
```

Return values of type `List<Int>` come back as `[KotlinInt]`. Convert with:
```swift
hours.map { Int(truncating: $0) }
```

**IDE note:** Xcode shows `No such module 'SharedLogic'` in the editor because the framework is not pre-built - it is compiled on demand by Gradle during Xcode's build phase via the script `embedAndSignAppleFrameworkForXcode`. This error disappears when you build (Cmd+B) or run (Cmd+R) from Xcode.

---

## Build

1. First build from the project root to compile the Kotlin framework:
   ```
   ./gradlew :sharedLogic:embedAndSignAppleFrameworkForXcode
   ```
   Or simply open `iosApp/iosApp.xcodeproj` in Xcode and build - the Xcode build phase runs this Gradle task automatically.

2. The Xcode build phase has `JAVA_HOME` hardcoded to Android Studio's JBR at:
   `/Applications/Android Studio.app/Contents/jbr/Contents/Home`
   This is required because Xcode's shell cannot find Java via the normal PATH.

3. Minimum deployment target: **iOS 18.2**

---

## State Management Summary

| Pattern | Used for |
|---|---|
| `@StateObject` | Owning `TimezoneItems` in `ContentView` |
| `@EnvironmentObject` | Accessing `TimezoneItems` in child views |
| `@State` | Local view state (dates, booleans, hour lists) |
| `ObservableObject` + `@Published` | `TimezoneItems` - shared mutable state |
| `Timer.publish` + `.onReceive` | Live clock updates every second |
| `.sheet` | `HourSheet` (partial modal) |
| `.fullScreenCover` | `TimezoneDialog` (full-screen modal) |
