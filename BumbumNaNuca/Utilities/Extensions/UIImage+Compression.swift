//
//  UIImage+Compression.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow
//

import UIKit

extension UIImage {
    /// Comprime a imagem para JPEG com qualidade ajustável
    /// - Parameters:
    ///   - maxSizeBytes: Tamanho máximo em bytes (padrão: 2MB)
    /// - Returns: Data comprimido ou nil se falhar
    func compressed(maxSizeBytes: Int = 2_000_000) -> Data? {
        var compression: CGFloat = 0.7  // Qualidade inicial: 70%
        var imageData = self.jpegData(compressionQuality: compression)
        
        // Reduz qualidade progressivamente até atingir tamanho alvo
        while let data = imageData, data.count > maxSizeBytes, compression > 0.1 {
            compression -= 0.1
            imageData = self.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}
