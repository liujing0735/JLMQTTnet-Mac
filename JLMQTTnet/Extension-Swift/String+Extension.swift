//
//  String+Extension.swift
//  JLMQTTnet
//
//  Created by JasonLiu on 2018/8/15.
//  Copyright © 2018年 trudian. All rights reserved.
//

extension String {
    var bytes: [UInt8] {
        var array = [UInt8]()
        for char in self.utf8{
            array.append(char)
        }
        return array
    }
    
    var toData: Data! {
        return self.data(using: String.Encoding.utf8)
    }
    
    var toHexData: Data! {
        get {
            var data = Data(capacity: self.count/2)
            let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
                let substring = (self as NSString).substring(with: match!.range)
                var num = UInt8(substring, radix: 16)!
                data.append(&num, count: 1)
            }
            guard data.count > 0 else { return nil }
            return data
        }
    }
}
