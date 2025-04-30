import XCTest
import SwiftData
@testable import Rundong

final class PDFServiceTests: XCTestCase {
    // Test generating a business card for a person with all fields
    func testGenerateBusinessCardWithFullInfo() {
        // Create a test person
        let person = DukePerson(
            DUID: 123456,
            netID: "test123",
            fName: "John",
            lName: "Doe",
            from: "USA",
            hobby: "Reading",
            languages: ["Swift", "Python"],
            moviegenre: "Sci-Fi",
            gender: .Male,
            role: .Student,
            program: .MENG,
            plan: .CS,
            team: "Team Alpha",
            picture: "" // No picture for this test
        )
        
        // Generate the business card
        let pdfURL = PDFService.shared.generateBusinessCard(for: person)
        
        // Verify PDF was generated
        XCTAssertNotNil(pdfURL, "PDF should be generated successfully")
        
        // Verify file exists
        if let url = pdfURL {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "PDF file should exist")
            
            // Cleanup test file
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    // Test generating a business card for a person with minimal info
    func testGenerateBusinessCardWithMinimalInfo() {
        // Create a test person with minimal information
        let person = DukePerson(
            DUID: 654321,
            netID: "min123",
            fName: "Jane",
            lName: "Smith",
            gender: .Female,
            role: .Unknown,
            program: .NotApplicable,
            plan: .NotApplicable
        )
        
        // Generate the business card
        let pdfURL = PDFService.shared.generateBusinessCard(for: person)
        
        // Verify PDF was generated
        XCTAssertNotNil(pdfURL, "PDF should be generated successfully")
        
        // Verify file exists
        if let url = pdfURL {
            XCTAssertTrue(FileManager.default.fileExists(atPath: url.path), "PDF file should exist")
            
            // Cleanup test file
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    // Test cleanup function
    func testCleanupTempFiles() {
        // Create a test person
        let person = DukePerson(
            DUID: 111222,
            netID: "clean123",
            fName: "Test",
            lName: "Cleanup",
            gender: .Unknown,
            role: .Student,
            program: .NotApplicable,
            plan: .NotApplicable
        )
        
        // Generate a few business cards
        _ = PDFService.shared.generateBusinessCard(for: person)
        _ = PDFService.shared.generateBusinessCard(for: person)
        
        // Run cleanup
        PDFService.shared.cleanupTempFiles()
        
        // Check that temp directory no longer contains our files
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: tempDir,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            // Count how many business card files remain
            let cardFiles = fileURLs.filter { $0.lastPathComponent.hasPrefix("BusinessCard_") }
            XCTAssertEqual(cardFiles.count, 0, "All business card temp files should be removed")
            
        } catch {
            XCTFail("Failed to check temp directory: \(error)")
        }
    }
}
