import SwiftUI
import PDFKit

struct PDFToImageTestView: View {
    // State variables to store the generated content
    @State private var pdfURL: URL?
    @State private var cardImage: UIImage?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    
    // Sample person for testing
    private let samplePerson = DukePerson(
        DUID: 123456,
        netID: "test123",
        fName: "Jane",
        lName: "Doe",
        from: "California",
        hobby: "Photography",
        languages: ["Swift", "Python", "JavaScript"],
        moviegenre: "Sci-Fi",
        gender: .Female,
        role: .Student,
        program: .MENG,
        plan: .CS,
        team: "Mobile Dev",
        picture: "" // No picture for simplicity
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("PDF to Image Test")
                    .font(.largeTitle)
                    .padding(.top)
                
                // Generate button
                Button {
                    generatePDFAndImage()
                } label: {
                    Text("Generate PDF & Convert to Image")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isGenerating)
                .padding(.horizontal)
                
                if isGenerating {
                    ProgressView("Generating...")
                        .padding()
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // PDF Preview
                if let pdfURL = pdfURL {
                    VStack(alignment: .leading) {
                        Text("PDF Preview:")
                            .font(.headline)
                            .padding(.top)
                        
                        PDFKitView(url: pdfURL)
                            .frame(height: 250)
                            .border(Color.gray)
                    }
                    .padding(.horizontal)
                }
                
                // Image Preview
                if let image = cardImage {
                    VStack(alignment: .leading) {
                        Text("Converted Image:")
                            .font(.headline)
                            .padding(.top)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                            .border(Color.gray)
                    }
                    .padding(.horizontal)
                }
                
                // Clean up button
                Button {
                    cleanup()
                } label: {
                    Text("Clean Up")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    // Generate PDF and convert to image
    private func generatePDFAndImage() {
        isGenerating = true
        errorMessage = nil
        
        // Clear previous results
        pdfURL = nil
        cardImage = nil
        
        // Run in background to avoid UI blocking
        DispatchQueue.global().async {
            // Step 1: Generate PDF
            guard let generatedPDFURL = PDFService.shared.generateBusinessCard(for: samplePerson) else {
                DispatchQueue.main.async {
                    isGenerating = false
                    errorMessage = "Failed to generate PDF"
                }
                return
            }
            
            // Step 2: Convert PDF to image
            guard let convertedImage = PDFService.shared.convertPDFToImage(pdfURL: generatedPDFURL) else {
                DispatchQueue.main.async {
                    isGenerating = false
                    errorMessage = "Failed to convert PDF to image"
                }
                return
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                isGenerating = false
                pdfURL = generatedPDFURL
                cardImage = convertedImage
            }
        }
    }
    
    // Clean up temporary files
    private func cleanup() {
        pdfURL = nil
        cardImage = nil
        errorMessage = nil
        PDFService.shared.cleanupTempFiles()
    }
}

// Helper to display PDFs
struct PDFKitView2: UIViewRepresentable {
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

#Preview {
    PDFToImageTestView()
}
