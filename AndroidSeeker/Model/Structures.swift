//
//  Structures.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import Foundation

class File: NSObject, Identifiable, Codable {
    var id: String
    var fileName : String
    var parentFile : String
    var subFiles : [File]
    
    override var description: String {
        return "File(id: \(id), fileName: \(fileName), parentFile: \(parentFile), subfiles: \(subFiles))"
    }
    
    init(id: String, fileName: String, parentFile: String, subFiles: [File]) {
        self.id = id
        self.fileName = fileName
        self.parentFile = parentFile
        self.subFiles = subFiles
    }
}

class Device: NSObject, Identifiable, Codable{
    var id: String
    var name: String
    var status: String
    var files : [File]
    
    override var description: String {
        return "Device(id: \(id), name: \(name), status: \(status), files: \(files))"
    }
    
    init(id: String, name: String, status: String, files: [File]) {
        self.id = id
        self.name = name
        self.status = status
        self.files = files
    }
}

var subFilesMock: [File] = [
    File(id: "3220", fileName: "subFile1", parentFile: "file1", subFiles: []),
    File(id: "3221", fileName: "subFile2", parentFile: "file2", subFiles: []),
    File(id: "3222", fileName: "subFile3", parentFile: "file3", subFiles: []),
    File(id: "3223", fileName: "subFile4", parentFile: "file4", subFiles: []),
    
    File(id: "3224", fileName: "subFile5", parentFile: "file5", subFiles: []),
    File(id: "3225", fileName: "subFile6", parentFile: "file6", subFiles: []),
    File(id: "3226", fileName: "subFile7", parentFile: "file7", subFiles: []),
    File(id: "3227", fileName: "subFile8", parentFile: "file8", subFiles: []),
    
    File(id: "3228", fileName: "subFile9", parentFile: "file9", subFiles: []),
    File(id: "3229", fileName: "subFile10", parentFile: "file10", subFiles: []),
    File(id: "3230", fileName: "subFile11", parentFile: "file11", subFiles: []),
    File(id: "3231", fileName: "subFile12", parentFile: "file12", subFiles: []),
]

var filesMock: [File] = [
    File(id: "3232", fileName: "file1", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3233", fileName: "file2", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3234", fileName: "file3", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3235", fileName: "file4", parentFile: "/root", subFiles: subFilesMock),
    
    File(id: "3236", fileName: "file5", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3237", fileName: "file6", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3238", fileName: "file7", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3239", fileName: "file8", parentFile: "/root", subFiles: subFilesMock),
    
    File(id: "3240", fileName: "file9", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3241", fileName: "file10", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3242", fileName: "file11", parentFile: "/root", subFiles: subFilesMock),
    File(id: "3243", fileName: "file12", parentFile: "/root", subFiles: subFilesMock),
]


var deviceMock : [Device] = [
    Device(id: "673241", name: "ÄDDCCBB$", status: "device", files: filesMock ),
    Device(id: "3219", name: "465F4478", status: "offline", files: filesMock),
    Device(id: "132987", name: "34DFZZ78", status: "unauthorized", files: filesMock),
    Device(id: "27318", name: "89GFZZ78", status: "unauthorized", files: filesMock),
    Device(id: "72381", name: "IGORFZZ78", status: "device", files: filesMock)
]

