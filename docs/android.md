# Android Documentation

## Overview

The Android app is built with **Compose Multiplatform**. Almost all UI code lives in the `sharedUI` module (`sharedUI/src/commonMain/`) so it can be shared across platforms. The `androidApp` module is intentionally thin - it only contains the `MainActivity` entry point.

---

## Module Structure

```
androidApp/
  src/main/kotlin/com/azico/findtime/
    MainActivity.kt          - Entry point, sets up Napier logging, calls MainView

sharedLogic/
  src/commonMain/kotlin/com/azico/findtime/
    TimeZoneHelper.kt        - Interface for all business logic
    TimeZoneHelperImpl.kt    - Implementation using kotlinx-datetime

sharedUI/
  src/commonMain/kotlin/com/azico/findtime/
    MainView.kt              - Root composable: Scaffold + bottom nav + FAB
    MyApplicationTheme.kt    - Material3 theme (colors, typography, shapes)
    Types.kt                 - Type aliases used across UI
    TimeZoneScreen.kt        - "World Clocks" tab screen
    FindMeetingScreen.kt     - "Find Meeting" tab screen
    LocalTimeCard.kt         - Gradient card for the user's local time
    TimeCard.kt              - Card for a selected timezone
    NumberTimeCard.kt        - Card with draggable NumberPicker (used in FindMeeting)
    AddTimeZoneDialog.kt     - Full-screen dialog to search/select timezones
    AnimatedSwipeDismiss.kt  - Swipe-to-delete wrapper using SwipeToDismissBox
    MeetingDialog.kt         - Dialog showing found meeting hours
    NumberPicker.kt          - Draggable animated hour picker component
    App.kt                   - Unused stub (left from project template)
```

---

## Entry Point: MainActivity

**File:** `androidApp/src/main/kotlin/com/azico/findtime/MainActivity.kt`

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        Napier.base(DebugAntilog())   // Initialize multiplatform logger
        setContent {
            MainView { tabIndex ->
                TopAppBar(
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.primary
                    ),
                    title = {
                        when (tabIndex) {
                            0 -> Text(stringResource(R.string.world_clocks))
                            else -> Text(stringResource(R.string.findmeeting))
                        }
                    }
                )
            }
        }
    }
}
```

`MainView` takes a lambda (`topBarFun`) that receives the current tab index. This lets `MainActivity` control the top app bar title while keeping `MainView` platform-agnostic.

---

## Root Composable: MainView

**File:** `sharedUI/src/commonMain/kotlin/com/azico/findtime/MainView.kt`

### Navigation model

```kotlin
sealed class Screen(val title: String) {
    object TimeZonesScreen : Screen("Timezones")
    object FindTimeScreen  : Screen("Find Time")
}

data class BottomItem(
    val route: String,
    val icon: ImageVector,
    val iconContentDescription: String
)

val bottomNavigationItems = listOf(
    BottomItem(Screen.TimeZonesScreen.title, Icons.Filled.Language, "Timezones"),
    BottomItem(Screen.FindTimeScreen.title,  Icons.Filled.Place,    "Find Time")
)
```

`sealed class` is Kotlin's equivalent of a Swift enum with associated values. Each `object` inside is a singleton instance - there's only ever one `TimeZonesScreen`.

### State

| Variable | Type | Purpose |
|---|---|---|
| `showAddDialog` | `MutableState<Boolean>` | Controls AddTimeZoneDialog visibility |
| `currentTimezoneStrings` | `MutableList<String>` | The list of selected timezones, shared between both screens |
| `selectedIndex` | `MutableIntState` | Current bottom nav tab index (0 or 1) |

### Layout structure

```
Scaffold
  topBar: actionBarFun(selectedIndex)       - TopAppBar from MainActivity
  floatingActionButton: FAB (tab 0 only)    - Opens AddTimeZoneDialog
  bottomBar: NavigationBar                  - Two tabs
  content:
    if showAddDialog -> AddTimeZoneDialog
    when selectedIndex:
      0 -> TimeZoneScreen(currentTimezoneStrings)
      1 -> FindMeetingScreen(currentTimezoneStrings)
```

The FAB is only shown on tab 0 (World Clocks). Tapping it sets `showAddDialog = true`.

---

## Screens

### TimeZoneScreen

**File:** `sharedUI/src/commonMain/kotlin/com/azico/findtime/TimeZoneScreen.kt`

Shows the user's local time at the top, then a scrollable list of selected timezones below. Each item supports swipe-to-delete.

**Live clock:**
```kotlin
var time by remember { mutableStateOf(timezoneHelper.currentTime()) }
LaunchedEffect(Unit) {
    while (true) {
        time = timezoneHelper.currentTime()
        delay(1000L)   // updates every second
    }
}
```

`LaunchedEffect(Unit)` runs once when the composable enters the composition and launches a coroutine. The coroutine loops forever, updating `time` every second. When `time` changes, Compose re-renders only the parts of the UI that read it.

**List:**
```kotlin
LazyColumn {
    items(count = currentTimezoneStrings.size) { index ->
        AnimatedSwipeDismiss(
            item = currentTimezoneStrings[index],
            background = { /* red delete background */ },
            content = { TimeCard(...) },
            onDismiss = { zone -> currentTimezoneStrings.remove(zone) }
        )
    }
}
```

`LazyColumn` is Compose's equivalent of `UITableView` / `RecyclerView` - it only composes visible items.

### FindMeetingScreen

**File:** `sharedUI/src/commonMain/kotlin/com/azico/findtime/FindMeetingScreen.kt`

Lets the user set a work-hours range with two `NumberPicker` wheels, select which timezones to include via checkboxes, then search for overlapping hours.

**State:**

| Variable | Type | Purpose |
|---|---|---|
| `startTime` | `MutableIntState` | Start hour (default 8) |
| `endTime` | `MutableIntState` | End hour (default 17) |
| `selectedTimeZones` | `SnapshotStateMap<Int, Boolean>` | Checkbox state per timezone index |
| `meetingHours` | `SnapshotStateList<Int>` | Results from `timezoneHelper.search()` |
| `showMeetingDialog` | `MutableState<Boolean>` | Controls MeetingDialog visibility |

**Search flow:**
1. User adjusts start/end hours via `NumberPicker` wheels
2. User unchecks any timezones to exclude
3. Tapping "Search" calls `timezoneHelper.search(startHour, endHour, selectedZones)`
4. Results are stored in `meetingHours`, then `MeetingDialog` is shown

---

## Components

### LocalTimeCard

**File:** `sharedUI/.../LocalTimeCard.kt`

A full-width gradient card (blue left to right) showing the device's current timezone, time, and date. Uses `Brush.horizontalGradient` with `startGradientColor = Color(0xFF1e88e5)` and `endGradientColor = Color(0xFF005cb2)`.

### TimeCard

**File:** `sharedUI/.../TimeCard.kt`

Card for a selected timezone in the list. Shows timezone ID (top-left), hours difference (bottom-left), current time in that zone (top-right), date (bottom-right).

### NumberTimeCard

**File:** `sharedUI/.../NumberTimeCard.kt`

Used in `FindMeetingScreen`. Wraps a label ("Start" / "End") above a `NumberPicker` that allows dragging or tapping up/down arrows to select an hour 0-23.

### NumberPicker

**File:** `sharedUI/.../NumberPicker.kt`

Custom draggable composable. Displays the current value with up/down `IconButton`s and supports vertical drag gestures via `Modifier.draggable`. State advances by one unit per ~30dp of drag.

### AnimatedSwipeDismiss

**File:** `sharedUI/.../AnimatedSwipeDismiss.kt`

Wraps any composable with swipe-to-delete behavior using `SwipeToDismissBox` (Material3). When the user swipes far enough, it animates out via `AnimatedVisibility` (`shrinkVertically() + fadeOut()`) before calling `onDismiss`.

```kotlin
@OptIn(ExperimentalMaterial3Api::class)
fun AnimatedSwipeDismiss(
    item: T,
    background: @Composable (DismissDirection) -> Unit,
    content: @Composable () -> Unit,
    onDismiss: (T) -> Unit
)
```

### AddTimeZoneDialog

**File:** `sharedUI/.../AddTimeZoneDialog.kt`

Full-screen dialog with a search field filtering all available timezone IDs. Uses `mutableStateMapOf<String, Boolean>` to track selections. Tapping "Add" calls `onAdd` with the list of selected timezone strings.

### MeetingDialog

**File:** `sharedUI/.../MeetingDialog.kt`

`AlertDialog` listing the meeting hours returned by `timezoneHelper.search()`. Displayed as `"8:00"`, `"9:00"`, etc.

---

## Theme: MyApplicationTheme

**File:** `sharedUI/.../MyApplicationTheme.kt`

Material3 theme with custom light and dark color schemes.

Key brand colors:
```kotlin
val startGradientColor = Color(0xFF1e88e5)   // card gradient start
val endGradientColor   = Color(0xFF005cb2)   // card gradient end
```

Applied via `MaterialTheme(colorScheme, typography, shapes, content)` wrapping the entire app inside `MainView`.

---

## Type Aliases

**File:** `sharedUI/.../Types.kt`

```kotlin
typealias OnAddType   = (List<String>) -> Unit      // callback when timezones are added
typealias onDismissType = () -> Unit                 // dismiss callback
typealias composeFun  = @Composable () -> Unit       // zero-arg composable
typealias topBarFun   = @Composable (Int) -> Unit    // top bar receiving tab index

fun EmptyComposable() {}   // no-op default for topBarFun
```

`topBarFun` is used as the parameter type for `MainView`'s `actionBarFun` parameter, letting `MainActivity` pass a real `TopAppBar` while previews pass nothing.

---

## Business Logic: sharedLogic

### TimeZoneHelper interface

```kotlin
interface TimeZoneHelper {
    fun getTimeZoneStrings(): List<String>
    fun currentTime(): String
    fun currentTimeZone(): String
    fun hoursFromTimeZone(otherTimeZoneId: String): Double
    fun getTime(timezoneId: String): String
    fun getDate(timezoneId: String): String
    fun search(startHour: Int, endHour: Int, timezoneStrings: List<String>): List<Int>
}
```

### TimeZoneHelperImpl

**File:** `sharedLogic/.../TimeZoneHelperImpl.kt`

Uses `kotlinx-datetime` for all timezone math. Key import note: `Clock` is from `kotlin.time.Clock` (not `kotlinx.datetime.Clock`) because Kotlin 2.x moved `Clock` to the standard library.

| Method | What it does |
|---|---|
| `getTimeZoneStrings()` | Returns all IANA timezone IDs sorted alphabetically |
| `currentTime()` | Formats current local time as `"h:mm am/pm"` |
| `currentTimeZone()` | Returns the device's system timezone ID string |
| `hoursFromTimeZone(id)` | Absolute hour difference between local and given timezone |
| `getTime(id)` | Formatted time in the given timezone |
| `getDate(id)` | e.g. `"Wednesday, May 20"` in the given timezone |
| `search(start, end, zones)` | Returns hours (within start-end) that fall within start-end in all given zones |

**`search` algorithm:**
- Iterates each hour in `[startHour, endHour]`
- For each hour, checks via `isValid()` whether that hour maps to within the range in every selected timezone
- `isValid()` constructs a `LocalDateTime` at `hour:00` in the other timezone, converts it back to local time, and checks the result is also inside the range

---

## Key Dependencies

All versions are defined in `gradle/libs.versions.toml`.

| Library | Version | Purpose |
|---|---|---|
| Kotlin | 2.3.21 | Language |
| Compose Multiplatform | 1.11.0 | Shared UI |
| AGP | 9.0.1 | Android Gradle Plugin |
| `kotlinx-datetime` | 0.8.0 | Timezone math in sharedLogic |
| Napier | 2.6.1 | Multiplatform logging |
| Navigation Compose | 2.9.2 | Available but not yet used |
| Material3 | (via Compose) | Design system |

---

## Build

Open the project in Android Studio and run the `androidApp` configuration on a device or emulator (min SDK 24).

The `sharedUI` module is consumed by `androidApp` via:
```kotlin
// androidApp/build.gradle.kts
implementation(project(":sharedUI"))
```

`sharedLogic` is consumed by `sharedUI`:
```kotlin
// sharedUI/build.gradle.kts
implementation(project(":sharedLogic"))
```
