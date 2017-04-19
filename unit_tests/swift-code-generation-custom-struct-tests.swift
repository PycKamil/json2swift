//
//  swift-code-generation-custom-struct-tests.swift
//  json2swift
//
//  Created by Joshua Smith on 10/21/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

import XCTest

class swift_code_generation_custom_struct_tests: XCTestCase {
    func createTestSwiftStruct() -> SwiftStruct? {
        if let jsonFilePath = Bundle(identifier: "unit_tests")!.path(forResource: "Response", ofType: "json") {
            let url = URL(fileURLWithPath: jsonFilePath)
            let data: Data
            do    { data = try Data(contentsOf: url) }
            catch { return nil }

            let jsonObject: Any
            do    { jsonObject = try JSONSerialization.jsonObject(with: data, options: []) }
            catch { return nil }

            let jsonSchema: JSONElementSchema
            let rootNameFromPath = url.deletingPathExtension().lastPathComponent

            if      let jsonElement = jsonObject as? JSONElement   { jsonSchema = JSONElementSchema.inferred(from: jsonElement, named: rootNameFromPath ) }
            else if let jsonArray   = jsonObject as? [JSONElement] { jsonSchema = JSONElementSchema.inferred(from: jsonArray, named: rootNameFromPath ) }
            else                                                   { return nil }

            return SwiftStruct.create(from: jsonSchema)
        }
        return nil
    }

    func testOptionalUnboxStatement() {
        let transformation = TransformationFromJSON(attributeName: "a", propertyName: "p")
        XCTAssertEqual(transformation.optionalUnboxStatement, "self.p = unboxer.unbox(key: \"a\")")
    }
    
    func testRequiredUnboxStatement() {
        let transformation = TransformationFromJSON(attributeName: "a", propertyName: "p")
        XCTAssertEqual(transformation.requiredUnboxStatement, "self.p = try unboxer.unbox(key: \"a\")")
    }

    func testSerializable() {
        guard let swiftStruct = createTestSwiftStruct(),
            let serializable = swiftStruct.nestedStructs.first?.serializable.toLinesOfCode(at: Indentation(chars: "")) else { XCTFail(); return }

        XCTAssertEqual(serializable[0], "func serialize() -> Any {")
        XCTAssertEqual(serializable[1], "var serializationDictionary: [AnyHashable: Any] = [:]")
        XCTAssertEqual(serializable[2], "serializationDictionary[\"dataSources\"] = dataSources.serialize()")
        XCTAssertEqual(serializable[3], "if let emptyDictionary = emptyDictionary { serializationDictionary[\"emptyDictionary\"] = emptyDictionary.serialize() }")
        XCTAssertEqual(serializable[4], "if let fullUrl = fullUrl { serializationDictionary[\"fullUrl\"] = fullUrl.serialize() }")
        XCTAssertEqual(serializable[5], "if let primitiveType = primitiveType { serializationDictionary[\"primitiveType\"] = primitiveType.serialize() }")
        XCTAssertEqual(serializable[6], "serializationDictionary[\"boxes\"] = slot.serialize()")
        XCTAssertEqual(serializable[7], "return serializationDictionary")
        XCTAssertEqual(serializable[8], "}")
    }
}
