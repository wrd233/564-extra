import Foundation
import SwiftData

@MainActor
class PersonViewModel: ObservableObject {
    // PDF generation states
    enum PDFGenerationState: Equatable {
        case idle
        case generating
        case success(URL)           // 现有的PDF URL
        case successWithImage(pdfURL: URL, imageURL: URL)  // 新增：同时成功生成PDF和图片
        case failure(String)
        
        // 我们需要修改Equatable实现来支持新的case
        static func == (lhs: PDFGenerationState, rhs: PDFGenerationState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.generating, .generating):
                return true
            case (.success(let lhsURL), .success(let rhsURL)):
                return lhsURL == rhsURL
            case (.successWithImage(let lhsPDF, let lhsImage), .successWithImage(let rhsPDF, let rhsImage)):
                return lhsPDF == rhsPDF && lhsImage == rhsImage
            case (.failure(let lhsError), .failure(let rhsError)):
                return lhsError == rhsError
            default:
                return false
            }
        }
    }
    
    enum CardGenerationState {
        case idle
        case generating
        case success(pdfURL: URL, imageURL: URL)
        case failure(String)
    }
    
    
    @Published var cardState: CardGenerationState = .idle
    @Published var pdfState: PDFGenerationState = .idle
    
    @Published var dukePerson: DukePerson
    
    // Download-related status
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Edit-related status
    @Published var isEditing = false
    @Published var draftPerson: DukePerson
    
    private let network = NetworkService.shared
    
    // Allow passing data from outside
    init(person: DukePerson) {
        self.dukePerson = person
        self.draftPerson = person
    }
    
    func download() async {
        isLoading = true
        
        do {
            let dto = try await network.downloadPersonDTO()
            
            // Create a new person instance from DTO
            let person = convertDTO2DukePerson(dto: dto)
            
            self.dukePerson = person
            // Save a copy
            self.draftPerson = person
            self.errorMessage = nil
        } catch {
            errorMessage = "Failed: \(error.localizedDescription)"
            print(errorMessage ?? "Unknown error")
        }
        
        isLoading = false
    }
    
    func upload() async {
        do {
            let success = await NetworkService.shared.upload(person: draftPerson)
            print("Upload result: \(success ? "success" : "failure")")
        }
    }
    
    func startEditing() {
        // Create a copy of the current person for editing
        draftPerson = dukePerson
        isEditing = true
    }
    
    func cancelEditing() {
        // Discard changes
        draftPerson = dukePerson
        isEditing = false
    }
    
    func saveChanges(context: ModelContext) {
        // Update the model
        updatePersonProperties(dukePerson, from: draftPerson)
        isEditing = false
        
        // Save changes to SwiftData
        do {
            try context.save()
            print("Successfully saved changes to person")
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
    
    // Helper to update properties without changing the instance
    private func updatePersonProperties(_ target: DukePerson, from source: DukePerson) {
        // We don't update DUID as it's the identifier
        target.netID = source.netID
        target.fName = source.fName
        target.lName = source.lName
        target.from = source.from
        target.hobby = source.hobby
        target.languages = source.languages
        target.moviegenre = source.moviegenre
        target.gender = source.gender
        target.role = source.role
        target.program = source.program
        target.plan = source.plan
        target.team = source.team
        target.picture = source.picture
    }
    
    // 在 PersonViewModel.swift 中
    func generateAndUploadCard(modelContext: ModelContext?) async {
        print("开始生成和上传名片")
        
        await MainActor.run {
            pdfState = .generating
            print("状态已更新为: generating")
        }
        
        do {
            // 生成PDF
            print("尝试生成PDF...")
            guard let pdfURL = PDFService.shared.generateBusinessCard(for: dukePerson) else {
                print("PDF生成失败，返回nil")
                throw NSError(domain: "PDFGeneration", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to generate PDF"])
            }
            print("PDF生成成功，URL: \(pdfURL)")
            
            // 转换为图片
            print("尝试转换PDF为图片...")
            guard let cardImage = PDFService.shared.convertPDFToImage(pdfURL: pdfURL) else {
                print("PDF转图片失败")
                throw NSError(domain: "PDFConversion", code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to convert PDF to image"])
            }
            print("PDF转图片成功")
            
            // 准备上传
            print("准备图片数据用于上传...")
            guard let imageData = cardImage.jpegData(compressionQuality: 0.9) else {
                print("创建图片数据失败")
                throw NSError(domain: "ImagePreparation", code: 3,
                              userInfo: [NSLocalizedDescriptionKey: "Failed to prepare image data"])
            }
            
            // 上传图片
            print("开始上传图片到服务器...")
            let filename = "card_\(dukePerson.netID)_\(Int(Date().timeIntervalSince1970)).jpg"
            
            do {
                let serverURL = try await NetworkService.shared.uploadCardImage(imageData: imageData, filename: filename)
                print("图片上传成功，服务器URL: \(serverURL)")
                
                // 保存URL到模型
                dukePerson.cardImageURL = serverURL.absoluteString
                print("URL已保存到模型: \(serverURL.absoluteString)")
                
                // 保存到数据库
                if let context = modelContext {
                    try context.save()
                    print("模型已保存到数据库")
                } else {
                    print("警告: modelContext为nil，数据未保存到数据库")
                }
                
                // 更新UI
                await MainActor.run {
                    print("更新UI状态为success")
                    pdfState = .successWithImage(pdfURL: pdfURL, imageURL: serverURL)
                }
            } catch {
                print("上传过程中发生错误: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("详细错误信息: \(nsError.domain), 代码: \(nsError.code)")
                    print("用户信息: \(nsError.userInfo)")
                }
                
                throw error
            }
        } catch {
            print("捕获到最终错误: \(error)")
            await MainActor.run {
                pdfState = .failure(error.localizedDescription)
                print("状态已更新为failure: \(error.localizedDescription)")
            }
        }
    }
}
