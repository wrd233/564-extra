//
//  DukePerson.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import SwiftData

enum Gender : String {
    case Unknown = "Unknown"
    case Male = "Male"
    case Female = "Female"
    case Other = "Other"
}
extension Gender : Codable, CaseIterable {}

let allGenders = Gender.allCases.map { $0.rawValue }

enum Role : String, Codable {
    case Unknown = "Unknown"
    case Professor = "Professor"
    case TA = "TA"
    case Student = "Student"
    case Other = "Other"
}
extension Role : CaseIterable {}

let allRoles = Role.allCases.map { $0.rawValue }

enum Program : String, Codable {
    case NotApplicable = "NA"
    case MENG = "MENG"
    case BA = "BA"
    case BS = "BS"
    case MS = "MS"
    case PHD = "PhD"
    case Other = "Other"
}
extension Program: CaseIterable {}

let allPrograms = Program.allCases.map { $0.rawValue }

enum Plan: String, Codable {
    case NotApplicable = "NA"
    case CS = "Computer Science"
    case ECE = "ECE"
    case FinTech = "FinTech"
    case Other = "Other"
}

extension Plan: CaseIterable {}

let allPlans = Plan.allCases.map { $0.rawValue }

@Model
class DukePerson: CustomStringConvertible {
    private(set) var DUID:Int // to make DUID const
    var netID:String
    var fName:String
    var lName:String
    var from:String
    var hobby:String
    var languages:[String]
    var moviegenre:String
    var gender:Gender
    var role:Role
    var program:Program
    var plan:Plan
    var team:String
    var picture:String
    var cardImageURL: String = ""  // 存储名片图片的在线URL
    var email: String {
        ("\(self.netID)@duke.edu")
    }
    var description: String {
        var description = "\(fName) \(lName) is a \(role.rawValue)."
        
        if !from.isEmpty {
            description += " He is from \(from)"
        }
        
        if !hobby.isEmpty {
            description += " and enjoys \(hobby)."
        } else {
            description += "."
        }
        
        if !moviegenre.isEmpty {
            description += " \(fName) likes to watch \(moviegenre) movies"
        }
        
        if !languages.isEmpty {
            let languageList = languages.joined(separator: ", ")
            description += " and is proficient in \(languageList)."
        } else {
            description += "."
        }
        
        description += " You can reach him at \(email)."
        
        return description
    }
    
    init( DUID: Int,netID: String,fName: String,lName: String,from: String = "",hobby: String = "",languages: [String] = [],moviegenre: String = "",gender: Gender,role: Role,program: Program,plan: Plan,team: String = "",picture: String = "") {
        self.DUID = DUID
        self.netID = netID
        self.fName = fName
        self.lName = lName
        self.from = from
        self.hobby = hobby
        self.languages = languages
        self.moviegenre = moviegenre
        self.gender = gender
        self.role = role
        self.program = program
        self.plan = plan
        self.team = team
        self.picture = picture
    }
}
