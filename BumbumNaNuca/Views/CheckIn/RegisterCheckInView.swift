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
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: RegisterCheckInViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Tipo de Exercício
                Section {
                    ExerciseTypePicker(selectedType: $viewModel.exerciseType)
                }
                
                // Foto
                Section {
                    photoSection
                } header: {
                    Text("Foto do Treino")
                }
                
                // Título
                Section {
                    TextField("Título do Check-in", text: Binding(
                        get: { viewModel.title },
                        set: { viewModel.setTitle($0) }
                    ))
                } header: {
                    Text("Título")
                } footer: {
                    Text("\(viewModel.title.count)/100 caracteres")
                }
                
                // Detalhes Opcionais
                Section {
                    // Calorias
                    TextField("Calorias", text: Binding(
                        get: { viewModel.calories },
                        set: { viewModel.setCalories($0) }
                    ))
                    .keyboardType(.numberPad)
                    
                    // Localização
                    TextField("Localização", text: Binding(
                        get: { viewModel.location },
                        set: { viewModel.setLocation($0) }
                    ))
                } header: {
                    Text("Detalhes Opcionais")
                } footer: {
                    if !viewModel.location.isEmpty {
                        Text("\(viewModel.location.count)/200 caracteres")
                    }
                }
                
                // Data/Hora
                Section {
                    DatePicker(
                        "Data e Hora",
                        selection: Binding(
                            get: { viewModel.date },
                            set: { viewModel.setDate($0) }
                        ),
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                } header: {
                    Text("Quando")
                }
                
                // Erros de validação
                if !viewModel.validationErrors.isEmpty {
                    Section {
                        ForEach(viewModel.validationErrors, id: \.self) { error in
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.callout)
                        }
                    }
                }
            }
            .navigationTitle("Registrar Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        handleDismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Check In") {
                        Task {
                            let success = await viewModel.save()
                            if success {
                                dismiss()
                            }
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
    
    // MARK: - Photo Section
    
    @ViewBuilder
    private var photoSection: some View {
        if let photo = viewModel.photo {
            // Mostra foto selecionada
            VStack(spacing: 12) {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button(role: .destructive) {
                    viewModel.clearPhoto()
                } label: {
                    Label("Remover Foto", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
            }
        } else {
            // Botões para adicionar foto
            VStack(spacing: 12) {
                Button {
                    requestCameraPermission()
                } label: {
                    Label("Tirar Foto", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images
                ) {
                    Label("Escolher da Galeria", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                    Task {
                        await viewModel.loadPhoto(from: newItem)
                    }
                }
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

#Preview("Empty Form") {
    RegisterCheckInView(modelContext: ModelContext(
        try! ModelContainer(for: CheckIn.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ))
}
