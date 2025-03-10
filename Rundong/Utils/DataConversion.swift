//
//  DataConversion.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import SwiftData
import Foundation

// Convert a single DTO into a DukePerson instance
func convertDTO2DukePerson(dto: DukePersonDTO) -> DukePerson {
    let gender = Gender(rawValue: dto.gender) ?? .Unknown
    let role = Role(rawValue: dto.role) ?? .Unknown
    let program = Program(rawValue: dto.program) ?? .NotApplicable
    let plan = Plan(rawValue: dto.plan) ?? .NotApplicable
    
    return DukePerson(
        DUID: dto.DUID,
        netID: dto.netID,
        fName: dto.fName,
        lName: dto.lName,
        from: dto.from,
        hobby: dto.hobby,
        languages: dto.languages,
        moviegenre: dto.moviegenre,
        gender: gender,
        role: role,
        program: program,
        plan: plan,
        team: dto.team,
        picture: dto.picture
    )
}

// Convert an array of DTOs into DukePerson instances and insert them via ModelContext
func convertDTOsToDukePersons(dtoArray: [DukePersonDTO], context: ModelContext) {
    for dto in dtoArray {
        let person = convertDTO2DukePerson(dto: dto)
        context.insert(person)
    }
    
    do {
        try context.save()
        print("转换并保存 \(dtoArray.count) 条记录成功")
    } catch {
        print("保存转换后的记录时出错: \(error)")
    }
}

func convertDukePersonToDTO(person: DukePerson) -> DukePersonDTO {
    return DukePersonDTO(
        DUID: person.DUID,
        netID: person.netID,
        fName: person.fName,
        lName: person.lName,
        from: person.from,
        hobby: person.hobby,
        languages: person.languages,
        moviegenre: person.moviegenre,
        gender: person.gender.rawValue,
        role: person.role.rawValue,
        program: person.program.rawValue,
        plan: person.plan.rawValue,
        team: person.team,
        picture: person.picture
    )
}
