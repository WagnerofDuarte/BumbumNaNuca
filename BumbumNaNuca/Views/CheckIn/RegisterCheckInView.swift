//
//  RegisterCheckInView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - User Story 1
//

import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

/// Tela de registro de check-in com foto, tipo de exercício e detalhes
struct RegisterCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: RegisterCheckInViewModel
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    
    let onComplete: (() -> Void)?
    
    init(modelContext: ModelContext, workoutSession: WorkoutSession? = nil, onComplete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: RegisterCheckInViewModel(modelContext: modelContext, workoutSession: workoutSession))
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // SECTION B: Training Details Form (Reordered)
                    VStack(alignment: .leading, spacing: 20) {
                        // 1. Title
                        titleSection
                        
                        // 2. Location
                        locationSection
                        
                        // 3. Calories Burned
                        caloriesSection
                        
                        // 4. Exercise Type
                        exerciseTypeSection
                        
                        // 5. Date & Time
                        dateTimeSection
                    }
                    .padding(.horizontal)
                    
                    // SECTION A: Training Photo (moved to bottom)
                    photoSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        handleDismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            let success = await viewModel.save()
                            if success {
                                dismiss();                                onComplete?()                            }
                        }
                    } label: {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Check In")
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }

            .sheet(isPresented: $showCamera) {
                CameraPicker(image: Binding(
                    get: { viewModel.photo },
                    set: { viewModel.setPhoto($0 ?? UIImage()) }
                ))
                .ignoresSafeArea()
            }
            .alert("Permissão Necessária", isPresented: $showPermissionAlert) {
                Button("Configurações", action: openSettings)
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text(permissionMessage)
            }
            .alert("Mudanças Não Salvas", isPresented: $viewModel.showUnsavedChangesAlert) {
                Button("Descartar", role: .destructive) {
                    dismiss()
                }
                Button("Continuar Editando", role: .cancel) { }
            } message: {
                Text("Você tem alterações não salvas. Deseja descartá-las?")
            }
        }
    }
    
    // MARK: - Title Section
    
    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Título")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            TextField("Digite o título do check-in", text: Binding(
                get: { viewModel.title },
                set: { viewModel.setTitle($0) }
            ))
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            if !viewModel.title.isEmpty {
                Text("\(viewModel.title.count)/100 caracteres")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Inline error
            if let error = viewModel.titleError {
                ErrorLabel(message: error)
            }
        }
    }
    
    // MARK: - Photo Section
    
    @ViewBuilder
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let photo = viewModel.photo {
                // Show selected photo
                VStack(alignment: .leading, spacing: 12) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Button(role: .destructive) {
                        viewModel.clearPhoto()
                    } label: {
                        Label("Remover Foto", systemImage: "trash")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .padding(.horizontal)
            } else {
                // Add Photo section
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        requestCameraPermission()
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                            Text("Tirar Foto")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    PhotosPicker(
                        selection: $viewModel.selectedPhotoItem,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                            Text("Escolher da Galeria")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                        Task {
                            await viewModel.loadPhoto(from: newItem)
                        }
                    }
                    
                    Text("Adicione uma foto do seu treino (opcional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Exercise Type Section
    
    @ViewBuilder
    private var exerciseTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tipo de Exercício")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Picker("Tipo de Exercício", selection: Binding(
                get: { viewModel.exerciseType },
                set: { viewModel.setExerciseType($0) }
            )) {
                Text("Selecione...").tag("")
                
                ForEach(ExerciseType.all, id: \.self) { type in
                    HStack {
                        let iconConfig = ExerciseType.icon(for: type)
                        Image(systemName: iconConfig.symbol)
                            .foregroundColor(iconConfig.color)
                        Text(type)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.menu)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Inline error
            if let error = viewModel.exerciseTypeError {
                ErrorLabel(message: error)
            }
        }
    }
    
    // MARK: - Calories Section
    
    @ViewBuilder
    private var caloriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calorias Queimadas")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            TextField("Digite as calorias", text: Binding(
                get: { viewModel.calories },
                set: { viewModel.setCalories($0) }
            ))
            .keyboardType(.numberPad)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Inline error
            if let error = viewModel.caloriesError {
                ErrorLabel(message: error)
            }
        }
    }
    
    // MARK: - Date & Time Section
    
    @ViewBuilder
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Data e Hora")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            DatePicker(
                "",
                selection: Binding(
                    get: { viewModel.date },
                    set: { viewModel.setDate($0) }
                ),
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Inline error
            if let error = viewModel.dateError {
                ErrorLabel(message: error)
            }
        }
    }
    
    // MARK: - Location Section
    
    @ViewBuilder
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Localização (Opcional)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            TextField("Digite a localização", text: Binding(
                get: { viewModel.location },
                set: { viewModel.setLocation($0) }
            ))
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            if !viewModel.location.isEmpty {
                Text("\(viewModel.location.count)/200 caracteres")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func handleDismiss() {
        if viewModel.hasUnsavedChanges() {
            viewModel.showUnsavedChangesAlert = true
        } else {
            dismiss()
        }
    }
    
    private func requestCameraPermission() {
        Task {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch status {
            case .authorized:
                await MainActor.run {
                    showCamera = true
                }
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run {
                    if granted {
                        showCamera = true
                    } else {
                        permissionMessage = "BumbumNaNuca precisa de acesso à câmera para tirar fotos dos seus treinos."
                        showPermissionAlert = true
                    }
                }
            case .denied, .restricted:
                await MainActor.run {
                    permissionMessage = "Acesso à câmera foi negado. Por favor, habilite nas Configurações do sistema."
                    showPermissionAlert = true
                }
            @unknown default:
                break
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Error Label Component

private struct ErrorLabel: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.caption)
            Text(message)
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.red)
        .cornerRadius(8)
    }
}

#Preview("Empty Form") {
    RegisterCheckInView(modelContext: ModelContext(
        try! ModelContainer(for: CheckIn.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ))
}
