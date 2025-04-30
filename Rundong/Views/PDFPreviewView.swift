import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    // The URL of the PDF to display
    let pdfURL: URL
    
    // Callback for when the view is dismissed
    var onDismiss: () -> Void
    
    // State for error display
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // PDF view wrapper
                PDFKitView(url: pdfURL)
                    .edgesIgnoringSafeArea(.bottom)
            }
            .navigationTitle("Business Card Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Close button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onDismiss()
                    }
                }
                
                // Share button
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: pdfURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

// UIViewRepresentable wrapper for PDFView
struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        // Create PDF view
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        
        // Return the empty view
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Create and load the PDF document
        if let document = PDFDocument(url: url) {
            uiView.document = document
        }
    }
}
