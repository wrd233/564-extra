import UIKit
import PDFKit

class PDFService {
    // Singleton pattern
    static let shared = PDFService()
    private init() {}
    
    // Generate a business card PDF for a person
    func generateBusinessCard(for person: DukePerson) -> URL? {
        // Create PDF renderer with business card size
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: BusinessCardTemplate.size))
        
        // Create a temporary file URL for the PDF
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "BusinessCard_\(person.netID)_\(Int(Date().timeIntervalSince1970)).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            // Generate PDF
            try renderer.writePDF(to: fileURL) { context in
                // Add a single page
                context.beginPage()
                
                // Get the graphics context
                let ctx = context.cgContext
                
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
            }
            
            return fileURL
        } catch {
            print("Error generating PDF: \(error)")
            return nil
        }
    }
    
    // Clean up temporary PDF files
    func cleanupTempFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: tempDir,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            for fileURL in fileURLs where fileURL.lastPathComponent.hasPrefix("BusinessCard_") {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error cleaning up temp files: \(error)")
        }
    }
    
    // MARK: - Private Drawing Methods
    
    internal func drawBackground(in context: CGContext) {
        // Fill the entire card with background color
        context.setFillColor(BusinessCardTemplate.backgroundColor.cgColor)
        context.fill(CGRect(origin: .zero, size: BusinessCardTemplate.size))
        
        // Draw a border
        context.setStrokeColor(BusinessCardTemplate.primaryColor.cgColor)
        context.setLineWidth(1.0)
        context.stroke(CGRect(origin: .zero, size: BusinessCardTemplate.size))
        
        // Draw a header bar
        let headerRect = CGRect(x: 0, y: 0, width: BusinessCardTemplate.size.width, height: 30)
        context.setFillColor(BusinessCardTemplate.primaryColor.cgColor)
        context.fill(headerRect)
    }
    
    internal func drawHeader(for person: DukePerson, in context: CGContext) {
        // Draw "DUKE UNIVERSITY" text in header
        let headerText = "DUKE UNIVERSITY"
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ]
        
        let headerTextRect = CGRect(x: BusinessCardTemplate.margin, y: 8,
                                   width: BusinessCardTemplate.size.width - 2 * BusinessCardTemplate.margin,
                                   height: 20)
        
        (headerText as NSString).draw(in: headerTextRect, withAttributes: headerAttrs)
    }
    
    internal func drawAvatar(for person: DukePerson, in context: CGContext) {
        // Position for avatar
        let avatarRect = CGRect(
            x: BusinessCardTemplate.margin,
            y: 40,
            width: BusinessCardTemplate.avatarSize.width,
            height: BusinessCardTemplate.avatarSize.height
        )
        
        // Try to create image from person's picture data
        if !person.picture.isEmpty, let imageData = Data(base64Encoded: person.picture),
           let image = UIImage(data: imageData) {
            // Save context state
            context.saveGState()
            
            // Create and add circular clipping path for avatar
            let avatarPath = CGPath(ellipseIn: avatarRect, transform: nil)
            context.addPath(avatarPath)
            context.clip()
            
            // Draw the image
            image.draw(in: avatarRect)
            
            // Restore context state
            context.restoreGState()
            
            // Draw circle around avatar
            context.setStrokeColor(BusinessCardTemplate.primaryColor.cgColor)
            context.setLineWidth(1.0)
            context.addPath(avatarPath)
            context.strokePath()
        } else {
            // If no image, draw a placeholder circle
            context.setStrokeColor(BusinessCardTemplate.primaryColor.cgColor)
            context.setLineWidth(1.0)
            context.addEllipse(in: avatarRect)
            context.strokePath()
            
            // Draw placeholder text
            let initialsText = String(person.fName.prefix(1)) + String(person.lName.prefix(1))
            let initialsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: BusinessCardTemplate.primaryColor
            ]
            
            let textSize = initialsText.size(withAttributes: initialsAttributes)
            let textX = avatarRect.midX - textSize.width / 2
            let textY = avatarRect.midY - textSize.height / 2
            
            (initialsText as NSString).draw(
                at: CGPoint(x: textX, y: textY),
                withAttributes: initialsAttributes
            )
        }
    }
    
    internal func drawPersonInfo(for person: DukePerson, in context: CGContext) {
        // Starting position for text (to the right of the avatar)
        let textX = BusinessCardTemplate.margin * 2 + BusinessCardTemplate.avatarSize.width
        var textY: CGFloat = 40
        
        // Draw name
        let nameText = "\(person.fName) \(person.lName)"
        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: BusinessCardTemplate.nameFont,
            .foregroundColor: BusinessCardTemplate.primaryColor
        ]
        (nameText as NSString).draw(
            at: CGPoint(x: textX, y: textY),
            withAttributes: nameAttrs
        )
        textY += 18
        
        // Draw role
        let roleText = "\(person.role.rawValue), Duke University"
        let roleAttrs: [NSAttributedString.Key: Any] = [
            .font: BusinessCardTemplate.titleFont,
            .foregroundColor: BusinessCardTemplate.secondaryColor
        ]
        (roleText as NSString).draw(
            at: CGPoint(x: textX, y: textY),
            withAttributes: roleAttrs
        )
        textY += 16
        
        // Draw program and plan if applicable
        if person.program != .NotApplicable {
            let programText = "\(person.program.rawValue) - \(person.plan.rawValue)"
            let programAttrs: [NSAttributedString.Key: Any] = [
                .font: BusinessCardTemplate.detailFont,
                .foregroundColor: BusinessCardTemplate.secondaryColor
            ]
            (programText as NSString).draw(
                at: CGPoint(x: textX, y: textY),
                withAttributes: programAttrs
            )
            textY += 14
        }
        
        // Draw email
        let emailText = "Email: \(person.email)"
        let emailAttrs: [NSAttributedString.Key: Any] = [
            .font: BusinessCardTemplate.detailFont,
            .foregroundColor: UIColor.black
        ]
        (emailText as NSString).draw(
            at: CGPoint(x: textX, y: textY),
            withAttributes: emailAttrs
        )
        textY += 14
        
        // Draw DUID
        let duidText = "DUID: \(person.DUID)"
        let duidAttrs: [NSAttributedString.Key: Any] = [
            .font: BusinessCardTemplate.detailFont,
            .foregroundColor: UIColor.black
        ]
        (duidText as NSString).draw(
            at: CGPoint(x: textX, y: textY),
            withAttributes: duidAttrs
        )
    }
    
    internal func drawFooter(for person: DukePerson, in context: CGContext) {
        // Position for footer
        let footerY = BusinessCardTemplate.size.height - BusinessCardTemplate.margin - 12
        
        // Draw from location if available
        if !person.from.isEmpty {
            let fromText = "From: \(person.from)"
            let fromAttrs: [NSAttributedString.Key: Any] = [
                .font: BusinessCardTemplate.detailFont,
                .foregroundColor: BusinessCardTemplate.secondaryColor
            ]
            (fromText as NSString).draw(
                at: CGPoint(x: BusinessCardTemplate.margin, y: footerY),
                withAttributes: fromAttrs
            )
        }
        
        // Draw team if available
        if !person.team.isEmpty {
            let teamText = "Team: \(person.team)"
            let teamAttrs: [NSAttributedString.Key: Any] = [
                .font: BusinessCardTemplate.detailFont,
                .foregroundColor: BusinessCardTemplate.secondaryColor
            ]
            
            let teamTextSize = teamText.size(withAttributes: teamAttrs)
            let teamX = BusinessCardTemplate.size.width - BusinessCardTemplate.margin - teamTextSize.width
            
            (teamText as NSString).draw(
                at: CGPoint(x: teamX, y: footerY),
                withAttributes: teamAttrs
            )
        }
    }
}
