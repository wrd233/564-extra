//
//  DukePersonDTO.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import Foundation

// 用于网络数据传输
struct DukePersonDTO: Codable {
    let DUID: Int
    let netID: String
    let fName: String
    let lName: String
    let from: String
    let hobby: String
    let languages: [String]
    let moviegenre: String
    let gender: String
    let role: String
    let program: String
    let plan: String
    let team: String
    let picture: String
}
