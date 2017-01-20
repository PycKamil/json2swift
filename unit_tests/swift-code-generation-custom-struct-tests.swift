//
//  swift-code-generation-custom-struct-tests.swift
//  json2swift
//
//  Created by Joshua Smith on 10/21/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

import XCTest

class swift_code_generation_custom_struct_tests: XCTestCase {
    func testOptionalUnboxStatement() {
        let transformation = TransformationFromJSON(attributeName: "a", propertyName: "p")
        XCTAssertEqual(transformation.optionalUnboxStatement, "self.p = unboxer.unbox(key: \"a\")")
    }
    
    func testRequiredUnboxStatement() {
        let transformation = TransformationFromJSON(attributeName: "a", propertyName: "p")
        XCTAssertEqual(transformation.requiredUnboxStatement, "self.p = try unboxer.unbox(key: \"a\")")
    }

}
