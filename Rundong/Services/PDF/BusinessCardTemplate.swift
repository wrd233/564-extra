import SwiftUI

// Simple template system for business cards
struct BusinessCardTemplate {
    // Standard business card size (3.5 x 2 inches in points @ 72DPI)
    static let size = CGSize(width: 252, height: 144)
    
    // Margins
    static let margin: CGFloat = 12
    
    // Colors for Duke theme
    static let primaryColor = UIColor(red: 0.0, green: 0.24, blue: 0.56, alpha: 1.0) // Duke Blue
    static let secondaryColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Gray
    static let backgroundColor = UIColor.white
    
    // Fonts
    static let nameFont = UIFont.boldSystemFont(ofSize: 16)
    static let titleFont = UIFont.systemFont(ofSize: 12)
    static let detailFont = UIFont.systemFont(ofSize: 10)
    
    // Avatar size
    static let avatarSize = CGSize(width: 48, height: 48)
}
