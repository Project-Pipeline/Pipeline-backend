//
//  PipelineJSONHelper.swift
//  
//
//  Created by Jing Wei Li on 1/10/21.
//

import Foundation

protocol PipelineJSONHelperType {
    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }
}

class PipelienJSONHelper: PipelineJSONHelperType {
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
