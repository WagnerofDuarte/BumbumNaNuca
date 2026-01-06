# Guia de Componentes UI - BumbumNaNuca

## Visão Geral

Este documento detalha todos os componentes de UI do aplicativo, desde telas completas até componentes reutilizáveis, seguindo o design system e boas práticas de SwiftUI.

---

## 1. Design System

### 1.1 Paleta de Cores

```swift
// Colors+Theme.swift
extension Color {
    // Primary Colors
    static let appPrimary = Color("PrimaryColor")        // #007AFF
    static let appSecondary = Color("SecondaryColor")    // #FF9500
    
    // Semantic Colors
    static let appSuccess = Color.green                  // #34C759
    static let appDanger = Color.red                     // #FF3B30
    static let appWarning = Color.orange                 // #FF9500
    static let appInfo = Color.blue                      // #007AFF
    
    // Neutral Colors
    static let appBackground = Color("BackgroundColor")   // Sistema adaptativo
    static let appCardBackground = Color("CardBackground")
    static let appBorder = Color.gray.opacity(0.2)
    
    // Text Colors
    static let appTextPrimary = Color.primary
    static let appTextSecondary = Color.secondary
    static let appTextTertiary = Color.gray
    
    // Muscle Group Colors
    static let muscleChest = Color.blue
    static let muscleBack = Color.green
    static let muscleLegs = Color.orange
    static let muscleShoulders = Color.purple
    static let muscleArms = Color.red
    static let muscleAbs = Color.yellow
    static let muscleCardio = Color.pink
}
```

### 1.2 Tipografia

```swift
// Typography.swift
enum AppFont {
    // Titles
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .bold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    // Body
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    
    // Utility
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)
    
    // Numbers (Monospaced)
    static let numberLarge = Font.system(size: 48, weight: .bold, design: .rounded).monospacedDigit()
    static let numberMedium = Font.system(size: 24, weight: .semibold, design: .rounded).monospacedDigit()
    static let numberSmall = Font.system(size: 16, weight: .regular, design: .rounded).monospacedDigit()
}
```

### 1.3 Espaçamento

```swift
// Spacing.swift
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    
    // Specific
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 16
    static let buttonHeight: CGFloat = 50
    static let minTappableSize: CGFloat = 44
}
```

### 1.4 Cantos Arredondados

```swift
enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 20
    static let button: CGFloat = 12
    static let card: CGFloat = 16
}
```

---

## 2. Componentes Base

### 2.1 Buttons

#### PrimaryButton
```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(AppFont.bodyBold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Spacing.buttonHeight)
            .background(isDisabled ? Color.gray : Color.appPrimary)
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.button)
        }
        .disabled(isDisabled || isLoading)
    }
}
```

#### SecondaryButton
```swift
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.bodyBold)
                .frame(maxWidth: .infinity)
                .frame(height: Spacing.buttonHeight)
                .background(Color.clear)
                .foregroundColor(Color.appPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.button)
                        .stroke(Color.appPrimary, lineWidth: 2)
                )
        }
        .disabled(isDisabled)
    }
}
```

#### IconButton
```swift
struct IconButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 24
    var color: Color = .appPrimary
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(color)
                .frame(width: Spacing.minTappableSize, height: Spacing.minTappableSize)
        }
    }
}
```

### 2.2 Cards

#### BaseCard
```swift
struct BaseCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(Spacing.cardPadding)
            .background(Color.appCardBackground)
            .cornerRadius(CornerRadius.card)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
```

#### WorkoutPlanCard
```swift
struct WorkoutPlanCard: View {
    let plan: WorkoutPlan
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            BaseCard {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text(plan.name)
                            .font(AppFont.title3)
                            .foregroundColor(.appTextPrimary)
                        
                        Spacer()
                        
                        if plan.isActive {
                            Badge(text: "Ativo", color: .appSuccess)
                        }
                    }
                    
                    HStack {
                        Label("\(plan.exercises.count) exercícios", 
                              systemImage: "figure.strengthtraining.traditional")
                            .font(AppFont.callout)
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        if let lastSession = plan.sessions.last {
                            Text("Último: \(lastSession.startDate.formatted(.relative(presentation: .named)))")
                                .font(AppFont.caption)
                                .foregroundColor(.appTextTertiary)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

### 2.3 Badges e Tags

#### Badge
```swift
struct Badge: View {
    let text: String
    var color: Color = .appPrimary
    
    var body: some View {
        Text(text)
            .font(AppFont.captionBold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(color)
            .cornerRadius(CornerRadius.small)
    }
}
```

#### MuscleGroupTag
```swift
struct MuscleGroupTag: View {
    let muscleGroup: MuscleGroup
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(muscleGroup.color)
                .frame(width: 8, height: 8)
            
            Text(muscleGroup.rawValue)
                .font(AppFont.caption)
                .foregroundColor(.appTextSecondary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical: Spacing.xxs)
        .background(muscleGroup.color.opacity(0.1))
        .cornerRadius(CornerRadius.small)
    }
}

extension MuscleGroup {
    var color: Color {
        switch self {
        case .chest: return .muscleChest
        case .back: return .muscleBack
        case .legs: return .muscleLegs
        case .shoulders: return .muscleShoulders
        case .arms: return .muscleArms
        case .abs: return .muscleAbs
        case .cardio: return .muscleCardio
        }
    }
}
```

### 2.4 Estados

#### EmptyStateView
```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.appTextTertiary)
            
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(AppFont.title2)
                    .foregroundColor(.appTextPrimary)
                
                Text(description)
                    .font(AppFont.callout)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, Spacing.md)
            }
        }
        .padding(Spacing.xl)
    }
}
```

#### LoadingView
```swift
struct LoadingView: View {
    var message: String = "Carregando..."
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(AppFont.callout)
                .foregroundColor(.appTextSecondary)
        }
    }
}
```

#### ErrorView
```swift
struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.appDanger)
            
            Text("Ops! Algo deu errado")
                .font(AppFont.title3)
                .foregroundColor(.appTextPrimary)
            
            Text(message)
                .font(AppFont.callout)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                SecondaryButton(title: "Tentar Novamente", action: retryAction)
                    .padding(.top, Spacing.md)
            }
        }
        .padding(Spacing.xl)
    }
}
```

---

## 3. Componentes Específicos

### 3.1 Timer Components

#### RestTimerView
```swift
struct RestTimerView: View {
    @StateObject private var viewModel: RestTimerViewModel
    
    init(duration: Int) {
        _viewModel = StateObject(wrappedValue: RestTimerViewModel(duration: duration))
    }
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(Color.appBorder, lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.progress)
                
                VStack(spacing: Spacing.xs) {
                    Text(viewModel.timeString)
                        .font(AppFont.numberLarge)
                        .foregroundColor(.appTextPrimary)
                    
                    Text("Descanso")
                        .font(AppFont.caption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            .frame(width: 200, height: 200)
            
            // Controls
            HStack(spacing: Spacing.md) {
                IconButton(
                    icon: viewModel.isPaused ? "play.fill" : "pause.fill",
                    action: viewModel.togglePause,
                    size: 28
                )
                
                IconButton(
                    icon: "arrow.clockwise",
                    action: viewModel.reset,
                    size: 28,
                    color: .appSecondary
                )
                
                IconButton(
                    icon: "forward.fill",
                    action: viewModel.skip,
                    size: 28,
                    color: .appTextSecondary
                )
            }
        }
        .padding(Spacing.xl)
    }
}

class RestTimerViewModel: ObservableObject {
    @Published var remainingTime: Int
    @Published var isPaused = true
    
    let totalDuration: Int
    private var timer: Timer?
    
    var progress: Double {
        Double(remainingTime) / Double(totalDuration)
    }
    
    var timeString: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(duration: Int) {
        self.totalDuration = duration
        self.remainingTime = duration
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            stopTimer()
            // Trigger haptic and sound
            HapticService.shared.notification(.success)
            NotificationService.shared.playTimerSound()
        }
    }
    
    func reset() {
        stopTimer()
        remainingTime = totalDuration
        isPaused = true
    }
    
    func skip() {
        stopTimer()
        isPaused = true
    }
}
```

### 3.2 Exercise Components

#### ExerciseRow
```swift
struct ExerciseRow: View {
    let exercise: Exercise
    var showDragHandle: Bool = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            if showDragHandle {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.appTextTertiary)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(exercise.name)
                    .font(AppFont.body)
                    .foregroundColor(.appTextPrimary)
                
                HStack(spacing: Spacing.sm) {
                    MuscleGroupTag(muscleGroup: exercise.muscleGroup)
                    
                    Text("\(exercise.defaultSets)x\(exercise.defaultReps)")
                        .font(AppFont.caption)
                        .foregroundColor(.appTextSecondary)
                    
                    if exercise.videoURL != nil {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.appPrimary)
                            .font(.system(size: 12))
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.appTextTertiary)
        }
        .padding(.vertical, Spacing.xs)
    }
}
```

#### SetTrackerView
```swift
struct SetTrackerView: View {
    @Binding var weight: String
    @Binding var reps: String
    let setNumber: Int
    let previousSet: ExerciseSet?
    let onComplete: () -> Void
    
    var body: some View {
        BaseCard {
            VStack(spacing: Spacing.md) {
                // Header
                HStack {
                    Text("Série \(setNumber)")
                        .font(AppFont.title3)
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    if let previous = previousSet {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Último:")
                                .font(AppFont.caption)
                                .foregroundColor(.appTextTertiary)
                            Text("\(previous.weight ?? 0, specifier: "%.1f")kg × \(previous.reps)")
                                .font(AppFont.captionBold)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
                
                // Inputs
                HStack(spacing: Spacing.md) {
                    // Weight Input
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Peso (kg)")
                            .font(AppFont.caption)
                            .foregroundColor(.appTextSecondary)
                        
                        TextField("0.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .font(AppFont.numberMedium)
                            .padding(Spacing.sm)
                            .background(Color.appBackground)
                            .cornerRadius(CornerRadius.small)
                    }
                    
                    // Reps Input
                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text("Repetições")
                            .font(AppFont.caption)
                            .foregroundColor(.appTextSecondary)
                        
                        TextField("0", text: $reps)
                            .keyboardType(.numberPad)
                            .font(AppFont.numberMedium)
                            .padding(Spacing.sm)
                            .background(Color.appBackground)
                            .cornerRadius(CornerRadius.small)
                    }
                }
                
                // Complete Button
                PrimaryButton(title: "Concluir Série", action: onComplete)
            }
        }
    }
}
```

#### VideoPlayerView
```swift
import WebKit

struct VideoPlayerView: View {
    let videoURL: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            YouTubeWebView(url: videoURL)
                .navigationTitle("Vídeo Instrucional")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fechar") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

struct YouTubeWebView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let videoID = extractVideoID(from: url) else { return }
        
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <body style="margin:0; padding:0;">
        <iframe width="100%" height="100%" 
                src="https://www.youtube.com/embed/\(videoID)" 
                frameborder="0" 
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                allowfullscreen>
        </iframe>
        </body>
        </html>
        """
        
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    private func extractVideoID(from url: String) -> String? {
        // Extract video ID from YouTube URL
        // Example: https://www.youtube.com/watch?v=VIDEO_ID
        // or: https://youtu.be/VIDEO_ID
        let patterns = [
            "(?<=watch\\?v=)[^&]+",
            "(?<=youtu.be/)[^&]+"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
                return String(url[Range(match.range, in: url)!])
            }
        }
        return nil
    }
}
```

### 3.3 Progress Components

#### LoadProgressChart
```swift
import Charts

struct LoadProgressChart: View {
    let exerciseSets: [ExerciseSet]
    
    private var chartData: [ChartDataPoint] {
        exerciseSets
            .sorted(by: { $0.completedDate < $1.completedDate })
            .compactMap { set in
                guard let weight = set.weight else { return nil }
                return ChartDataPoint(
                    date: set.completedDate,
                    value: weight,
                    label: "\(weight)kg"
                )
            }
    }
    
    var body: some View {
        BaseCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Evolução de Carga")
                    .font(AppFont.title3)
                
                if chartData.isEmpty {
                    EmptyStateView(
                        icon: "chart.xyaxis.line",
                        title: "Sem dados",
                        description: "Complete treinos para ver sua evolução"
                    )
                } else {
                    Chart(chartData) { dataPoint in
                        LineMark(
                            x: .value("Data", dataPoint.date),
                            y: .value("Carga", dataPoint.value)
                        )
                        .foregroundStyle(Color.appPrimary)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Data", dataPoint.date),
                            y: .value("Carga", dataPoint.value)
                        )
                        .foregroundStyle(Color.appPrimary)
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5))
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
            }
        }
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}
```

#### PersonalRecordCard
```swift
struct PersonalRecordCard: View {
    let exercise: Exercise
    let record: ExerciseSet
    
    var body: some View {
        BaseCard {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(exercise.name)
                        .font(AppFont.bodyBold)
                        .foregroundColor(.appTextPrimary)
                    
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        
                        Text("\(record.weight ?? 0, specifier: "%.1f")kg × \(record.reps) reps")
                            .font(AppFont.title3)
                            .foregroundColor(.appPrimary)
                    }
                    
                    Text(record.completedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(AppFont.caption)
                        .foregroundColor(.appTextTertiary)
                }
                
                Spacer()
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow.opacity(0.3))
            }
        }
    }
}
```

### 3.4 Check-in Components

#### CheckInButton
```swift
struct CheckInButton: View {
    @Binding var hasCheckedInToday: Bool
    let onCheckIn: () -> Void
    
    var body: some View {
        Button(action: onCheckIn) {
            HStack {
                Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(hasCheckedInToday ? "Check-in realizado!" : "Fazer Check-in")
                        .font(AppFont.bodyBold)
                    
                    Text(hasCheckedInToday ? "Bom treino!" : "Marque sua presença hoje")
                        .font(AppFont.caption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
            }
            .padding(Spacing.md)
            .background(hasCheckedInToday ? Color.appSuccess.opacity(0.1) : Color.appCardBackground)
            .foregroundColor(hasCheckedInToday ? .appSuccess : .appPrimary)
            .cornerRadius(CornerRadius.card)
        }
        .disabled(hasCheckedInToday)
    }
}
```

#### StreakDisplay
```swift
struct StreakDisplay: View {
    let currentStreak: Int
    let bestStreak: Int
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            StreakItem(
                icon: "flame.fill",
                title: "Sequência Atual",
                value: currentStreak,
                color: .orange
            )
            
            Divider()
            
            StreakItem(
                icon: "star.fill",
                title: "Melhor Sequência",
                value: bestStreak,
                color: .yellow
            )
        }
        .padding(Spacing.md)
        .background(Color.appCardBackground)
        .cornerRadius(CornerRadius.card)
    }
}

struct StreakItem: View {
    let icon: String
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text("\(value)")
                .font(AppFont.numberMedium)
                .foregroundColor(.appTextPrimary)
            
            Text(title)
                .font(AppFont.caption)
                .foregroundColor(.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
```

#### AttendanceCalendarView
```swift
struct AttendanceCalendarView: View {
    let checkIns: [CheckIn]
    @State private var selectedDate = Date()
    
    private var datesWithCheckIn: Set<DateComponents> {
        Set(checkIns.map {
            Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
        })
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Frequência Mensal")
                .font(AppFont.title3)
            
            // Calendar grid would go here
            // Using DatePicker in calendar mode or custom calendar grid
            
            HStack(spacing: Spacing.md) {
                LegendItem(color: .appSuccess, text: "Treino realizado")
                LegendItem(color: .appBorder, text: "Sem treino")
            }
            .font(AppFont.caption)
        }
        .padding(Spacing.md)
    }
}

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: Spacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(text)
                .foregroundColor(.appTextSecondary)
        }
    }
}
```

---

## 4. Telas Principais

### 4.1 HomeView

```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Olá, Atleta!")
                                .font(AppFont.largeTitle)
                            
                            Text(Date().formatted(date: .long, time: .omitted))
                                .font(AppFont.callout)
                                .foregroundColor(.appTextSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, Spacing.screenPadding)
                    
                    // Check-in
                    CheckInButton(
                        hasCheckedInToday: $viewModel.hasCheckedInToday,
                        onCheckIn: viewModel.performCheckIn
                    )
                    .padding(.horizontal, Spacing.screenPadding)
                    
                    // Streak
                    StreakDisplay(
                        currentStreak: viewModel.currentStreak,
                        bestStreak: viewModel.bestStreak
                    )
                    .padding(.horizontal, Spacing.screenPadding)
                    
                    // Active Plan
                    if let activePlan = viewModel.activePlan {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Plano Ativo")
                                .font(AppFont.title3)
                                .padding(.horizontal, Spacing.screenPadding)
                            
                            ActivePlanCard(
                                plan: activePlan,
                                onStart: { viewModel.startWorkout(plan: activePlan) }
                            )
                            .padding(.horizontal, Spacing.screenPadding)
                        }
                    }
                    
                    // Last Workout
                    if let lastSession = viewModel.lastWorkoutSession {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Último Treino")
                                .font(AppFont.title3)
                                .padding(.horizontal, Spacing.screenPadding)
                            
                            LastWorkoutSummary(session: lastSession)
                                .padding(.horizontal, Spacing.screenPadding)
                        }
                    }
                }
                .padding(.vertical, Spacing.md)
            }
            .navigationTitle("BumbumNaNuca")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
```

---

## 5. View Modifiers Customizados

### 5.1 Card Style
```swift
extension View {
    func cardStyle() -> some View {
        self
            .padding(Spacing.cardPadding)
            .background(Color.appCardBackground)
            .cornerRadius(CornerRadius.card)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
```

### 5.2 Loading Overlay
```swift
extension View {
    func loadingOverlay(isLoading: Bool, message: String = "Carregando...") -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    LoadingView(message: message)
                        .padding(Spacing.xl)
                        .background(Color.appCardBackground)
                        .cornerRadius(CornerRadius.card)
                }
            }
        }
    }
}
```

### 5.3 Error Alert
```swift
extension View {
    func errorAlert(error: Binding<String?>) -> some View {
        self.alert("Erro", isPresented: .constant(error.wrappedValue != nil)) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let errorMessage = error.wrappedValue {
                Text(errorMessage)
            }
        }
    }
}
```

---

## 6. Animações

### 6.1 Animações Padrão
```swift
// Transições suaves
.animation(.easeInOut(duration: 0.3), value: someState)

// Spring animation para interações
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: someState)

// Transitions
.transition(.move(edge: .trailing).combined(with: .opacity))
```

### 6.2 Exemplos de Uso
```swift
// Card aparecendo
@State private var showCard = false

BaseCard { ... }
    .opacity(showCard ? 1 : 0)
    .offset(y: showCard ? 0 : 20)
    .onAppear {
        withAnimation(.easeOut(duration: 0.4)) {
            showCard = true
        }
    }

// Button press feedback
@State private var isPressed = false

PrimaryButton(...)
    .scaleEffect(isPressed ? 0.95 : 1.0)
    .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = pressing
        }
    }) { }
```

---

## 7. Acessibilidade

### 7.1 Labels e Hints
```swift
Button(action: {}) {
    Image(systemName: "plus")
}
.accessibilityLabel("Adicionar exercício")
.accessibilityHint("Toque duas vezes para adicionar um novo exercício ao plano")
```

### 7.2 Dynamic Type
```swift
// Usar fonts do sistema que escalam automaticamente
Text("Título")
    .font(AppFont.title1)
    .minimumScaleFactor(0.8)
    .lineLimit(2)
```

### 7.3 Contrast
```swift
// Garantir contraste adequado
Text("Importante")
    .foregroundColor(.appTextPrimary) // Sempre contra background adequado
```

---

## Resumo

Este guia de componentes fornece:
- ✅ Design system consistente
- ✅ Componentes reutilizáveis e testáveis
- ✅ Padrões de UI/UX seguindo HIG
- ✅ Acessibilidade incorporada
- ✅ Animações suaves e naturais
- ✅ Código modular e manutenível

Todos os componentes devem seguir estes padrões para garantir uma experiência consistente em todo o aplicativo.
