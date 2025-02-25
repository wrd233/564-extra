//
//  DataConversion.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import SwiftData
import Foundation

// 将单个 DTO 转换为 DukePerson 实例
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

// 将 DTO 数组转换为 DukePerson 实例，并通过 ModelContext 插入
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
