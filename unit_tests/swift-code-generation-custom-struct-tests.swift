//
//  swift-code-generation-custom-struct-tests.swift
//  json2swift
//
//  Created by Joshua Smith on 10/21/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

import XCTest

class swift_code_generation_custom_struct_tests: XCTestCase {
    func test_custom_struct() {
        let customStruct = createStruct(named: "SomeStruct")
        let transformation = TransformationFromJSON.toCustomStruct(attributeName: "a", propertyName: "p", type: customStruct)
        XCTAssertEqual(transformation.optionalUnboxStatement, "self.p = unboxer.unbox(key: \"a\")")
    }
    
    func test_array_of_required_struct() {
        let someStruct = createStruct(named: "SomeStruct")
        let transformation = TransformationFromJSON.toCustomStructArray(attributeName: "a", propertyName: "p", elementType: someStruct, hasOptionalElements: false)
        XCTAssertEqual(transformation.requiredUnboxStatement, "self.p = try unboxer.unbox(key: \"a\")")
    }
    
    func test_array_of_optional_struct() {
        let someStruct = createStruct(named: "SomeStruct")
        let transformation = TransformationFromJSON.toCustomStructArray(attributeName: "a", propertyName: "p", elementType: someStruct, hasOptionalElements: true)
        XCTAssertEqual(transformation.optionalUnboxStatement, "self.p = unboxer.unbox(key: \"a\")")
    }
    
    private func createStruct(named name: String) -> SwiftStruct {
        let initializer = SwiftInitializer(parameters: [])
        let failableInitializer = SwiftFailableInitializer(requiredTransformations: [], optionalTransformations: [])
        return SwiftStruct(name: name,
                           properties: [],
                           initializer: initializer,
                           failableInitializer: failableInitializer,
                           nestedStructs: [])
    }
}
