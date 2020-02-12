import Foundation

//  Json工具类
//  Created by 蒋具宏 on 2020/2/11.
public class JsonUtil {
    /**
     * 将对象转换为JSON字符串(数组/对象)
     */
    public static func toJson(_ object: Any) -> String {
        // 解析数组
        if let array = object as? [Any] {
            var result = "[";
            for item in array{
                result += "\(toJsonByObj(item)),";
            }
            // 删除末尾逗号
            if result.hasSuffix(","){
                result = String(result.dropLast());
            }
            return result + "]";
        }
        
        // 解析单个对象
        return toJsonByObj(object);
    }
    
    /**
     * 将对象转换为JSON字符串(单个对象)
     */
    public static func toJsonByObj(_ object: Any) -> String{
        var result = "{";
        // 反射当前类及父类反射对象
        let morror = Mirror.init(reflecting: object)
        let superMorror = morror.superclassMirror
        // 键值对字典
        var dict : Dictionary<String?, Any> = [:];
        
        // 遍历父类和子类属性集合，添加到键值对字典
        for (name, value) in (superMorror?.children)! {
            dict[name!] = value;
        }
        for (name, value) in morror.children {
            dict[name!] = value;
        }
        
        // 组装json对象
        for (name,value) in dict{
            // 解码值，根据不同类型设置不同封装，nil不进行封装
            if let n = name{
                let v = unwrap(value);
                // 未解码成功的值，则是nil
                if !("\(type(of:v))".hasPrefix("Optional")) {
                    result += kv(n, v);
                    result += ",";
                }
                //            print("\(name!),\(type(of:v))");
            }
        }
        
        // 删除末尾逗号
        if result.hasSuffix(","){
            result = String(result.dropLast());
        }
        
        return result + "}";
    }
    
    /**
     * 解码值，optional 将会被自动解码
     */
    public static func unwrap<T>(_ any: T) -> Any{
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional, let first = mirror.children.first else {
            return any
        }
        return first.value
    }
    
    /**
     * 根据K和V拼装键值对
     */
    public static func kv(_ k : Any, _ v : Any)->String{
        var result = "\"\(k)\":";
        
        // 根据类型赋值不同的值
        if v is String{
            result += "\"\(v)\"";
        }else if v is Int32 || v is Int || v is UInt32 || v is UInt64 || v is Bool || v is Double{
            result += "\(v)";
        }else if v is Date{
            result += "\(Int((v as! Date).timeIntervalSince1970))";
        }else if v is Data{
            result += "\"\(String(data: v as! Data, encoding: String.Encoding.utf8)!.replacingOccurrences(of: "\0",with: ""))\"";
        }else if v is Dictionary<AnyHashable, Any>{
            result += "{";
            // 解析键值对
            for (key,value) in v as! Dictionary<AnyHashable, Any>{
                result += "\(kv(key, value)),";
            }
            // 删除末尾逗号
            if result.hasSuffix(","){
                result = String(result.dropLast());
            }
            result += "}";
        }else if v is NSObject{
            result += toJson(v);
        }else {
            result += "\"\(v)\"";
        }
        
        return result;
    }
}
