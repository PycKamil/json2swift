//
//  swift-data-model.swift
//  json2swift
//
//  Created by Joshua Smith on 10/14/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

import Foundation

struct SwiftStruct {
    let name: String
    let properties: [SwiftProperty]
    let initializer: SwiftInitializer
    let failableInitializer: SwiftFailableInitializer
    let nestedStructs: [SwiftStruct]
}

struct SwiftProperty {
    let name: String
    let type: SwiftType
}

struct SwiftType {
    let name: String
    let isOptional: Bool
}

struct SwiftInitializer {
    let parameters: [SwiftParameter]
}

struct SwiftParameter {
    let name: String
    let type: SwiftType
}

struct SwiftFailableInitializer {
    let requiredTransformations: [TransformationFromJSON]
    let optionalTransformations: [TransformationFromJSON]
}

struct TransformationFromJSON {
    let attributeName: String
    let propertyName: String
}

enum SwiftPrimitiveValueType {
    case int
    case double
    case date(format: String)
    case url
    case string
    case bool
    case any
    case emptyArray
}
