//
//  RegisterCheckInViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - User Story 1
//

import SwiftUI
import SwiftData
import PhotosUI
import OSLog

/// Gerencia estado e lógica do formulário de registro de check-in
@Observable
final class RegisterCheckInViewModel {
    // MARK: - Published State
    
    /// Tipo de exercício selecionado
    var exerciseType: String = ""
    
    /// Título do check-in (obrigatório, max 100 chars)
    var title: String = ""
    
    /// Calorias queimadas (opcional)
    var calories: String = ""
    
    /// Localização do treino (opcional)
    var location: String = ""
    
    /// Data/hora do check-in
    var date: Date = Date()
    
    /// Item selecionado do PhotosPicker
    var selectedPhotoItem: PhotosPickerItem?
    
    /// Imagem carregada (câmera ou galeria)
    var photo: UIImage?
    
    /// Erros de validação
    var validationErrors: [String] = []
    
    /// Operação de salvamento em andamento
    var isSaving: Bool = false
    
    /// Check-in salvo com sucesso (dispara navegação)
    var didSave: Bool = false
    
    /// Mostrar alerta de mudanças não salvas
    var showUnsavedChangesAlert: Bool = false
    
    // MARK: - Private Dependencies
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Actions
    
    /// Atualiza tipo de exercício selecionado
    func setExerciseType(_ type: String) {
        exerciseType = type
        clearValidationError(containing: "exercício")
    }
    
    /// Atualiza título (com limite de 100 caracteres)
    func setTitle(_ value: String) {
        let trimmed = String(value.prefix(100))
        title = trimmed
        clearValidationError(containing: "título")
    }
    
    /// Atualiza calorias (valida numérico)
    func setCalories(_ value: String) {
        // Permite apenas números
        let filtered = value.filter { $0.isNumber }
        calories = filtered
        clearValidationError(containing: "calorias")
    }
    
    /// Atualiza localização
    func setLocation(_ value: String) {
        let trimmed = String(value.prefix(200))
        location = trimmed
    }
    
    /// Atualiza data/hora (não permite futuro)
    func setDate(_ value: Date) {
        if value > Date() {
            date = Date()
        } else {
            date = value
        }
        clearValidationError(containing: "data")
    }
    
    /// Define foto da câmera
    func setPhoto(_ image: UIImage) {
        photo = image
    }
    
    /// Carrega foto do PhotosPicker
    func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.photo = image
                }
            }
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.checkIn.error("Erro ao carregar foto: \(errorMessage)")
        }
    }
    
    /// Remove foto selecionada
    func clearPhoto() {
        photo = nil
        selectedPhotoItem = nil
    }
    
    /// Valida e salva check-in
    func save() async -> Bool {
        isSaving = true
        validationErrors = []
        
        // Validação
        let errors = validate()
        if !errors.isEmpty {
            validationErrors = errors
            isSaving = false
            return false
        }
        
        // Comprime foto se presente
        var photoData: Data? = nil
        if let photo = photo {
            photoData = photo.compressed()
            if photoData == nil {
                validationErrors = ["Erro ao processar foto. Tente outra imagem."]
                isSaving = false
                return false
            }
        }
        
        // Cria CheckIn
        let caloriesInt = Int(calories)
        let checkIn = CheckIn(
            date: date,
            photoData: photoData,
            exerciseType: exerciseType,
            title: title,
            calories: caloriesInt,
            location: location.isEmpty ? nil : location
        )
        
        // Salva no contexto
        modelContext.insert(checkIn)
        
        do {
            try modelContext.save()
            let hasPhotoValue = photoData != nil
            AppLogger.checkIn.info("Check-in salvo: tipo=\(self.exerciseType), hasPhoto=\(hasPhotoValue)")
            
            // Haptic feedback de sucesso
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            isSaving = false
            didSave = true
            return true
        } catch {
            let errorMessage = error.localizedDescription
            AppLogger.checkIn.error("Erro ao salvar check-in: \(errorMessage)")
            validationErrors = ["Erro ao salvar check-in. Tente novamente."]
            isSaving = false
            return false
        }
    }
    
    /// Reseta formulário para estado inicial
    func reset() {
        exerciseType = ""
        title = ""
        calories = ""
        location = ""
        date = Date()
        photo = nil
        selectedPhotoItem = nil
        validationErrors = []
        isSaving = false
        didSave = false
    }
    
    /// Verifica se há mudanças não salvas
    func hasUnsavedChanges() -> Bool {
        return !exerciseType.isEmpty ||
               !title.isEmpty ||
               !calories.isEmpty ||
               !location.isEmpty ||
               photo != nil
    }
    
    // MARK: - Private Helpers
    
    private func validate() -> [String] {
        var errors: [String] = []
        
        if exerciseType.isEmpty || !ExerciseType.isValid(exerciseType) {
            errors.append("Selecione um tipo de exercício")
        }
        
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Digite um título para o check-in")
        }
        
        if date > Date() {
            errors.append("Data do check-in não pode ser no futuro")
        }
        
        if let caloriesInt = Int(calories), caloriesInt < 0 {
            errors.append("Calorias não podem ser negativas")
        }
        
        return errors
    }
    
    private func clearValidationError(containing text: String) {
        validationErrors.removeAll { $0.localizedCaseInsensitiveContains(text) }
    }
}
