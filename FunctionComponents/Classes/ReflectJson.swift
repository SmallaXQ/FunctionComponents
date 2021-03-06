//
//  ReflectJson.swift
//  HPC
//
//  Created by Smalla on 2019/12/27.
//  Copyright © 2019 huili. All rights reserved.
//

import Foundation

public protocol ReflectJson {
    func toJSONModel() -> Any?
    func toJSONString() -> String?
}

extension ReflectJson {
    func getMirrorKeyValues(_ mirror: Mirror?) -> [String: Any] { // iOS8+
        var keyValues = [String: Any]()
        guard let mirror = mirror else { return keyValues }
        for case let (label?, value) in mirror.children {
            keyValues[label] = value
        }
        if mirror.superclassMirror?.subjectType != NSObject.self {
            getMirrorKeyValues(mirror.superclassMirror).forEach({ (key, value) in
                keyValues[key] = value
            })
        }
        return keyValues
    }
    
    //将数据转成可用的JSON模型
    public func toJSONModel() -> Any? {
        let replacePropertys = (self as? TTReflectProtocol)?.setupMappingReplaceProperty?() ?? [:]
        
        let mirror = Mirror(reflecting: self)
        let keyValues = getMirrorKeyValues(mirror)
        if mirror.children.count > 0 {
            var result: [String: AnyObject] = [:]
            for (label, value) in keyValues {
                let sourceLabel = replacePropertys.keys.contains(label) ? replacePropertys[label]! : label
                debugPrint("source label: ", sourceLabel)
                if let jsonValue = value as? ReflectJson {
                    if let hasResult = jsonValue.toJSONModel() {
                        result[sourceLabel] = hasResult as AnyObject
                    } else {
                        let valueMirror = Mirror(reflecting: value)
                        if valueMirror.superclassMirror?.subjectType != NSObject.self {
                            result[sourceLabel] = value as AnyObject
                        }
                    }
                }
            }
            return result as AnyObject
        }
        return nil
    }
    
    //将数据转成JSON字符串
    public func toJSONString() -> String? {
        guard let jsonModel = self.toJSONModel() else {
            return ""
        }
        //    debugPrint(jsonModel)
        //利用OC的json库转换成Data，
        let data = try? JSONSerialization.data(withJSONObject: jsonModel,
                                               options: [])
        //Data转换成String打印输出
        let str = String(data: data!, encoding: .utf8)
        return str
    }
}

extension NSObject: ReflectJson { }

extension String: ReflectJson { }
extension Int: ReflectJson { }
extension Double: ReflectJson { }
extension Bool: ReflectJson { }
extension Dictionary: ReflectJson { }
//扩展Array，格式化输出
extension Array: ReflectJson {
    //将数据转成可用的JSON模型
    public func toJSONModel() -> Any? {
        var result: [Any] = []
        for value in self {
            if let jsonValue = value as? ReflectJson , let jsonModel = jsonValue.toJSONModel(){
                result.append(jsonModel)
            }
        }
        return result
    }
}
//扩展Date日期类型，格式化输出
extension Date: ReflectJson {
    public func toJSONModel() -> Any? {
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        // 为日期格式器设置格式字符串
        dformatter.dateFormat = "yyyy-MM-dd"
        // 使用日期格式器格式化日期、时间
        let datestr = dformatter.string(from: self)
        return datestr
    }
}
