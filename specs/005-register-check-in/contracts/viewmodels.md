# ViewModel Contracts: Register Check-In Flow

**Feature**: 005-register-check-in  
**Date**: January 15, 2026  
**Purpose**: Define public APIs for all ViewModels in check-in feature

---

## RegisterCheckInViewModel

**Responsibility**: Manage check-in registration form state, validation, photo handling, and persistence

### Public Interface

```swift
import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class RegisterCheckInViewModel {
    // MARK: - Published State
    
    /// Selected exercise type from predefined list
    private(set) var exerciseType: String = ""
    
    /// Check-in title (required, max 100 chars)
    private(set) var title: String = ""
    
    /// Optional calories burned
    private(set) var calories: String = ""  // String for TextField binding
    
    /// Optional location text
    private(set) var location: String = ""
    
    /// Selected date/time (defaults to now)
    private(set) var date: Date = Date()
    
    /// Selected photo from gallery (PhotosPicker binding)
    var selectedPhotoItem: PhotosPickerItem?
    
    /// Loaded photo image (from camera or gallery)
    private(set) var photo: UIImage?
    
    /// Validation errors (empty if valid)
    private(set) var validationErrors: [String] = []
    
    /// Save operation in progress
    private(set) var isSaving: Bool = false
    
    /// Save succeeded (triggers navigation dismissal)
    private(set) var didSave: Bool = false
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Actions
    
    /// Update exercise type selection
    func setExerciseType(_ type: String)
    
    /// Update title (enforces 100 char limit)
    func setTitle(_ value: String)
    
    /// Update calories (validates numeric)
    func setCalories(_ value: String)
    
    /// Update location
    func setLocation(_ value: String)
    
    /// Update date/time
    func setDate(_ value: Date)
    
    /// Set photo from camera capture
    func setPhoto(_ image: UIImage)
    
    /// Load photo from PhotosPicker selection
    func loadPhoto(from item: PhotosPickerItem?) async
    
    /// Remove selected photo
    func clearPhoto()
    
    /// Validate all fields and save check-in
    func save() async -> Bool
    
    /// Reset form to initial state
    func reset()
    
    // MARK: - Private Dependencies
    private let modelContext: ModelContext
}
```

### Behavior Specifications

#### Field Updates
- `setExerciseType()`: Updates selection, clears validation error
- `setTitle()`: Enforces 100 character limit, trims whitespace
- `setCalories()`: Only accepts numeric input, clears if invalid
- `setDate()`: Rejects future dates (clamps to now)
- `setPhoto()`: Compresses image before storing
- `loadPhoto()`: Async loads from PhotosPickerItem, handles errors

#### Validation Logic
```swift
func validate() -> [String] {
    var errors: [String] = []
    
    if exerciseType.isEmpty || !ExerciseType.all.contains(exerciseType) {
        errors.append("Please select an exercise type")
    }
    
    if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        errors.append("Please enter a title")
    }
    
    if date > Date() {
        errors.append("Check-in date cannot be in the future")
    }
    
    if let caloriesInt = Int(calories), caloriesInt < 0 {
        errors.append("Calories cannot be negative")
    }
    
    return errors
}
```

#### Save Flow
1. Validate all fields
2. If errors, set `validationErrors` and return false
3. Compress photo if present (<2MB)
4. Create CheckIn model with fields
5. Insert into modelContext
6. Save context
7. Set `didSave = true` (triggers navigation dismissal)
8. Return true

#### Photo Loading
```swift
func loadPhoto(from item: PhotosPickerItem?) async {
    guard let item = item else { return }
    
    do {
        if let data = try await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            self.photo = image
        }
    } catch {
        // Log error, don't block user (photo optional)
        Logger.shared.error("Failed to load photo: \(error)")
    }
}
```

---

## CheckInViewModel

**Responsibility**: Provide check-in data for Check-In tab (summary + current month calendar)

### Public Interface

```swift
import SwiftUI
import SwiftData

@Observable
final class CheckInViewModel {
    // MARK: - Published State
    
    /// Total count of all check-ins
    private(set) var totalCheckIns: Int = 0
    
    /// Check-ins for current month grouped by day
    private(set) var currentMonthCheckIns: [Date: CheckIn] = [:]
    
    /// Current month being displayed
    private(set) var currentMonth: Date = Date()
    
    /// Loading state
    private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }
    
    // MARK: - Public Actions
    
    /// Reload all data (call on tab appear or after save)
    func refresh()
    
    /// Navigate to previous month (not used in MVP, but ready for future)
    func previousMonth()
    
    /// Navigate to next month (not used in MVP, but ready for future)
    func nextMonth()
    
    // MARK: - Private Dependencies
    private let modelContext: ModelContext
}
```

### Behavior Specifications

#### Data Refresh
```swift
func refresh() {
    isLoading = true
    defer { isLoading = false }
    
    // Fetch total count
    let countDescriptor = FetchDescriptor<CheckIn>()
    totalCheckIns = (try? modelContext.fetchCount(countDescriptor)) ?? 0
    
    // Fetch current month check-ins
    let startOfMonth = Calendar.current.startOfMonth(for: currentMonth)
    let endOfMonth = Calendar.current.endOfMonth(for: currentMonth)
    
    let monthDescriptor = FetchDescriptor<CheckIn>(
        predicate: #Predicate { checkIn in
            checkIn.date >= startOfMonth && checkIn.date < endOfMonth
        },
        sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
    )
    
    let checkIns = (try? modelContext.fetch(monthDescriptor)) ?? []
    
    // Group by calendar day (keep most recent if multiple same day)
    currentMonthCheckIns = Dictionary(
        checkIns.map { ($0.calendarDay, $0) },
        uniquingKeysWith: { newest, _ in newest }
    )
}
```

#### Month Navigation
- `previousMonth()`: Decrements currentMonth by 1 month, calls refresh()
- `nextMonth()`: Increments currentMonth by 1 month (max = now), calls refresh()

---

## CalendarViewModel

**Responsibility**: Provide check-in data grouped by month for historical "View All" screen

### Public Interface

```swift
import SwiftUI
import SwiftData

@Observable
final class CalendarViewModel {
    // MARK: - Published State
    
    /// All months with check-ins, ordered newest first
    private(set) var monthsWithCheckIns: [(month: Date, checkIns: [Date: CheckIn])] = []
    
    /// Loading state
    private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }
    
    // MARK: - Public Actions
    
    /// Reload all historical data
    func refresh()
    
    // MARK: - Private Dependencies
    private let modelContext: ModelContext
}
```

### Behavior Specifications

#### Data Refresh
```swift
func refresh() {
    isLoading = true
    defer { isLoading = false }
    
    // Fetch all check-ins
    let descriptor = FetchDescriptor<CheckIn>(
        sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
    )
    
    let allCheckIns = (try? modelContext.fetch(descriptor)) ?? []
    
    // Group by month
    let grouped = Dictionary(grouping: allCheckIns) { checkIn in
        Calendar.current.startOfMonth(for: checkIn.date)
    }
    
    // Convert to sorted array with day grouping
    monthsWithCheckIns = grouped
        .sorted { $0.key > $1.key }  // Newest month first
        .map { month, checkIns in
            let dayGrouped = Dictionary(
                checkIns.map { ($0.calendarDay, $0) },
                uniquingKeysWith: { newest, _ in newest }
            )
            return (month: month, checkIns: dayGrouped)
        }
}
```

---

## Dependency Injection

All ViewModels receive ModelContext via initializer:

```swift
// In View
@Environment(\.modelContext) private var modelContext

var body: some View {
    RegisterCheckInView(
        viewModel: RegisterCheckInViewModel(modelContext: modelContext)
    )
}
```

---

## Error Handling

ViewModels expose errors via published properties:

```swift
@Observable
class ViewModel {
    private(set) var error: Error?
    
    func action() async {
        do {
            try await performAction()
            error = nil
        } catch {
            self.error = error
            Logger.shared.error("Action failed: \(error)")
        }
    }
}

// In View
.alert("Error", isPresented: .constant(viewModel.error != nil)) {
    Button("OK") { viewModel.error = nil }
} message: {
    if let error = viewModel.error {
        Text(error.localizedDescription)
    }
}
```

---

## Testing Contracts

### Manual Test Scenarios

#### RegisterCheckInViewModel
1. **Valid submission**: Fill all required fields → save succeeds, didSave = true
2. **Missing exercise type**: Submit without type → validation error shown
3. **Missing title**: Submit without title → validation error shown
4. **Future date**: Select future date → validation error or auto-clamp to now
5. **Photo loading**: Select from gallery → photo loaded and displayed
6. **Photo optional**: Submit without photo → save succeeds
7. **Field limits**: Enter 101 chars in title → truncated to 100

#### CheckInViewModel
1. **Empty state**: No check-ins → totalCheckIns = 0, calendar empty
2. **With data**: Create check-ins → count increments, calendar displays
3. **Multiple same day**: 2 check-ins same day → calendar shows most recent photo
4. **Month navigation**: Change month → calendar updates correctly

#### CalendarViewModel
1. **Empty state**: No check-ins → monthsWithCheckIns = []
2. **Single month**: Check-ins in one month → one month group shown
3. **Multiple months**: Check-ins across months → sorted newest first
4. **Excluded months**: Months without check-ins → not in list

---

## Performance Requirements

- `refresh()` calls: <500ms for 100 check-ins
- Photo loading: <2s for typical 3-5MB gallery images
- Save operation: <300ms including compression
- Calendar rendering: 60fps scrolling through 12+ months

---

## Logging

All ViewModels use structured logging:

```swift
import OSLog

extension Logger {
    static let checkIn = Logger(subsystem: "com.bumbumnuca.app", category: "check-in")
}

// Usage
Logger.checkIn.info("Check-in saved: type=\(exerciseType), hasPhoto=\(photo != nil)")
Logger.checkIn.error("Photo loading failed: \(error)")
Logger.checkIn.debug("Validation errors: \(validationErrors)")
```

**Privacy**:
- ✅ Log: exercise type (enum), hasPhoto (bool), error codes
- ❌ Do NOT log: photo data, title text, location strings

---

## Status

✅ Contracts Complete | **Ready for**: quickstart.md
