import UIKit
import PDFKit

extension PDFService {
    /// Generates two versions of a business card PDF: one for display (with QR code) and one for scanning
    /// - Parameter person: The person to create business cards for
    /// - Returns: Tuple containing URLs to both versions of the PDF, or nil if generation fails
    func generateBusinessCardWithQRCode(for person: DukePerson) -> (displayPDF: URL, scanPDF: URL)? {
        // Step 1: Generate the "scan" version (without QR code) first
        guard let scanPDFURL = generateBusinessCard(for: person) else {
            print("Failed to generate scan version PDF")
            return nil
        }
        
        // Step 2: Create a QR code that points to the scan PDF
        // Make QR code larger (100x100) for easier scanning
        let qrSize = CGSize(width: 200, height: 200)
        guard let qrImage = QRCodeService.shared.generateScannableQRCode(
            from: scanPDFURL,
            size: qrSize
        ) else {
            print("Failed to generate QR code")
            return nil
        }
        
        // Step 3: Generate a second PDF that includes the QR code below the business card
        let displayPDFURL = createDisplayVersionPDF(for: person, scanPDFURL: scanPDFURL, qrImage: qrImage)
        
        if let displayPDFURL = displayPDFURL {
            return (displayPDF: displayPDFURL, scanPDF: scanPDFURL)
        } else {
            // Clean up scan PDF if display version failed
            try? FileManager.default.removeItem(at: scanPDFURL)
            return nil
        }
    }
    
    /// Creates the display version of the PDF with embedded QR code
    private func createDisplayVersionPDF(for person: DukePerson, scanPDFURL: URL, qrImage: UIImage) -> URL? {
        // Create a temporary file URL for the display PDF
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = QRCodeService.shared.generateFileName(
            baseFileName: "BusinessCard_\(person.netID)",
            withQR: true
        )
        let displayPDFURL = tempDir.appendingPathComponent(fileName)
        
        // Define the extended PDF size to include space for QR code below the business card
        // Original card is 252x144, add 140 points for QR code and text below
        let extendedSize = CGSize(width: BusinessCardTemplate.size.width, height: BusinessCardTemplate.size.height + 140)
        
        // Create PDF renderer with extended size
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: extendedSize))
        
        do {
            // Generate PDF
            try renderer.writePDF(to: displayPDFURL) { context in
                // Add a single page
                context.beginPage()
                
                // Get the graphics context
                let ctx = context.cgContext
                
                // First draw the business card at the top
                // Draw background
                drawBackground(in: ctx)
                
                // Draw header with Duke logo and name
                drawHeader(for: person, in: ctx)
                
                // Draw avatar
                drawAvatar(for: person, in: ctx)
                
                // Draw person info
                drawPersonInfo(for: person, in: ctx)
                
                // Draw footer
                drawFooter(for: person, in: ctx)
                
                // Now draw QR code below the business card
                drawQRCode(qrImage, in: ctx, pdfHeight: extendedSize.height)
                
                // Draw scan instruction text
                drawScanInstructions(in: ctx, pdfHeight: extendedSize.height)
            }
            
            return displayPDFURL
        } catch {
            print("Error generating display PDF: \(error)")
            return nil
        }
    }
    
    /// Draws the QR code below the business card
    private func drawQRCode(_ qrImage: UIImage, in context: CGContext, pdfHeight: CGFloat) {
        // Position for QR code (centered below the business card)
        let qrSize = CGSize(width: 100, height: 100)
        let qrRect = CGRect(
            x: (BusinessCardTemplate.size.width - qrSize.width) / 2, // Center horizontally
            y: BusinessCardTemplate.size.height + 10, // 10 points below the business card
            width: qrSize.width,
            height: qrSize.height
        )
        
        // Draw the QR code image
        qrImage.draw(in: qrRect)
    }
    
    /// Draws text instructions for scanning the QR code
    private func drawScanInstructions(in context: CGContext, pdfHeight: CGFloat) {
        let instructionText = "Scan QR code to view digital business card"
        let instructionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        
        // Position the text below the QR code
        let textRect = CGRect(
            x: 0,
            y: BusinessCardTemplate.size.height + 115, // Below the QR code
            width: BusinessCardTemplate.size.width,
            height: 20
        )
        
        // Center the text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        var attrs = instructionAttrs
        attrs[.paragraphStyle] = paragraphStyle
        
        // Draw the text
        (instructionText as NSString).draw(in: textRect, withAttributes: attrs)
    }
}
