//
//  Data+Extension.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/15.
//  Copyright © 2018年 trudian. All rights reserved.
//

extension Data {
    var toString: String!{
        return String(data: self, encoding: String.Encoding.utf8)
    }
    
    var toHexString: String! {
        if let string = self.toString {
            var result = ""
            for char in string.utf8{
                result += String(format: "%02x", char)
            }
            return result
        }
        return nil
    }
}
