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
    
    /// Creates a styled QR code with Duke colors and optional logo
    /// - Parameters:
    ///   - url: The URL to encode
    ///   - size: The desired size of the QR code
    ///   - addLogo: Whether to add the Duke logo in the center
    /// - Returns: A styled UIImage containing the QR code
    func generateStyledQRCode(from url: URL, size: CGSize, addLogo: Bool = true) -> UIImage? {
        // Generate the basic QR code with a slightly larger size to account for scaling
        guard let ciImage = createQRCodeCIImage(from: url.absoluteString) else {
            return nil
        }
        
        // Convert CIImage to CGImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        // Create a context to draw the styled QR code
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Calculate the scale to fit the QR code into our desired size
        let scale = min(size.width, size.height) / max(ciImage.extent.width, ciImage.extent.height)
        
        // 在变换之前保存状态
        context.saveGState()

        // 你的 translate/scale/draw 逻辑……
        context.translateBy(x: size.width/2, y: size.height/2)
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -ciImage.extent.width/2, y: -ciImage.extent.height/2)
        context.setFillColor(QRCodeService.dukeBlue.cgColor)
        context.draw(cgImage, in: ciImage.extent)

        // 恢复到保存前的状态（也就把 CTM、裁剪区、线宽、颜色等等都还原了）
        context.restoreGState()
        
        // Add rounded border
        let borderPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 5, y: 5),
                                                         size: CGSize(width: size.width - 10,
                                                                     height: size.height - 10)),
                                      cornerRadius: 10)
        QRCodeService.dukeBlue.setStroke()
        borderPath.lineWidth = 2
        borderPath.stroke()
        
        // Add Duke 'D' logo if requested
        if addLogo {
            let logoSize = CGSize(width: size.width * 0.2, height: size.height * 0.2)
            let logoRect = CGRect(
                x: (size.width - logoSize.width) / 2,
                y: (size.height - logoSize.height) / 2,
                width: logoSize.width,
                height: logoSize.height
            )
            
            // Draw white circle background for the logo
            UIColor.white.setFill()
            context.fillEllipse(in: logoRect.insetBy(dx: -8, dy: -8))
            
            // Draw the Duke 'D'
            let font = UIFont.boldSystemFont(ofSize: logoSize.height * 0.8)
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: QRCodeService.dukeBlue
            ]
            
            let text = "D"
            let textSize = text.size(withAttributes: textAttributes)
            text.draw(at: CGPoint(
                x: logoRect.midX - textSize.width / 2,
                y: logoRect.midY - textSize.height / 2
            ), withAttributes: textAttributes)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
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
}
