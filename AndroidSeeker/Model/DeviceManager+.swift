//
//  DeviceManager+.swift
//  AndroidSeeker
//
//  Created by ifws on 24/10/24.
//

import Foundation


extension DeviceManager {
    
    
    func compareFiles() -> [String: [String] ] {
        
        var dict: [String: [String] ] = [
            "Substituir": [],// arquivos que foram alterados no device e existem no mac
            "Importar": [],// arquivos que apenas existem no device
            "Deletar": [] // arquivos que existem no mac mas nao no device
        ]
       
        
        dict["Substituir"]?.append("lyvia.jpg")
        dict["Substituir"]?.append("igor.jpg")
        
        for (key, value) in dict where key == "Substituir" {
            print( value)
        }
        return dict
    }
}



