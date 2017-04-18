//
//  failable-initializer-translation.swift
//  json2swift
//
//  Created by Joshua Smith on 10/28/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

// MARK: - JSON attribute --> TransformationFromJSON
extension TransformationFromJSON {
    static func create(forAttributeNamed attributeName: String, inAttributeMap attributeMap: JSONAttributeMap) -> TransformationFromJSON {
        let propertyName = attributeName.toSwiftPropertyName()
        var attributeName = attributeName
        if let customKey = attributeMap[attributeName]?.jsonElementSchema?.attributes["custom_key"]?.jsonStringValue {
            attributeName = customKey
        }

        return TransformationFromJSON(attributeName: attributeName,
                                      propertyName: propertyName)
    }
}
