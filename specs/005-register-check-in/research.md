# Research: Register Check-In Flow

**Feature**: 005-register-check-in  
**Date**: January 15, 2026  
**Purpose**: Resolve technical unknowns and document technology choices for check-in registration with photos

---

## Research Tasks

Based on Technical Context unknowns and implementation requirements:

1. **Photo Capture & Selection** - How to implement camera + gallery picker in SwiftUI
2. **Image Storage & Compression** - Best practices for storing photos in SwiftData
3. **Calendar UI Components** - Approach for rendering monthly calendar with photos
4. **Permission Handling** - Camera and photo library authorization flows
5. **Exercise Type Icons** - Design system for placeholder icons (40-48pt, colored)

---

## 1. Photo Capture & Selection in SwiftUI

### Decision: Use PhotosPicker + UIImagePickerController

**Technology**: 
- `PhotosPicker` (SwiftUI native, iOS 16+) for gallery selection
- `UIImagePickerController` (UIKit bridge) for camera capture

**Rationale**:
- PhotosPicker provides modern SwiftUI API for photo library access
- Automatic permission handling (no manual PHPhotoLibrary authorization needed)
- UIImagePickerController still required for camera since PhotosPicker doesn't support camera source
- Both are Apple-native frameworks (zero dependencies)

**Implementation Pattern**:
```swift
// Gallery Selection (SwiftUI native)
@State private var selectedPhotoItem: PhotosPickerItem?

PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
    Label("Choose from Library", systemImage: "photo.on.rectangle")
}
.onChange(of: selectedPhotoItem) { loadImage($0) }

// Camera Capture (UIKit bridge)
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    // ... coordinator implementation
}
```

**Alternatives Considered**:
- AVFoundation custom camera: Too complex for MVP, overkill for simple photo capture
- Third-party libraries (e.g., Kingfisher): Violates zero-dependency constitution

**Best Practices**:
- Request camera permission before presenting picker: `AVCaptureDevice.requestAccess(for: .video)`
- Handle permission denial gracefully with alert + Settings deep link
- Compress images before storing (see next section)

---

## 2. Image Storage & Compression

### Decision: Store compressed JPEG in SwiftData as Data

**Storage Strategy**:
- Convert UIImage to JPEG Data with 0.7 quality compression
- Store as `photoData: Data?` property in CheckIn model
- Target: <2MB per photo (FR-025 constraint)

**Rationale**:
- SwiftData supports Data type natively (Binary Large Object)
- JPEG compression balances quality vs. storage (0.7 quality ~70-80% size reduction)
- Storing as Data avoids file system management complexity
- Encrypted at rest by iOS (SwiftData default)

**Implementation**:
```swift
// In CheckIn model
@Model
final class CheckIn {
    var photoData: Data?  // Compressed JPEG
    // ... other fields
    
    // Computed property for convenience
    var photo: UIImage? {
        get {
            guard let data = photoData else { return nil }
            return UIImage(data: data)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.7)
        }
    }
}

// Extension for compression
extension UIImage {
    func compressed(quality: CGFloat = 0.7, maxSize: Int = 2_000_000) -> Data? {
        var compression = quality
        var imageData = self.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxSize, compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}
```

**Alternatives Considered**:
- File system storage: More complex (file URL management, orphaned files risk)
- Full resolution storage: Violates <2MB constraint (SC-004)
- PNG format: Larger file sizes, no transparency needed

**Performance Considerations**:
- Compression on background thread if images >5MB original size
- Lazy loading in calendar views (load on demand, not all at once)
- Thumbnail generation for calendar display (scale down to 100x100pt)

---

## 3. Calendar UI Components

### Decision: Custom SwiftUI Grid with LazyVGrid

**Approach**: Build monthly calendar using `LazyVGrid` with 7-column layout

**Rationale**:
- No native iOS calendar component with photo support
- LazyVGrid provides efficient rendering for large datasets
- Full control over cell appearance (rounded photos, placeholder icons)
- Performant scrolling even with 100+ check-ins (SC-004)

**Architecture**:
```swift
struct CalendarMonthView: View {
    let month: Date
    let checkIns: [CheckIn]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(daysInMonth, id: \.self) { day in
                CalendarDayView(day: day, checkIn: checkIn(for: day))
            }
        }
    }
}

struct CalendarDayView: View {
    let day: Date
    let checkIn: CheckIn?
    
    var body: some View {
        ZStack {
            if let checkIn = checkIn {
                // Show photo or placeholder icon
                if let photo = checkIn.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    PlaceholderIconView(exerciseType: checkIn.exerciseType)
                }
            }
            // Day number overlay
            Text("\(day.day)")
                .font(.caption)
        }
        .frame(width: 48, height: 48)
    }
}
```

**Performance Optimizations**:
- Use `.id()` modifier on LazyVGrid to force refresh on month change
- Thumbnail images cached in memory (100x100pt, not full resolution)
- Limit historical view to 24 months max (2 years)

**Alternatives Considered**:
- UICalendarView (iOS 16+): Doesn't support custom cell content (photos)
- Third-party libraries (FSCalendar, JTAppleCalendar): Violates zero-dependency rule
- Manual layout calculation: More complex than LazyVGrid, no lazy loading

---

## 4. Permission Handling

### Decision: Declarative permission requests with fallback UI

**Camera Permission Flow**:
```swift
import AVFoundation

func requestCameraPermission() async -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    switch status {
    case .authorized:
        return true
    case .notDetermined:
        return await AVCaptureDevice.requestAccess(for: .video)
    case .denied, .restricted:
        // Show alert with Settings link
        showPermissionDeniedAlert()
        return false
    @unknown default:
        return false
    }
}
```

**Photo Library Permission**:
- PhotosPicker handles automatically (no manual PHPhotoLibrary.requestAuthorization needed)
- User sees iOS system prompt on first interaction
- Denial handled by picker (won't open)

**Info.plist Entries Required**:
```xml
<key>NSCameraUsageDescription</key>
<string>BumbumNaNuca needs camera access to capture your training photos for check-ins</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>BumbumNaNuca needs photo library access to select training photos for check-ins</string>
```

**User Experience**:
- FR-003, FR-004: Appropriate messaging when permission denied
- FR-027: Clear error messages with actionable steps
- Provide "Open Settings" button to allow user to grant permissions

---

## 5. Exercise Type Icons & Placeholder Design

### Decision: SF Symbols with color-coded backgrounds

**Icon System** (40-48pt rounded shapes per clarifications):
- Use SF Symbols for exercise type representations
- 44pt icon size (middle of 40-48pt range, iOS touch target standard)
- Rounded background circle with distinct color per type
- Icon rendered in white for contrast

**Exercise Type → Icon + Color Mapping**:
| Exercise Type | SF Symbol | Background Color |
|---------------|-----------|------------------|
| Run | `figure.run` | Orange (#FF9500) |
| Gym | `dumbbell.fill` | Red (#FF3B30) |
| Swim | `figure.pool.swim` | Blue (#007AFF) |
| Bike | `bicycle` | Green (#34C759) |
| Walk | `figure.walk` | Teal (#5AC8FA) |
| Yoga | `figure.mind.and.body` | Purple (#AF52DE) |
| Cycling | `bicycle.circle.fill` | Indigo (#5856D6) |
| Strength Training | `figure.strengthtraining.traditional` | Pink (#FF2D55) |

**Implementation**:
```swift
struct PlaceholderIconView: View {
    let exerciseType: String
    
    var iconConfig: (symbol: String, color: Color) {
        switch exerciseType {
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
    
    var body: some View {
        ZStack {
            Circle()
                .fill(iconConfig.color)
                .frame(width: 44, height: 44)
            
            Image(systemName: iconConfig.symbol)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
    }
}
```

**Rationale**:
- SF Symbols are native, vector-based, accessible
- Color coding provides instant visual recognition in calendar
- 44pt aligns with iOS Human Interface Guidelines (minimum touch target)
- Consistent with rounded photo appearance (both circular)

**Accessibility**:
- SF Symbols automatically support Dynamic Type
- Color is supplementary (icon shape provides primary meaning)
- VoiceOver reads exercise type label (not just icon)

---

## Technology Stack Summary

| Component | Technology | Version | Justification |
|-----------|-----------|---------|---------------|
| **Photo Selection** | PhotosPicker (SwiftUI) | iOS 16+ | Native API, auto permissions, zero dependencies |
| **Camera Capture** | UIImagePickerController | iOS 2+ | Only native option for camera in SwiftUI bridge |
| **Image Compression** | UIImage.jpegData() | Built-in | Native compression, no libraries needed |
| **Storage** | SwiftData (Data type) | iOS 17+ | Project standard, encrypted at rest, binary support |
| **Calendar Layout** | LazyVGrid | SwiftUI | Efficient rendering, lazy loading, custom cells |
| **Icons** | SF Symbols | iOS 13+ | Native, accessible, 4000+ icons, vector-based |
| **Permissions** | AVFoundation + PhotosUI | Built-in | Standard iOS permission APIs |
| **Date Handling** | Foundation (Calendar) | Built-in | Existing extension (Calendar+Extensions.swift) |

**External Dependencies**: ✅ **ZERO** - 100% native Apple frameworks

---

## Best Practices Applied

### Image Handling
1. Always compress before storage (0.7 quality JPEG)
2. Generate thumbnails for calendar display (100x100pt)
3. Load images on demand (not all at once)
4. Handle nil photoData gracefully (show placeholder)

### Calendar Performance
1. Use LazyVGrid for efficient rendering
2. Limit historical view to reasonable range (24 months)
3. Cache month calculations (don't recalculate on every render)
4. Use .id() modifier to force refresh when month changes

### Permission UX
1. Request permissions just-in-time (when user taps camera/gallery)
2. Provide clear messaging in Info.plist descriptions
3. Show actionable alerts on denial (with Settings link)
4. Gracefully degrade if permissions denied (allow skip photo)

### Validation
1. Validate required fields (exercise type, title) before save
2. Prevent future date selection (FR-011)
3. Limit title to 100 characters (FR-008)
4. Show inline validation errors (FR-013)

---

## Open Questions → RESOLVED

All research complete. No blocking unknowns remain. Ready for Phase 1 (data model + contracts).

---

## References

- [PhotosPicker Documentation](https://developer.apple.com/documentation/photokit/photospicker)
- [UIImagePickerController Guide](https://developer.apple.com/documentation/uikit/uiimagepickercontroller)
- [SwiftData Binary Data Storage](https://developer.apple.com/documentation/swiftdata/model-macro)
- [LazyVGrid Performance](https://developer.apple.com/documentation/swiftui/lazyvgrid)
- [SF Symbols Browser](https://developer.apple.com/sf-symbols/)
- [iOS Permission Best Practices](https://developer.apple.com/design/human-interface-guidelines/privacy)

**Status**: ✅ Research Complete | **Ready for**: Phase 1 (data-model.md + contracts/)
