//
//  command-line-interface.swift
//  json2swift
//
//  Created by Joshua Smith on 10/28/16.
//  Copyright © 2016 iJoshSmith. All rights reserved.
//

import Foundation

typealias ErrorMessage = String

func run(with arguments: [String]) -> ErrorMessage? {
    guard arguments.isEmpty == false else { return "Please provide a JSON file path or directory path." }
    
    let path = (arguments[0] as NSString).resolvingSymlinksInPath
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else { return "No such file or directory exists." }
    
    let jsonFilePaths: [String]
    if isDirectory.boolValue {
        guard let filePaths = findJSONFilePaths(in: path) else { return "Unable to read contents of directory." }
        guard filePaths.isEmpty == false else { return "The directory does not contain any JSON files." }
        jsonFilePaths = filePaths
    }
    else {
        jsonFilePaths = [path]
    }

    let destinationPath: String
    if arguments.count > 1 {
        destinationPath = (arguments[1] as NSString).resolvingSymlinksInPath
    } else {
        if isDirectory.boolValue {
            destinationPath = path
        } else {
            destinationPath = (path as NSString).deletingLastPathComponent
        }
    }

    for jsonFilePath in jsonFilePaths {
        if let errorMessage = generateSwiftFileBasedOnJSON(inFile: jsonFilePath, destinationPath: destinationPath) {
            return errorMessage
        }
    }
        
    return nil
}


// MARK: - Finding JSON files in directory
private func findJSONFilePaths(in directory: String) -> [String]? {
    guard let jsonFileNames = findJSONFileNames(in: directory) else { return nil }
    return resolveAbsolutePaths(for: jsonFileNames, inDirectory: directory)
}

private func findJSONFileNames(in directory: String) -> [String]? {
    let isJSONFile: (String) -> Bool = { $0.lowercased().hasSuffix(".json") }
    do    { return try FileManager.default.contentsOfDirectory(atPath: directory).filter(isJSONFile) }
    catch { return nil }
}

private func resolveAbsolutePaths(for jsonFileNames: [String], inDirectory directory: String) -> [String] {
    return jsonFileNames.map { (directory as NSString).appendingPathComponent($0) }
}


// MARK: - Generating Swift file based on JSON
private func generateSwiftFileBasedOnJSON(inFile jsonFilePath: String, destinationPath: String) -> ErrorMessage? {
    let url = URL(fileURLWithPath: jsonFilePath)
    let data: Data
    do    { data = try Data(contentsOf: url) }
    catch { return "Unable to read file: \(jsonFilePath)" }
    
    let jsonObject: Any
    do    { jsonObject = try JSONSerialization.jsonObject(with: data, options: []) }
    catch { return "File does not contain valid JSON: \(jsonFilePath)" }
    
    let jsonSchema: JSONElementSchema
    let rootNameFromPath = url.deletingPathExtension().lastPathComponent

    if      let jsonElement = jsonObject as? JSONElement   { jsonSchema = JSONElementSchema.inferred(from: jsonElement, named: rootNameFromPath ) }
    else if let jsonArray   = jsonObject as? [JSONElement] { jsonSchema = JSONElementSchema.inferred(from: jsonArray, named: rootNameFromPath ) }
    else                                                   { return "Unsupported JSON format: must be a dictionary or array of dictionaries." }

    let swiftStruct = SwiftStruct.create(from: jsonSchema)
    writeGeneratedCode(swiftStruct: swiftStruct, destinationPath: destinationPath)

    return nil
}

func writeGeneratedCode(swiftStruct: SwiftStruct, destinationPath: String) {
    let stringForStruct = SwiftCodeGenerator.generateCode(for: swiftStruct)
    let swiftFilePath = destinationPath + "/" + swiftStruct.name + ".swift"
    guard write(swiftCode: stringForStruct, toFile: swiftFilePath) else { print ("Unable to write to file: \(swiftFilePath)"); return }
    print(" Struct file created: " + swiftFilePath)
    swiftStruct.nestedStructs.forEach { nestedStruct in
        writeGeneratedCode(swiftStruct: nestedStruct, destinationPath: destinationPath)
    }
}

private func write(swiftCode: String, toFile filePath: String) -> Bool {
    do {
        try swiftCode.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
        return true
    }
    catch {
        return false
    }
}
