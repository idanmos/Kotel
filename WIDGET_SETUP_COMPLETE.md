# Kotel Widget & Live Activity Setup - Final Steps

## Current Status

✅ All widget code has been created and is ready
✅ Widget files have been moved to the correct extension folder
✅ Live Activity service has been integrated into the main app
✅ UI controls for Live Activity have been added

## Build Error to Fix

You're seeing this error:
```
Multiple commands produce KotelActivityAttributes.stringsdata
```

This happens because `KotelActivityAttributes.swift` is in the Compile Sources build phase twice for the main app target.

### How to Fix in Xcode:

1. **Select the `Kotel` target** in Xcode's project navigator
2. Go to **Build Phases** tab
3. Expand **Compile Sources**
4. Look for `KotelActivityAttributes.swift` - it will appear **twice**
5. Remove **one** of the duplicate entries (keep just one)
6. **Add the file to the widget extension target**:
   - Select `KotelWidgetExtension` target
   - Go to Build Phases → Compile Sources
   - Click the **+** button
   - Add `KotelActivityAttributes.swift`

Now the file will be compiled once for each target (shared between them).

## Verification Steps

After fixing the duplicate:

1. **Build the project** (Cmd+B) - should succeed
2. **Run on device/simulator**
3. **Test Home Screen Widgets**:
   - Long-press home screen → Add Widget → Search "Kotel"
   - Add Small, Medium, or Large widget
   
4. **Test Lock Screen Widgets**:
   - Lock screen → Customize → Add Widgets → Search "Kotel"
   - Add Circular, Rectangular, or Inline widget

5. **Test Live Activity**:
   - Open the app
   - Grant location permission
   - Tap "Start Live Activity" button
   - Check the Dynamic Island (on iPhone 14 Pro+) or Lock Screen
   - The compass should update as you move/rotate

## Widget Features

### Home Screen Widgets
- **Small**: Compact compass with distance
- **Medium**: Compass + Hebrew title + distance
- **Large**: Full compass rose with detailed info

### Lock Screen Widgets
- **Circular**: Rotating arrow compass
- **Rectangular**: Full info with distance
- **Inline**: Simple distance text

### Live Activity (Dynamic Island)
- **Compact**: Western Wall icon + rotating arrow
- **Minimal**: Single icon (when multiple activities)
- **Expanded**: Full UI with:
  - Hebrew title (הכותל המערבי)
  - Live compass direction
  - Distance display
  - Current heading
  - Calibration status

## Files Created

### Main App (Kotel/)
- `KotelActivityAttributes.swift` - Shared activity definition
- `Services/LiveActivityService.swift` - Live Activity manager
- Updated `ContentView.swift` - Added Live Activity button
- Updated `Shared/ViewModels/CompassViewModel.swift` - Live Activity methods

### Widget Extension (Kotel​Widget​Extension/)
- `KotelWidgetBundle.swift` - Main widget bundle & config
- `KotelWidgetEntry.swift` - Timeline provider
- `KotelWidgetViews.swift` - Home Screen widgets
- `LockScreenWidgetViews.swift` - Lock Screen widgets
- `KotelLiveActivity.swift` - Live Activity with Dynamic Island
- `Info.plist` - Extension configuration

## Required Capabilities

The following should already be configured:
- ✅ NSSupportsLiveActivities in main app
- ✅ WidgetKit framework linked
- ✅ ActivityKit framework linked
- ✅ Location permissions configured

## Next Steps

1. Fix the duplicate file issue as described above
2. Build and run the project
3. Test all widget types
4. Enjoy your Kotel compass with widgets and Live Activity! 🧭
