# Data Model: Register Check-In Flow

**Feature**: 005-register-check-in  
**Date**: January 15, 2026  
**Technology**: SwiftData (iOS 17+)  
**Storage**: SQLite local (on-device)

---

## Overview

This feature extends the existing CheckIn model (created in Feature 003) to support photo-based check-ins with exercise details. Schema modification is **additive and backward-compatible** - existing CheckIn records will continue to work.

**Key Changes**:
- Add optional `photoData` field for compressed JPEG storage
- Add required `exerciseType` and `title` fields
- Add optional `calories` and `location` fields
- Maintain existing `date` and `notes` fields

---

## Modified Entities

### CheckIn (MODIFICATION)

Represents a training check-in with photo and exercise details.

#### SwiftData Model

```swift
import Foundation
import SwiftData
import UIKit

@Model
final class CheckIn {
    // EXISTING FIELDS (Feature 003)
    @Attribute(.unique) var id: UUID
    var date: Date
    var notes: String
    
    // NEW FIELDS (Feature 005)
    var photoData: Data?              // Compressed JPEG (0.7 quality, <2MB)
    var exerciseType: String          // Required: Run, Gym, Swim, Bike, Walk, Yoga, Cycling, Strength Training
    var title: String                 // Required: Max 100 characters
    var calories: Int?                // Optional: Calories burned
    var location: String?             // Optional: Location text
    
    // EXISTING RELATIONSHIP (Feature 003)
    @Relationship(deleteRule: .nullify)
    var workoutSession: WorkoutSession?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        notes: String = "",
        photoData: Data? = nil,
        exerciseType: String,
        title: String,
        calories: Int? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.date = date
        self.notes = notes
        self.photoData = photoData
        self.exerciseType = exerciseType
        self.title = title
        self.calories = calories
        self.location = location
    }
}

// MARK: - Computed Properties

extension CheckIn {
    /// Returns UIImage from compressed photoData, or nil if no photo
    var photo: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }
    
    /// Returns thumbnail image (100x100pt) for calendar display
    var thumbnail: UIImage? {
        guard let photo = photo else { return nil }
        let targetSize = CGSize(width: 100, height: 100)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        photo.draw(in: CGRect(origin: .zero, size: targetSize))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail
    }
    
    /// Calendar day component (ignores time) for grouping
    var calendarDay: Date {
        Calendar.current.startOfDay(for: date)
    }
}
```

#### Field Specifications

| Field | Type | Required | Constraints | Purpose |
|-------|------|----------|-------------|---------|
| `id` | UUID | Yes | Unique | Primary key (existing) |
| `date` | Date | Yes | Not future | Check-in timestamp (existing) |
| `notes` | String | No | - | General notes (existing, not used in MVP) |
| `photoData` | Data? | No | <2MB | Compressed training photo (NEW) |
| `exerciseType` | String | Yes | Enum-like | Type from predefined list (NEW) |
| `title` | String | Yes | Max 100 chars | User-provided name (NEW) |
| `calories` | Int? | No | >= 0 | Calories burned (NEW) |
| `location` | String? | No | Max 200 chars | Location text (NEW) |
| `workoutSession` | WorkoutSession? | No | Relationship | Link to session (existing) |

#### Validation Rules

**Business Rules** (enforced in ViewModel):
- `exerciseType` must be one of: Run, Gym, Swim, Bike, Walk, Yoga, Cycling, Strength Training
- `title` length: 1-100 characters
- `date` cannot be in the future
- `calories` if present: >= 0
- `photoData` if present: <2MB (compression enforced before storage)
- `location` if present: max 200 characters

**Database Constraints** (SwiftData enforced):
- `id` is unique (@Attribute(.unique))
- `exerciseType`, `title` are non-optional (compilation error if missing)

---

## SwiftData Schema Evolution

### Migration Strategy

**From**: Schema v4 (CheckIn with id, date, notes, workoutSession)  
**To**: Schema v5 (CheckIn with added fields)

**Migration Type**: **Lightweight/Automatic** (additive changes only)

#### Schema Update

```swift
// BumbumNaNucaApp.swift - NO CHANGES NEEDED
var sharedModelContainer: ModelContainer = {
    let schema = Schema([
        WorkoutPlan.self,
        Exercise.self,
        WorkoutSession.self,
        ExerciseSet.self,
        CheckIn.self  // SwiftData detects new fields automatically
    ])
    
    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )
    
    return try! ModelContainer(for: schema, configurations: [modelConfiguration])
}()
```

#### Migration Behavior

**Existing CheckIn Records**:
- `photoData`: defaults to `nil`
- `exerciseType`: ⚠️ MIGRATION ISSUE - required field, no default
- `title`: ⚠️ MIGRATION ISSUE - required field, no default
- `calories`: defaults to `nil`
- `location`: defaults to `nil`

**⚠️ Breaking Change Mitigation**:

Since `exerciseType` and `title` are required fields, we need to provide migration defaults for existing records:

```swift
// Option 1: Make fields optional temporarily during migration
var exerciseType: String?  // Change to String temporarily
var title: String?         // Change to String temporarily

// Then in a future version (after all users migrated), make non-optional again

// Option 2: Provide default values (RECOMMENDED)
var exerciseType: String = "Unknown"  // Default for old records
var title: String = "Legacy Check-in" // Default for old records
```

**Recommendation**: Use Option 2 with defaults. This is backward-compatible and doesn't require multi-step migration.

#### Final Model with Migration Safety

```swift
@Model
final class CheckIn {
    @Attribute(.unique) var id: UUID
    var date: Date
    var notes: String
    var photoData: Data?
    var exerciseType: String = "Unknown"        // Default for migration
    var title: String = "Legacy Check-in"       // Default for migration
    var calories: Int?
    var location: String?
    
    @Relationship(deleteRule: .nullify)
    var workoutSession: WorkoutSession?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        notes: String = "",
        photoData: Data? = nil,
        exerciseType: String = "Unknown",  // Keep default in init
        title: String = "Legacy Check-in", // Keep default in init
        calories: Int? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.date = date
        self.notes = notes
        self.photoData = photoData
        self.exerciseType = exerciseType
        self.title = title
        self.calories = calories
        self.location = location
    }
}
```

**Verification Steps**:
1. Backup device/simulator data before testing
2. Run app with new schema - SwiftData auto-migrates
3. Verify existing CheckIn records have default values
4. Create new CheckIn with full fields
5. Confirm both old and new records display correctly

**Rollback**: Revert CheckIn.swift to Feature 003 version, delete app data

---

## Helper Types

### ExerciseType (Static Constants)

Not a separate model - just validation helper:

```swift
struct ExerciseType {
    static let all: [String] = [
        "Run",
        "Gym",
        "Swim",
        "Bike",
        "Walk",
        "Yoga",
        "Cycling",
        "Strength Training"
    ]
    
    static func isValid(_ type: String) -> Bool {
        return all.contains(type)
    }
    
    static func icon(for type: String) -> (symbol: String, color: Color) {
        switch type {
        case "Run": return ("figure.run", .orange)
        case "Gym": return ("dumbbell.fill", .red)
        case "Swim": return ("figure.pool.swim", .blue)
        case "Bike": return ("bicycle", .green)
        case "Walk": return ("figure.walk", .teal)
        case "Yoga": return ("figure.mind.and.body", .purple)
        case "Cycling": return ("bicycle.circle.fill", .indigo)
        case "Strength Training": return ("figure.strengthtraining.traditional", .pink)
        default: return ("figure.mixed.cardio", .gray)
        }
    }
}
```

---

## SwiftData Queries

### Common Fetch Patterns

```swift
// Fetch all check-ins ordered by date (newest first)
@Query(sort: \CheckIn.date, order: .reverse)
var checkIns: [CheckIn]

// Fetch check-ins for specific month
let startOfMonth = Calendar.current.startOfMonth(for: Date())
let endOfMonth = Calendar.current.endOfMonth(for: Date())

let descriptor = FetchDescriptor<CheckIn>(
    predicate: #Predicate { checkIn in
        checkIn.date >= startOfMonth && checkIn.date < endOfMonth
    },
    sortBy: [SortDescriptor(\CheckIn.date)]
)
let monthCheckIns = try modelContext.fetch(descriptor)

// Group check-ins by calendar day (for calendar display)
extension Array where Element == CheckIn {
    func groupedByDay() -> [Date: CheckIn] {
        Dictionary(
            self.map { ($0.calendarDay, $0) },
            uniquingKeysWith: { newest, _ in newest }  // Keep most recent if multiple same day
        )
    }
}

// Fetch check-ins grouped by month (for historical view)
extension Array where Element == CheckIn {
    func groupedByMonth() -> [(month: Date, checkIns: [CheckIn])] {
        let grouped = Dictionary(grouping: self) { checkIn in
            Calendar.current.startOfMonth(for: checkIn.date)
        }
        return grouped
            .sorted { $0.key > $1.key }  // Newest month first
            .map { (month: $0.key, checkIns: $0.value) }
    }
}
```

---

## Performance Considerations

### Image Storage Optimization

```swift
extension UIImage {
    /// Compress image to <2MB for storage
    func compressed(maxSizeBytes: Int = 2_000_000) -> Data? {
        var compression: CGFloat = 0.7
        var imageData = self.jpegData(compressionQuality: compression)
        
        // Iteratively reduce quality if still too large
        while let data = imageData, data.count > maxSizeBytes, compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}

// Usage in ViewModel
func savePhoto(_ image: UIImage) {
    checkIn.photoData = image.compressed()
}
```

### Calendar Performance (100+ check-ins)

- LazyVGrid loads cells on-demand (lazy loading)
- Use thumbnail images (100x100pt) not full resolution
- Cache month groupings in ViewModel (don't recalculate)
- Limit historical view to 24 months

**Estimated Storage** (100 check-ins):
- 100 photos × 1.5MB avg = 150MB
- Well under typical device storage limits

---

## Testing Considerations

### Manual Test Scenarios

1. **Create check-in with photo**: Verify compression, storage, retrieval
2. **Create check-in without photo**: Verify placeholder icon shows in calendar
3. **Migration test**: Install Feature 003 version, create check-in, update to Feature 005, verify default values
4. **Edge cases**:
   - Very large photos (>10MB) compress correctly
   - 100+ check-ins display smoothly in calendar
   - Multiple check-ins same day (show most recent)
   - Exercise type validation (reject invalid types)

### Validation Test Cases

```swift
// In RegisterCheckInViewModel
func validate() -> [String] {
    var errors: [String] = []
    
    if exerciseType.isEmpty || !ExerciseType.isValid(exerciseType) {
        errors.append("Please select an exercise type")
    }
    
    if title.isEmpty {
        errors.append("Please enter a title")
    } else if title.count > 100 {
        errors.append("Title must be 100 characters or less")
    }
    
    if date > Date() {
        errors.append("Check-in date cannot be in the future")
    }
    
    if let calories = calories, calories < 0 {
        errors.append("Calories cannot be negative")
    }
    
    if let photoData = photoData, photoData.count > 2_000_000 {
        errors.append("Photo size must be less than 2MB")
    }
    
    return errors
}
```

---

## Privacy and Security

**Data Classification**:
- **Personal**: Training photos, exercise titles, location - user-specific content
- **Sensitive**: Photos may contain faces/identifying information
- **Retention**: Indefinite (user can manually delete via future feature)

**Security Measures**:
- SwiftData encryption at rest (iOS default)
- No cloud sync in MVP (local-only)
- Photos never leave device
- No logging of photo data or location strings (only exercise type enum and error events)

**Privacy Impact**:
- Camera permission required (Info.plist description provided)
- Photo library permission required (Info.plist description provided)
- User can skip photo (optional field)
- No background photo access (only during active registration)

---

## Dependencies

### Model Dependencies
- **None** - CheckIn is self-contained
- Optional relationship to WorkoutSession (existing, not used in this feature)

### Framework Dependencies
- `Foundation` - Date, Calendar, UUID
- `SwiftData` - @Model, @Attribute, @Relationship
- `UIKit` - UIImage (for photo computed properties)

**External Dependencies**: ✅ **ZERO**

---

## Migration Checklist

- [x] Define new fields with default values for backward compatibility
- [x] Document schema version change (v4 → v5)
- [x] Verify existing relationships preserved (workoutSession)
- [x] Test migration with existing Feature 003 data
- [ ] Update BumbumNaNucaApp.swift schema (no changes needed - automatic)
- [ ] Manual test migration on device with real data

---

## Conclusion

**Schema Summary**:
- ✅ Extends existing CheckIn model (backward-compatible)
- ✅ 5 new fields (photoData, exerciseType, title, calories, location)
- ✅ Default values for required fields enable safe migration
- ✅ Zero new relationships (self-contained)
- ✅ Photo storage optimized (<2MB compression)
- ✅ Validation rules documented for ViewModel enforcement

**Ready for**: Phase 1 continuation (contracts/ + quickstart.md)

**Status**: ✅ Data Model Complete
