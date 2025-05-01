import UIKit
import CoreImage

class QRCodeService {
    // Duke university blue color
    static let dukeBlue = UIColor(red: 0.0, green: 24/255, blue: 121/255, alpha: 1.0)
    
    // Singleton instance
    static let shared = QRCodeService()
    private init() {}
    
    // MARK: - Core QR Code Generation
    
    /// Generates a QR code from a URL
    /// - Parameters:
    ///   - url: The URL to encode in the QR code
    ///   - size: The desired size of the QR code image
    /// - Returns: A UIImage containing the QR code, or nil if generation fails
    func generateQRCode(from url: URL, size: CGSize) -> UIImage? {
        // Create the QR code filter
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            print("Could not create QR code filter")
            return nil
        }
        
        // Set the message content for the QR code
        let data = url.absoluteString.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        // Set the error correction level
        filter.setValue("M", forKey: "inputCorrectionLevel") // M = ~15% error correction
        
        // Get the output image
        guard let ciImage = filter.outputImage else {
            print("Could not generate QR code image")
            return nil
        }
        
        // Scale the image to the desired size
        let scale = min(size.width, size.height) / ciImage.extent.width
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // Convert CIImage to UIImage
        return UIImage(ciImage: scaledImage)
    }
    
    // MARK: - QR Code Styling
    
    /// Creates a simple, easy-to-scan QR code
    /// - Parameters:
    ///   - url: The URL to encode
    ///   - size: The desired size of the QR code
    /// - Returns: A UIImage containing the QR code
    func generateStyledQRCode(from url: URL, size: CGSize, addLogo: Bool = false) -> UIImage? {
        // Create the QR code filter
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        // Set the message content for the QR code
        let data = url.absoluteString.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        // Set the error correction level to H (highest) for better scan reliability
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        // Get the output image
        guard let ciImage = filter.outputImage else {
            return nil
        }
        
        // Create a context for rendering
        let context = CIContext()
        
        // Calculate scale to fit the desired size while leaving margin
        // The QR code should be slightly smaller than the container to ensure proper scanning
        let extent = ciImage.extent
        let scale = min(size.width, size.height) * 0.85 / extent.width
        
        // Scale the image
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = ciImage.transformed(by: transform)
        
        // Convert to CGImage
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        // Create a new context to draw the final image
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let drawContext = UIGraphicsGetCurrentContext()!
        
        // Fill with white background
        drawContext.setFillColor(UIColor.white.cgColor)
        drawContext.fill(CGRect(origin: .zero, size: size))
        
        // Center the QR code
        let drawRect = CGRect(
            x: (size.width - scaledImage.extent.width) / 2,
            y: (size.height - scaledImage.extent.height) / 2,
            width: scaledImage.extent.width,
            height: scaledImage.extent.height
        )
        
        // Draw the QR code in black (best for scanning)
        UIImage(cgImage: cgImage).draw(in: drawRect)
        
        // Get the result
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
    /// Generates a highly scannable QR code
    /// - Parameters:
    ///   - url: The URL to encode
    ///   - size: The desired size of the QR code
    /// - Returns: A UIImage containing the QR code
    func generateScannableQRCode(from url: URL, size: CGSize) -> UIImage? {
        // Step 1: Generate the raw QR code with highest error correction
        guard let data = url.absoluteString.data(using: .utf8),
              let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        qrFilter.setValue(data, forKey: "inputMessage")
        // Use highest error correction level
        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let qrImage = qrFilter.outputImage else {
            return nil
        }
        
        // Step 2: Create a larger image with plenty of white space around the QR code
        // This ensures the "quiet zone" needed for reliable scanning
        
        // Convert to CGImage with proper scaling
        let transform = CGAffineTransform(scaleX: 10, y: 10) // Significant scaling for clarity
        let scaledQRImage = qrImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else {
            return nil
        }
        
        // Step 3: Create the final image with ample quiet zone
        let uiImage = UIImage(cgImage: cgImage)
        
        // Create a new context with even more padding
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        // Fill the entire context with white
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        
        // Draw the QR code centered, using only 70% of the available space
        // to ensure generous white margins
        let drawWidth = size.width * 0.7
        let drawHeight = size.height * 0.7
        let drawRect = CGRect(
            x: (size.width - drawWidth) / 2,
            y: (size.height - drawHeight) / 2,
            width: drawWidth,
            height: drawHeight
        )
        
        uiImage.draw(in: drawRect)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }

    // Helper method to create a CIImage for the QR code
    private func createQRCodeCIImage(from string: String) -> CIImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // H = Highest error correction (30%)
        
        return filter.outputImage
    }
    
    // MARK: - File Management
    
    /// Generates file names for QR code PDFs
    /// - Parameters:
    ///   - baseFileName: Base name for the files
    ///   - withQR: Whether this is the version with QR code
    /// - Returns: A file name with appropriate suffix
    func generateFileName(baseFileName: String, withQR: Bool) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let suffix = withQR ? "_with_qr" : "_scan"
        return "\(baseFileName)_\(timestamp)\(suffix).pdf"
    }
    
    /// Cleans up temporary QR code files
    func cleanupTempQRCodeFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: tempDir,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            // Remove files that match our naming pattern
            for fileURL in fileURLs {
                let fileName = fileURL.lastPathComponent
                if fileName.contains("_with_qr") || fileName.contains("_scan") {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("Error cleaning up QR code files: \(error)")
        }
    }
    
    func generateQRCodeForCard(person: DukePerson) -> UIImage? {
        // 如果已有卡片URL，直接用它生成QR码
        if !person.cardImageURL.isEmpty, let url = URL(string: person.cardImageURL) {
            return QRCodeService.shared.generateScannableQRCode(from: url, size: CGSize(width: 200, height: 200))
        }
        
        // 如果没有URL，可以返回null或显示错误提示
        return nil
    }
}
