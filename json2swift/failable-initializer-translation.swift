//
//  failable-initializer-translation.swift
//  json2swift
//
//  Created by Joshua Smith on 10/28/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

// MARK: - JSONElementSchema --> SwiftFailableInitializer
internal extension SwiftFailableInitializer {
    static func create(forStructBasedOn jsonElementSchema: JSONElementSchema) -> SwiftFailableInitializer {
        let attributeMap = jsonElementSchema.attributes
        let allAttributeNames = Set(attributeMap.keys)
        let requiredAttributeNames = allAttributeNames.filter { attributeMap[$0]!.isRequired }
        let optionalAttributeNames = allAttributeNames.subtracting(requiredAttributeNames)
        let requiredTransformations: [TransformationFromJSON] = requiredAttributeNames.map {
            TransformationFromJSON.create(forAttributeNamed: $0, inAttributeMap: attributeMap)
        }
        let optionalTransformations: [TransformationFromJSON] = optionalAttributeNames.map {
            TransformationFromJSON.create(forAttributeNamed: $0, inAttributeMap: attributeMap)
        }
        return SwiftFailableInitializer(requiredTransformations: requiredTransformations,
                                        optionalTransformations: optionalTransformations)
    }
}

// MARK: - JSON attribute --> TransformationFromJSON
fileprivate extension TransformationFromJSON {
    static func create(forAttributeNamed attributeName: String, inAttributeMap attributeMap: JSONAttributeMap) -> TransformationFromJSON {
        let propertyName = attributeName.toSwiftPropertyName()
        return TransformationFromJSON(attributeName: attributeName,
                                      propertyName: propertyName)
    }
}
