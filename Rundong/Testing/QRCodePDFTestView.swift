import SwiftUI
import PDFKit

struct QRCodePDFTestView: View {
    @State private var displayPDFURL: URL?
    @State private var scanPDFURL: URL?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    
    // Sample person for testing
    private let testPerson = DukePerson(
        DUID: 987654,
        netID: "test_pdf",
        fName: "PDF",
        lName: "Tester",
        from: "Testing Land",
        hobby: "QR Scanning",
        languages: ["Swift", "PDF"],
        moviegenre: "Tech Docs",
        gender: .Unknown,
        role: .Student,
        program: .MENG,
        plan: .CS,
        team: "QA Team",
        picture: ""
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("QR Code PDF Test")
                    .font(.largeTitle)
                    .padding()
                
                // Generate button
                Button {
                    generatePDFs()
                } label: {
                    Text("Generate QR Code PDFs")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isGenerating)
                .padding(.horizontal)
                
                if isGenerating {
                    ProgressView("Generating PDFs...")
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Display the PDFs if available
                if let displayURL = displayPDFURL {
                    VStack(alignment: .leading) {
                        Text("Display PDF (with QR code):")
                            .font(.headline)
                        
                        PDFKitRepresentedView(url: displayURL)
                            .frame(height: 200)
                            .border(Color.gray)
                    }
                    .padding()
                }
                
                if let scanURL = scanPDFURL {
                    VStack(alignment: .leading) {
                        Text("Scan PDF (without QR code):")
                            .font(.headline)
                        
                        PDFKitRepresentedView(url: scanURL)
                            .frame(height: 200)
                            .border(Color.gray)
                    }
                    .padding()
                }
                
                // Clean up button
                Button {
                    QRCodeService.shared.cleanupTempQRCodeFiles()
                    displayPDFURL = nil
                    scanPDFURL = nil
                    errorMessage = nil
                } label: {
                    Text("Clean Up Test Files")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Text("Testing Notes: Generate both PDFs, check that the QR code appears in the display version, and try scanning the QR code with your phone camera to open the scan version.")
                    .font(.caption)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
    }
    
    private func generatePDFs() {
        isGenerating = true
        errorMessage = nil
        
        // Run PDF generation in background
        DispatchQueue.global().async {
            let result = PDFService.shared.generateBusinessCardWithQRCode(for: testPerson)
            
            // Update UI on main thread
            DispatchQueue.main.async {
                isGenerating = false
                
                if let (display, scan) = result {
                    displayPDFURL = display
                    scanPDFURL = scan
                } else {
                    errorMessage = "Failed to generate PDFs"
                }
            }
        }
    }
}

// Helper to display PDFs
struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.displayMode = .singlePage
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            uiView.document = document
        }
    }
}

struct QRCodePDFTestView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodePDFTestView()
    }
}
