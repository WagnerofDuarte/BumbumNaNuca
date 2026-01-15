# Quickstart Guide: Register Check-In Flow

**Feature**: 005-register-check-in  
**Estimated Time**: 10-12 hours  
**Prerequisites**: Features 001-004 complete, iOS 17+ device/simulator

---

## Overview

This guide provides step-by-step implementation instructions for the Register Check-In feature. Work sequentially through phases for incremental progress.

**Implementation Order** (aligns with User Story priorities):
1. **Phase 1**: Data Layer (CheckIn model extension) - 1-2 hours
2. **Phase 2**: Register Check-In Screen (P1 core) - 3-4 hours
3. **Phase 3**: Check-In Tab with Current Month Calendar (P1 core) - 3-4 hours
4. **Phase 4**: Historical Calendar View (P2) - 2-3 hours
5. **Phase 5**: Polish & Manual Testing - 1-2 hours

---

## Phase 1: Data Layer (1-2 hours)

### Step 1.1: Extend CheckIn Model

**File**: `BumbumNaNuca/Models/CheckIn.swift` (MODIFY existing)

```swift
import Foundation
import SwiftData
import UIKit

@Model
final class CheckIn {
    // EXISTING (Feature 003)
    @Attribute(.unique) var id: UUID
    var date: Date
    var notes: String
    
    // NEW (Feature 005)
    var photoData: Data?
    var exerciseType: String = "Unknown"  // Default for migration
    var title: String = "Legacy Check-in" // Default for migration
    var calories: Int?
    var location: String?
    
    @Relationship(deleteRule: .nullify)
    var workoutSession: WorkoutSession?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        notes: String = "",
        photoData: Data? = nil,
        exerciseType: String = "Unknown",
        title: String = "Legacy Check-in",
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
    var photo: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }
    
    var thumbnail: UIImage? {
        guard let photo = photo else { return nil }
        let targetSize = CGSize(width: 100, height: 100)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        photo.draw(in: CGRect(origin: .zero, size: targetSize))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail
    }
    
    var calendarDay: Date {
        Calendar.current.startOfDay(for: date)
    }
}
```

### Step 1.2: Add Exercise Type Helper

**File**: `BumbumNaNuca/Utilities/ExerciseType.swift` (NEW)

```swift
import SwiftUI

struct ExerciseType {
    static let all: [String] = [
        "Run", "Gym", "Swim", "Bike",
        "Walk", "Yoga", "Cycling", "Strength Training"
    ]
    
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

### Step 1.3: Add Image Compression Extension

**File**: `BumbumNaNuca/Utilities/Extensions/UIImage+Compression.swift` (NEW)

```swift
import UIKit

extension UIImage {
    func compressed(maxSizeBytes: Int = 2_000_000) -> Data? {
        var compression: CGFloat = 0.7
        var imageData = self.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxSizeBytes, compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}
```

### Step 1.4: Add Calendar Extensions

**File**: `BumbumNaNuca/Utilities/Extensions/Calendar+CheckIn.swift` (NEW)

```swift
import Foundation

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    func endOfMonth(for date: Date) -> Date {
        guard let nextMonth = self.date(byAdding: .month, value: 1, to: startOfMonth(for: date)) else {
            return date
        }
        return self.date(byAdding: .second, value: -1, to: nextMonth)!
    }
    
    func daysInMonth(for date: Date) -> [Date] {
        guard let monthRange = range(of: .day, in: .month, for: date) else {
            return []
        }
        
        let startOfMonth = self.startOfMonth(for: date)
        
        return monthRange.compactMap { day in
            self.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}
```

**✅ Checkpoint**: Build project - should compile without errors. Existing CheckIn records will migrate automatically with default values.

---

## Phase 2: Register Check-In Screen (3-4 hours)

### Step 2.1: Create Camera Picker Bridge

**File**: `BumbumNaNuca/Views/Components/CameraPicker.swift` (NEW)

```swift
import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
```

### Step 2.2: Create Placeholder Icon Component

**File**: `BumbumNaNuca/Views/Components/PlaceholderIconView.swift` (NEW)

```swift
import SwiftUI

struct PlaceholderIconView: View {
    let exerciseType: String
    
    var iconConfig: (symbol: String, color: Color) {
        ExerciseType.icon(for: exerciseType)
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

### Step 2.3: Create ViewModel

**File**: `BumbumNaNuca/ViewModels/RegisterCheckInViewModel.swift` (NEW)

```swift
import SwiftUI
import SwiftData
import PhotosUI
import OSLog

@Observable
final class RegisterCheckInViewModel {
    var exerciseType: String = ""
    var title: String = ""
    var calories: String = ""
    var location: String = ""
    var date: Date = Date()
    var selectedPhotoItem: PhotosPickerItem?
    var photo: UIImage?
    var validationErrors: [String] = []
    var isSaving: Bool = false
    var didSave: Bool = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func setExerciseType(_ type: String) {
        exerciseType = type
        validationErrors.removeAll()
    }
    
    func setTitle(_ value: String) {
        title = String(value.prefix(100))
    }
    
    func setCalories(_ value: String) {
        calories = value.filter { $0.isNumber }
    }
    
    func setDate(_ value: Date) {
        date = min(value, Date())  // Clamp to now
    }
    
    func setPhoto(_ image: UIImage) {
        photo = image
    }
    
    func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.photo = image
            }
        } catch {
            Logger.checkIn.error("Failed to load photo: \(error)")
        }
    }
    
    func clearPhoto() {
        photo = nil
        selectedPhotoItem = nil
    }
    
    func save() async -> Bool {
        validationErrors = validate()
        guard validationErrors.isEmpty else { return false }
        
        isSaving = true
        defer { isSaving = false }
        
        let photoData = photo?.compressed()
        let caloriesInt = Int(calories)
        
        let checkIn = CheckIn(
            date: date,
            photoData: photoData,
            exerciseType: exerciseType,
            title: title,
            calories: caloriesInt,
            location: location.isEmpty ? nil : location
        )
        
        modelContext.insert(checkIn)
        
        do {
            try modelContext.save()
            Logger.checkIn.info("Check-in saved: type=\(exerciseType), hasPhoto=\(photoData != nil)")
            didSave = true
            return true
        } catch {
            Logger.checkIn.error("Save failed: \(error)")
            validationErrors = ["Failed to save check-in. Please try again."]
            return false
        }
    }
    
    func reset() {
        exerciseType = ""
        title = ""
        calories = ""
        location = ""
        date = Date()
        photo = nil
        selectedPhotoItem = nil
        validationErrors = []
        didSave = false
    }
    
    private func validate() -> [String] {
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
}

extension Logger {
    static let checkIn = Logger(subsystem: "com.bumbumnuca.app", category: "check-in")
}
```

### Step 2.4: Create Register Check-In View

**File**: `BumbumNaNuca/Views/CheckIn/RegisterCheckInView.swift` (NEW)

```swift
import SwiftUI
import PhotosUI
import AVFoundation

struct RegisterCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RegisterCheckInViewModel
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    
    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: RegisterCheckInViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                photoSection
                detailsSection
                optionalFieldsSection
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $viewModel.photo)
            }
            .onChange(of: viewModel.selectedPhotoItem) { _, item in
                Task {
                    await viewModel.loadPhoto(from: item)
                }
            }
            .onChange(of: viewModel.didSave) { _, didSave in
                if didSave {
                    dismiss()
                }
            }
            .alert("Permission Required", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow camera access in Settings to take photos.")
            }
        }
    }
    
    private var photoSection: some View {
        Section("Training Photo (Optional)") {
            if let photo = viewModel.photo {
                HStack {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer()
                    
                    Button("Remove", role: .destructive) {
                        viewModel.clearPhoto()
                    }
                }
            } else {
                HStack {
                    PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                    
                    Spacer()
                    
                    Button {
                        requestCameraPermission()
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                }
            }
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            Picker("Exercise Type *", selection: $viewModel.exerciseType) {
                Text("Select Type").tag("")
                ForEach(ExerciseType.all, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            
            TextField("Title *", text: Binding(
                get: { viewModel.title },
                set: { viewModel.setTitle($0) }
            ))
            
            DatePicker("Date & Time", selection: Binding(
                get: { viewModel.date },
                set: { viewModel.setDate($0) }
            ), in: ...Date())
            
            if !viewModel.validationErrors.isEmpty {
                ForEach(viewModel.validationErrors, id: \.self) { error in
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var optionalFieldsSection: some View {
        Section("Optional Details") {
            TextField("Calories Burned", text: Binding(
                get: { viewModel.calories },
                set: { viewModel.setCalories($0) }
            ))
            .keyboardType(.numberPad)
            
            TextField("Location", text: $viewModel.location)
        }
    }
    
    private func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCamera = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }
}
```

**✅ Checkpoint**: Run app → tap "Check In" button (add to home for testing) → form appears, can select photo, fill fields, save

---

## Phase 3: Check-In Tab with Calendar (3-4 hours)

### Step 3.1: Create ViewModel

**File**: `BumbumNaNuca/ViewModels/CheckInViewModel.swift` (NEW)

```swift
import SwiftUI
import SwiftData

@Observable
final class CheckInViewModel {
    var totalCheckIns: Int = 0
    var currentMonthCheckIns: [Date: CheckIn] = [:]
    var currentMonth: Date = Date()
    var isLoading: Bool = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }
    
    func refresh() {
        isLoading = true
        defer { isLoading = false }
        
        // Total count
        let countDescriptor = FetchDescriptor<CheckIn>()
        totalCheckIns = (try? modelContext.fetchCount(countDescriptor)) ?? 0
        
        // Current month
        let startOfMonth = Calendar.current.startOfMonth(for: currentMonth)
        let endOfMonth = Calendar.current.endOfMonth(for: currentMonth)
        
        let monthDescriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { checkIn in
                checkIn.date >= startOfMonth && checkIn.date < endOfMonth
            },
            sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
        )
        
        let checkIns = (try? modelContext.fetch(monthDescriptor)) ?? []
        
        currentMonthCheckIns = Dictionary(
            checkIns.map { ($0.calendarDay, $0) },
            uniquingKeysWith: { newest, _ in newest }
        )
    }
}
```

### Step 3.2: Create Calendar Day View

**File**: `BumbumNaNuca/Views/CheckIn/CalendarDayView.swift` (NEW)

```swift
import SwiftUI

struct CalendarDayView: View {
    let day: Date
    let checkIn: CheckIn?
    
    var body: some View {
        ZStack {
            if let checkIn = checkIn {
                if let thumbnail = checkIn.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    PlaceholderIconView(exerciseType: checkIn.exerciseType)
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
            }
            
            VStack {
                Spacer()
                Text("\(Calendar.current.component(.day, from: day))")
                    .font(.caption2)
                    .foregroundColor(checkIn != nil ? .white : .primary)
                    .padding(2)
                    .background(checkIn != nil ? Color.black.opacity(0.5) : Color.clear)
                    .clipShape(Circle())
            }
        }
        .frame(width: 44, height: 44)
    }
}
```

### Step 3.3: Create Month Calendar View

**File**: `BumbumNaNuca/Views/CheckIn/CalendarMonthView.swift` (NEW)

```swift
import SwiftUI

struct CalendarMonthView: View {
    let month: Date
    let checkIns: [Date: CheckIn]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current
    
    private var monthName: String {
        month.formatted(.dateTime.month(.wide).year())
    }
    
    private var daysInMonth: [Date] {
        calendar.daysInMonth(for: month)
    }
    
    private var weekdayHeaders: [String] {
        calendar.shortWeekdaySymbols
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(monthName)
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ForEach(daysInMonth, id: \.self) { day in
                    CalendarDayView(
                        day: day,
                        checkIn: checkIns[calendar.startOfDay(for: day)]
                    )
                }
            }
        }
        .padding()
    }
}
```

### Step 3.4: Create Check-In Tab View

**File**: `BumbumNaNuca/Views/CheckIn/CheckInTabView.swift` (NEW)

```swift
import SwiftUI
import SwiftData

struct CheckInTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CheckInViewModel?
    @State private var showRegisterCheckIn = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summarySection
                    calendarSection
                    viewAllButton
                }
                .padding()
            }
            .navigationTitle("Check-Ins")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showRegisterCheckIn = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showRegisterCheckIn) {
                RegisterCheckInView(modelContext: modelContext)
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = CheckInViewModel(modelContext: modelContext)
                } else {
                    viewModel?.refresh()
                }
            }
            .refreshable {
                viewModel?.refresh()
            }
        }
    }
    
    private var summarySection: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Total Check-Ins",
                value: "\(viewModel?.totalCheckIns ?? 0)"
            )
        }
    }
    
    private var calendarSection: some View {
        Group {
            if let viewModel = viewModel {
                CalendarMonthView(
                    month: viewModel.currentMonth,
                    checkIns: viewModel.currentMonthCheckIns
                )
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private var viewAllButton: some View {
        NavigationLink {
            Text("All Check-Ins (Phase 4)")  // Placeholder for now
        } label: {
            Label("View All Check-Ins", systemImage: "calendar")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}
```

**✅ Checkpoint**: Run app → navigate to Check-In tab → see calendar with check-ins, tap + to create new

---

## Phase 4: Historical Calendar View (2-3 hours)

### Step 4.1: Create ViewModel

**File**: `BumbumNaNuca/ViewModels/CalendarViewModel.swift` (NEW)

```swift
import SwiftUI
import SwiftData

@Observable
final class CalendarViewModel {
    var monthsWithCheckIns: [(month: Date, checkIns: [Date: CheckIn])] = []
    var isLoading: Bool = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }
    
    func refresh() {
        isLoading = true
        defer { isLoading = false }
        
        let descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
        )
        
        let allCheckIns = (try? modelContext.fetch(descriptor)) ?? []
        
        let grouped = Dictionary(grouping: allCheckIns) { checkIn in
            Calendar.current.startOfMonth(for: checkIn.date)
        }
        
        monthsWithCheckIns = grouped
            .sorted { $0.key > $1.key }
            .map { month, checkIns in
                let dayGrouped = Dictionary(
                    checkIns.map { ($0.calendarDay, $0) },
                    uniquingKeysWith: { newest, _ in newest }
                )
                return (month: month, checkIns: dayGrouped)
            }
    }
}
```

### Step 4.2: Create All Check-Ins View

**File**: `BumbumNaNuca/Views/CheckIn/AllCheckInsView.swift` (NEW)

```swift
import SwiftUI
import SwiftData

struct AllCheckInsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CalendarViewModel?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if let viewModel = viewModel {
                    if viewModel.monthsWithCheckIns.isEmpty {
                        EmptyStateView(
                            icon: "calendar.badge.exclamationmark",
                            message: "No check-ins yet"
                        )
                        .padding(.top, 100)
                    } else {
                        ForEach(viewModel.monthsWithCheckIns.indices, id: \.self) { index in
                            let monthData = viewModel.monthsWithCheckIns[index]
                            CalendarMonthView(
                                month: monthData.month,
                                checkIns: monthData.checkIns
                            )
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("All Check-Ins")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = CalendarViewModel(modelContext: modelContext)
            }
        }
    }
}
```

### Step 4.3: Connect All Check-Ins Navigation

**File**: Update `BumbumNaNuca/Views/CheckIn/CheckInTabView.swift`

Replace the placeholder `viewAllButton` with:

```swift
private var viewAllButton: some View {
    NavigationLink {
        AllCheckInsView()
    } label: {
        Label("View All Check-Ins", systemImage: "calendar")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
```

**✅ Checkpoint**: Tap "View All Check-Ins" → see historical calendars sorted newest to oldest

---

## Phase 5: Polish & Manual Testing (1-2 hours)

### Step 5.1: Add Info.plist Permissions

**File**: `BumbumNaNuca/Info.plist` (ADD)

```xml
<key>NSCameraUsageDescription</key>
<string>BumbumNaNuca needs camera access to capture your training photos for check-ins</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>BumbumNaNuca needs photo library access to select training photos for check-ins</string>
```

### Step 5.2: Add Check-In Tab to TabView

**File**: Update main TabView (likely in `ContentView.swift` or similar)

```swift
TabView {
    // ... existing tabs (Home, Workout, Progress)
    
    CheckInTabView()
        .tabItem {
            Label("Check-In", systemImage: "camera.fill")
        }
}
```

### Step 5.3: Manual Test Checklist

Run through all acceptance scenarios from spec.md:

**P1 - Quick Check-In Registration**:
- [ ] Tap "Check In" button → form opens
- [ ] Select exercise type → saved
- [ ] Tap "Take Photo" → camera opens (permission requested)
- [ ] Capture photo → photo displayed in form
- [ ] Tap "Choose from Library" → gallery opens
- [ ] Select photo → photo displayed
- [ ] Fill title → saved (max 100 chars)
- [ ] Save with all fields → returns to Home, count incremented

**P1 - Monthly Calendar View**:
- [ ] Navigate to Check-In tab → summary shows total count
- [ ] Calendar displays current month
- [ ] Days with check-ins show photo or icon
- [ ] Multiple check-ins same day → shows most recent

**P2 - Detailed Metrics**:
- [ ] Fill calories field → numeric only
- [ ] Select date/time → picker works
- [ ] Future date rejected or clamped to now
- [ ] Enter location → saved

**P2 - Historical View**:
- [ ] Tap "View All Check-Ins" → screen opens
- [ ] Months with check-ins shown
- [ ] Ordered newest to oldest
- [ ] Months without check-ins excluded

**Edge Cases**:
- [ ] Save without exercise type → validation error
- [ ] Save without title → validation error
- [ ] Save without photo → succeeds, icon placeholder shows
- [ ] Camera permission denied → alert with Settings link
- [ ] Large photo (>5MB) → compresses to <2MB
- [ ] 100+ check-ins → calendar scrolls smoothly

---

## Performance Optimization

### Image Loading Optimization

If calendar performance degrades with many photos, add lazy thumbnail generation:

**File**: Update `CalendarDayView.swift`

```swift
struct CalendarDayView: View {
    let day: Date
    let checkIn: CheckIn?
    
    @State private var loadedThumbnail: UIImage?
    
    var body: some View {
        ZStack {
            if let checkIn = checkIn {
                if let thumbnail = loadedThumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    PlaceholderIconView(exerciseType: checkIn.exerciseType)
                        .task {
                            // Load thumbnail async
                            loadedThumbnail = checkIn.thumbnail
                        }
                }
            }
            // ... rest of view
        }
    }
}
```

---

## Debugging

### SwiftData Query Debugging

```swift
// Add to ViewModel refresh() to debug queries
print("📊 Total check-ins: \(totalCheckIns)")
print("📅 Current month: \(currentMonth.formatted())")
print("✅ Check-ins this month: \(currentMonthCheckIns.count)")
```

### Photo Compression Verification

```swift
// Add to RegisterCheckInViewModel.save()
if let photoData = photoData {
    let sizeInMB = Double(photoData.count) / 1_000_000
    print("📸 Photo size: \(sizeInMB) MB")
}
```

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Camera not opening | Check Info.plist has NSCameraUsageDescription |
| Photos not loading | Verify PhotosPicker has .images matching filter |
| Calendar empty | Check date range in FetchDescriptor predicate |
| App crashes on migration | Delete app and reinstall (dev only) |
| Photos too large | Verify compression in UIImage+Compression.swift |
| Validation not working | Check exerciseType in ExerciseType.all list |

---

## Next Steps

After completing this feature:
1. Test on physical device (camera functionality)
2. Verify migration with Feature 003 data
3. Create PR with screenshots of:
   - Register form with photo
   - Calendar with check-ins
   - Historical view with multiple months
4. Manual test all P1 scenarios
5. Optional: Add analytics events for check-in creation

---

## Estimated Time Breakdown

| Phase | Tasks | Time |
|-------|-------|------|
| 1. Data Layer | Model extension, helpers, extensions | 1-2 hours |
| 2. Register Screen | ViewModel, photo handling, form UI | 3-4 hours |
| 3. Calendar Tab | ViewModel, calendar grid, tab integration | 3-4 hours |
| 4. Historical View | ViewModel, all months display | 2-3 hours |
| 5. Polish & Testing | Permissions, testing, fixes | 1-2 hours |
| **Total** | | **10-15 hours** |

**Status**: ✅ Quickstart Complete | **Ready for**: Implementation (Phase 2 - tasks.md creation)
