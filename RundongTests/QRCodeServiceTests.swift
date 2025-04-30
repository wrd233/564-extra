import XCTest
@testable import Rundong

final class QRCodeServiceTests: XCTestCase {
    
    // Test basic QR code generation
    func testGenerateQRCode() {
        // Create a test URL
        let testURL = URL(string: "https://example.com/test")!
        
        // Generate QR code
        let qrImage = QRCodeService.shared.generateQRCode(from: testURL, size: CGSize(width: 200, height: 200))
        
        // Verify QR code was generated
        XCTAssertNotNil(qrImage, "QR code image should be generated successfully")
        
        // Verify image has expected size
        XCTAssertEqual(qrImage?.size.width, 200, "QR code should have requested width")
        XCTAssertEqual(qrImage?.size.height, 200, "QR code should have requested height")
    }
    
    // Test styled QR code generation
    func testGenerateStyledQRCode() {
        // Create a test URL
        let testURL = URL(string: "https://example.com/styled")!
        
        // Generate styled QR code with logo
        let styledQR = QRCodeService.shared.generateStyledQRCode(
            from: testURL,
            size: CGSize(width: 300, height: 300),
            addLogo: true
        )
        
        // Verify styled QR code was generated
        XCTAssertNotNil(styledQR, "Styled QR code should be generated successfully")
        
        // Verify image has expected size
        XCTAssertEqual(styledQR?.size.width, 300, "Styled QR code should have requested width")
        XCTAssertEqual(styledQR?.size.height, 300, "Styled QR code should have requested height")
    }
    
    // Test file name generation
    func testGenerateFileName() {
        let service = QRCodeService.shared
        
        // Test with QR version
        let qrFileName = service.generateFileName(baseFileName: "businesscard", withQR: true)
        XCTAssertTrue(qrFileName.contains("_with_qr"), "QR version filename should contain _with_qr suffix")
        
        // Test scan version
        let scanFileName = service.generateFileName(baseFileName: "businesscard", withQR: false)
        XCTAssertTrue(scanFileName.contains("_scan"), "Scan version filename should contain _scan suffix")
        
        // Test uniqueness
        let anotherFileName = service.generateFileName(baseFileName: "businesscard", withQR: true)
        XCTAssertNotEqual(qrFileName, anotherFileName, "Generated filenames should be unique")
    }
    
    // Test cleanup functionality
    func testCleanupTempQRCodeFiles() {
        let service = QRCodeService.shared
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        
        // Create some test files
        let testFilePaths = [
            tempDir.appendingPathComponent("test_123_with_qr.pdf"),
            tempDir.appendingPathComponent("test_456_scan.pdf"),
            tempDir.appendingPathComponent("unrelated_file.txt")
        ]
        
        // Create empty files
        for path in testFilePaths {
            fileManager.createFile(atPath: path.path, contents: Data(), attributes: nil)
        }
        
        // Run cleanup
        service.cleanupTempQRCodeFiles()
        
        // Verify QR files were removed but unrelated files remain
        XCTAssertFalse(fileManager.fileExists(atPath: testFilePaths[0].path), "QR file should be removed")
        XCTAssertFalse(fileManager.fileExists(atPath: testFilePaths[1].path), "Scan file should be removed")
        XCTAssertTrue(fileManager.fileExists(atPath: testFilePaths[2].path), "Unrelated file should remain")
        
        // Clean up the remaining test file
        try? fileManager.removeItem(at: testFilePaths[2])
    }
}
