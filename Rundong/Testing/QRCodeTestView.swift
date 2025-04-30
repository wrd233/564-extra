import SwiftUI

struct QRCodeTestView: View {
    // Test URLs for different scenarios
    private let sampleURLs = [
        URL(string: "https://lh3.googleusercontent.com/ogw/AF2bZyhA0IlAt_TpS-7JIfFa02llRvtU3rFuLhKQO0Wi6mzhuQ=s64-c-mo")!,
        URL(string: "https://lh3.googleusercontent.com/ogw/AF2bZyhA0IlAt_TpS-7JIfFa02llRvtU3rFuLhKQO0Wi6mzhuQ=s64-c-mo")!,
        URL(string: "file:///Users/mac/Downloads/test_pic.png")!
    ]
    
    // State for styling options
    @State private var addLogo = true
    @State private var qrSize: CGFloat = 200
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("QR Code Service Test")
                    .font(.largeTitle)
                    .padding()
                
                // Controls for QR code appearance
                VStack(spacing: 10) {
                    Toggle("Add Duke Logo", isOn: $addLogo)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Size: \(Int(qrSize))px")
                        Slider(value: $qrSize, in: 100...300, step: 10)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Basic QR code example
                VStack(spacing: 10) {
                    Text("Basic QR Code")
                        .font(.headline)
                    
                    if let qrImage = QRCodeService.shared.generateQRCode(
                        from: sampleURLs[0],
                        size: CGSize(width: qrSize, height: qrSize)
                    ) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: qrSize, height: qrSize)
                    } else {
                        Text("Failed to generate basic QR code")
                            .foregroundColor(.red)
                    }
                    
                    Text("URL: \(sampleURLs[0].absoluteString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Styled QR code examples
                ForEach(0..<sampleURLs.count, id: \.self) { index in
                    VStack(spacing: 10) {
                        Text("Styled QR Code \(index + 1)")
                            .font(.headline)
                        
                        if let styledQR = QRCodeService.shared.generateStyledQRCode(
                            from: sampleURLs[index],
                            size: CGSize(width: qrSize, height: qrSize),
                            addLogo: addLogo
                        ) {
                            Image(uiImage: styledQR)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: qrSize, height: qrSize)
                        } else {
                            Text("Failed to generate styled QR code")
                                .foregroundColor(.red)
                        }
                        
                        Text("URL: \(sampleURLs[index].absoluteString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                
                // Information about testing
                VStack(alignment: .leading, spacing: 5) {
                    Text("Testing Notes:")
                        .font(.headline)
                    
                    Text("• Use the toggle to test with/without Duke logo")
                    Text("• Adjust slider to test different QR code sizes")
                    Text("• Test scanning each QR code with your phone")
                    Text("• First QR is basic, others are styled")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
    }
}

// Preview provider
struct QRCodeTestView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeTestView()
    }
}
