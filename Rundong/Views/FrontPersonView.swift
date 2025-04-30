import SwiftUI
import AVFoundation
import PDFKit

struct FrontPersonView: View {
    @ObservedObject var vm: PersonViewModel
    @State private var haloScale: CGFloat = 1.0
    @State private var haloOpacity: Double = 0.6
    @State private var locationTextColor: Color = .blue
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isLoadingAudio: Bool = false
    @State private var audioError: String? = nil
    
    @State private var showingPDFPreview = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .blur(radius: 15)
                    .frame(width: 240, height: 240)
                    .scaleEffect(haloScale)
                    .opacity(haloOpacity)
                
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .blur(radius: 8)
                    .frame(width: 200, height: 200)
                
                ProfileImage(base64String: vm.dukePerson.picture)
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    haloScale = 1.2
                    haloOpacity = 0.9
                }
                
                generateAndPlaySpeech()
            }
            
            Text("\(vm.dukePerson.fName) \(vm.dukePerson.lName)")
                .font(.custom("Noteworthy-Bold", size: 28))
                .foregroundColor(.primary)
                .shadow(color: .gray.opacity(0.3), radius: 1, x: 1, y: 1)
            
            Text(vm.dukePerson.hobby)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("From: ")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(vm.dukePerson.from)
                    .font(.caption.bold())
                    .foregroundColor(locationTextColor)
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever()) {
                    locationTextColor = .orange
                }
            }
            
            TextInfoBlock(content: vm.dukePerson.description)
            
            if isLoadingAudio {
                ProgressView("Generating audio...")
                    .padding()
            } else if let error = audioError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack {
                Button("Download") {
                    Task { await vm.download() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)
                
                Button {
                    vm.generatePDF()
                } label: {
                    HStack {
                        Image(systemName: "doc.text.viewfinder")
                        Text("Generate Card")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)
            }
            .padding()
        }
        .padding()
        .overlay {
            // Show loading indicator when generating PDF
            if case .generating = vm.pdfState {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .overlay {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Generating business card...")
                                .padding(.top)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        .cornerRadius(10)
                    }
            }
        }
        .onChange(of: vm.pdfState) { oldState, newState in
            if case .success(let url) = newState {
                showingPDFPreview = true
            } else if case .failure(let error) = newState {
                // Handle error (could add an alert here)
                print("PDF generation failed: \(error)")
            }
        }
        .sheet(isPresented: $showingPDFPreview) {
            // Reset PDF state when preview is dismissed
            vm.resetPDFState()
        } content: {
            if case .success(let url) = vm.pdfState {
                PDFPreviewView(pdfURL: url) {
                    showingPDFPreview = false
                }
            } else {
                Text("Error loading PDF")
                    .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    
    private func generateAndPlaySpeech() {
        isLoadingAudio = true
        audioError = nil
        
        guard let url = URL(string: "https://flask564.zeabur.app/generate-speech") else {
            audioError = "Invalid backend URL"
            isLoadingAudio = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: String] = ["text": vm.dukePerson.description]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            audioError = "Error preparing request"
            isLoadingAudio = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoadingAudio = false
                
                if let error = error {
                    audioError = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    audioError = "Invalid response"
                    return
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    audioError = "Server error: \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    audioError = "No data received"
                    return
                }
            
                do {
                    audioPlayer = try AVAudioPlayer(data: data)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch {
                    audioError = "Error playing audio"
                    print("Audio playback error: \(error)")
                }
            }
        }.resume()
    }
}

// TextInfoBlock component
struct TextInfoBlock: View {
    let content: String
    @State private var displayedText: String = ""
    @State private var showCursor: Bool = true
    
    @State private var currentIndex: Int = 0
    let typingSpeed: Double = 0.05
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            terminalTextView
        }
        .padding(.horizontal, 16)
        .onAppear {
            startTypingAnimation()
            startCursorBlinking()
        }
    }
    
    private var terminalTextView: some View {
        HStack(alignment: .top) {
            textContent
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(terminalBackground)
    }
    
    private var textContent: some View {
        HStack(spacing: 0) {
            Text(displayedText)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.green)
            
            cursorView
        }
    }
    
    private var cursorView: some View {
        Text("|")
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.green)
            .opacity(showCursor ? 1 : 0)
    }
    
    private var terminalBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.black.opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.green.opacity(0.5), lineWidth: 2)
            )
    }
    
    private func startTypingAnimation() {
        displayedText = ""
        currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { timer in
            if currentIndex < content.count {
                let index = content.index(content.startIndex, offsetBy: currentIndex)
                displayedText += String(content[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func startCursorBlinking() {
        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever()) {
            self.showCursor.toggle()
        }
    }
}



#Preview {
    let samplePerson = DukePerson(
        DUID: 123456,
        netID: "hack42",
        fName: "Ada",
        lName: "Lovelace",
        from: "London",
        hobby: "Programming",
        languages: ["Swift", "Python", "Assembly"],
        moviegenre: "Sci-Fi",
        gender: .Female,
        role: .Student,
        program: .MENG,
        plan: .CS,
        team: "Coding Ninjas",
        picture: ""
    )
    
    let viewModel = PersonViewModel(person: samplePerson)
    
    return FrontPersonView(vm: viewModel)
        .preferredColorScheme(.dark) 
        .padding()
        .previewLayout(.sizeThatFits)
}
