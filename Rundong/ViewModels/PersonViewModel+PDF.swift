import SwiftUI
import PDFKit

// PDF generation related extension for PersonViewModel
extension PersonViewModel {
    // Generate PDF business card for the current person
    func generatePDF() {
        // Update state to generating
        pdfState = .generating
        
        // Use background task to avoid blocking the UI
        Task {
            // Generate the PDF using PDFService
            if let pdfURL = PDFService.shared.generateBusinessCard(for: dukePerson) {
                // Update state with success and the URL
                await MainActor.run {
                    pdfState = .success(pdfURL)
                }
            } else {
                // Update state with failure
                await MainActor.run {
                    pdfState = .failure("Failed to generate PDF")
                }
            }
        }
    }
    
    // Reset PDF state when done
    func resetPDFState() {
        pdfState = .idle
    }
    
    // Clean up temporary PDF files
    func cleanupPDFFiles() {
        PDFService.shared.cleanupTempFiles()
    }
}
