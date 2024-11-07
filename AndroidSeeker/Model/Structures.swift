//
//  Structures.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import Foundation

//class File: NSObject, Identifiable, Codable {
//    var id: String
//    var fileName : String
//    var parentFile : String
//    var subFiles : [File]
//    
//    override var description: String {
//        return "File(id: \(id), fileName: \(fileName), parentFile: \(parentFile), subfiles: \(subFiles))"
//    }
//    
//    init(id: String, fileName: String, parentFile: String, subFiles: [File]) {
//        self.id = id
//        self.fileName = fileName
//        self.parentFile = parentFile
//        self.subFiles = subFiles
//    }
//}
//
//class Device: NSObject, Identifiable, Codable{
//    var id: String
//    var name: String
//    var status: String
//    var files : [File]
//    
//    override var description: String {
//        return "Device(id: \(id), name: \(name), status: \(status), files: \(files))"
//    }
//    
//    init(id: String, name: String, status: String, files: [File]) {
//        self.id = id
//        self.name = name
//        self.status = status
//        self.files = files
//    }
//}

var subFilesMock: [File] = [
    File(fileName: "subFile1", parentFile: "file1", subFiles: []),
    File(fileName: "subFile2", parentFile: "file2", subFiles: []),
    File(fileName: "subFile3", parentFile: "file3", subFiles: []),
    File(fileName: "subFile4", parentFile: "file4", subFiles: []),
    
    File(fileName: "subFile5", parentFile: "file5", subFiles: []),
    File(fileName: "subFile6", parentFile: "file6", subFiles: []),
    File(fileName: "subFile7", parentFile: "file7", subFiles: []),
    File(fileName: "subFile8", parentFile: "file8", subFiles: []),
    
    File(fileName: "subFile9", parentFile: "file9", subFiles: []),
    File(fileName: "subFile10", parentFile: "file10", subFiles: []),
    File(fileName: "subFile11", parentFile: "file11", subFiles: []),
    File(fileName: "subFile12", parentFile: "file12", subFiles: []),
]

var filesMock: [File] = [
    File(fileName: "file1", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file2", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file3", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file4", parentFile: "/root", subFiles: subFilesMock),
    
    File(fileName: "file5", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file6", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file7", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file8", parentFile: "/root", subFiles: subFilesMock),
    
    File(fileName: "file9", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file10", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file11", parentFile: "/root", subFiles: subFilesMock),
    File(fileName: "file12", parentFile: "/root", subFiles: subFilesMock),
]


var deviceMock : [Device] = [
    Device(name: "ÄDDCCBB$", status: "device", files: filesMock ),
    Device(name: "465F4478", status: "offline", files: filesMock),
    Device(name: "34DFZZ78", status: "unauthorized", files: filesMock),
    Device(name: "89GFZZ78", status: "unauthorized", files: filesMock),
    Device(name: "IGORFZZ78", status: "device", files: filesMock)
]

