// =====================================================================================================================
//
//  File:       VJson.swift
//  Project:    SwifterJSON
//
//  Version:    0.9.8
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/pages/projects/swifterjson/
//  Blog:       http://swiftrien.blogspot.com
//  Git:        https://github.com/Swiftrien/SwifterJSON
//
//  Copyright:  (c) 2014-2016 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  I strongly believe that the Non Agression Principle is the way for societies to function optimally. I thus reject
//  the implicit use of force to extract payment. Since I cannot negotiate with you about the price of this code, I
//  have choosen to leave it up to you to determine its price. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  whishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to visit the website/blog/google to ensure that you actually pay me and not some imposter)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
//  This JSON implementation was written using the definitions as found on: http://json.org (2015.01.01)
//
// =====================================================================================================================
//
//  As a general rule: use the pipe operators to read from a JSON hierarchy and use the subscript accessors to create
//  the JSON hierarchy. For more information, see the readme file.
//
// =====================================================================================================================
//
// History
//
// v0.9.8 - Preparations for Swift 3 (name changes)
//        - Added functions: stringOrNull, integerOrNull, doubleOrNull, boolOrNull and numberOrNull.
//        - Fixed problem where appendChild would not convert a non-array into an array.
//        - Added "&=" operators
//        - Changed VJsonSerializable and created additional protocols VJsonDeserializable and VJsonConvertible
//        - Added a load of new initializers and factories
//        - Added a conditional conversion of ARRAY into OBJECT
//        - Removed createXXXX functions where these duplicated the new initializers.
//        - Fixed crash when changing from an ARRAY to OBJECT and vice-versa
//        - Created better distiction between ARRAY and OBJECT access, it is no longer possible to insert in or append to objects just as it is no longer possible to add to arrays. There is no longer an automatic conversion of JSON items for child access/management. Instead, two new operations have been added to change object's into array's and vice versa. Note that value assignment en array accessors still auto-convert JSON item types.
//        - Added static option fatalErrorOnTypeConversion (for use during debugging)
//        - Improved iterator: will no longer generates items that are deleted while in the itteration loop
//        - Changed operations "object" to "item"
// v0.9.7 - Added protocol definition VJsonSerializable
//        - Added createJsonHierarchy(string)
// v0.9.6 - Header update
// v0.9.5 - Added "pipe" functions to allow for guard constructs when testing for item existence without side effect
// v0.9.4 - Changed target to a shared framework
//        - Added 'public' declarations to support use as framework
// v0.9.3 - Changed "removeChild:atIndex" to "removeChildAtIndex:withChild"
//        - Added conveniance operation "addChild" that does not need the name of the child to be added.
//        - Changed behaviour of "addChild:name" to change the item into an OBJECT if it is'nt one.
//        - Changed behaviour of "appendChild" to change the item into an ARRAY if it is'nt one.
//        - Upgraded to Swift 2.2
//        - Removed dependency on SwifterLog
//        - Updated for changes in ASCII.swift
// v0.9.2 - Fixed a problem where an assigned NULL object was removed from the hierarchy
// v0.9.1 - Changed parameter to 'addChild' to an optional.
//        - Fixed a problem where an object without a leading brace in an array would not be thrown as an error
//        - Changed 'makeCopy()' to 'copy' for constency with other projects
//        - Fixed the asString for BOOL types
//        - Changed all "...Value" returns to optionals (makes more sense as this allows the use of guard let statements
//        to check the JSON structure.
//        - Overhauled the child support interfaces (changes parameters and return values to optionals)
//        - Removed 'set' access from arrayValue and dictionaryValue as it could potentially lead to an invalid JSON
//        hierarchy
//        - Fixed subscript accessors, array can now be used on top-level with an implicit name of "array"
//        - Fixed missing braces around named objects in an array
// v0.9.0 Initial release
// =====================================================================================================================

import Foundation


/// For classes and structs that can be converted into a VJson object

public protocol VJsonSerializable {
    var json: VJson { get }
}


/// For classes and structs that can be constructed from a VJson object

public protocol VJsonDeserializable {
    init?(json: VJson?)
}


/// For classes and structs that can be converted into and constructed from a VJson object

public protocol VJsonConvertible: VJsonSerializable, VJsonDeserializable {}


/// Interrogate a JSON object for the existence of a child object without side effects

infix operator | { associativity left }


/// Assign an item to a JSON object. Will change the object into the JSON type necessary

infix operator &= {}


/// Interrogate a JSON object for the existence of a child object with the given name. Has no side effects

public func | (lhs: VJson?, rhs: String?) -> VJson? {
    guard let lhs = lhs else { return nil }
    guard let rhs = rhs else { return nil }
    let arr = lhs.children(rhs)
    if arr.count == 0 { return nil }
    return arr[0]
}


/// Interrogate a JSON object for the existence of a child object with the given index. Has no side effects

public func | (lhs: VJson?, rhs: Int?) -> VJson? {
    guard let lhs = lhs else { return nil }
    guard let rhs = rhs else { return nil }
    guard lhs.type == VJson.JType.ARRAY else { return nil }
    guard rhs < lhs.nofChildren else { return nil }
    return lhs.children![rhs]
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Int?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Int8?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: UInt8?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Int16?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: UInt16?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Int32?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: UInt32?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Int64?) {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given integer value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: UInt64?)  {
    guard let lhs = lhs else { return }
    lhs.integerValue = rhs == nil ? nil : Int(rhs!)
}


/// Assign a given double value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Float?) {
    guard let lhs = lhs else { return }
    lhs.doubleValue = rhs == nil ? nil : Double(rhs!)
}


/// Assign a given double value to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Double?) -> VJson? {
    guard let lhs = lhs else { return nil }
    lhs.doubleValue = rhs
    return lhs
}


/// Assign a given Number to the JSON item. Change the JSON item into a NUMBER if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: NSNumber?) -> VJson? {
    guard let lhs = lhs else { return nil }
    lhs.numberValue = rhs?.copy() as? NSNumber
    return lhs
}


/// Assign a given bool to the JSON item. Change the JSON item into a BOOL if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: Bool?) -> VJson? {
    guard let lhs = lhs else { return nil }
    lhs.boolValue = rhs
    return lhs
}


/// Assign a given string to the JSON item. Change the JSON item into a STRING if possible. If the optional is nil, the JSON item becomes a NULL.

public func &= (lhs: VJson?, rhs: String?) -> VJson? {
    guard let lhs = lhs else { return nil }
    lhs.stringValue = rhs
    return lhs
}


/// The Equatable protocol

public func == (lhs: VJson, rhs: VJson) -> Bool {
    if lhs === rhs { return true }
    if lhs.type != rhs.type { return false }
    if lhs.bool != rhs.bool { return false }
    if lhs.number != rhs.number { return false }
    if lhs.string != rhs.string { return false }
    if lhs.name != rhs.name { return false }
    if (lhs.children == nil) { return true } // Type equality is already established
    if lhs.children!.count != rhs.children!.count { return false }
    for i in 0 ..< lhs.children!.count {
        let lhc = lhs.children![i]
        let rhc = rhs.children![i]
        if lhc != rhc { return false }
    }
    return true
}

public func != (lhs: VJson, rhs: VJson) -> Bool {
    return !(lhs == rhs)
}


/**
 This class implements the JSON specification.
 */

public final class VJson: Equatable, CustomStringConvertible, SequenceType {
    
    
    /// The error type that gets thrown if errors are found during parsing.
    
    public enum Exception: ErrorType, CustomStringConvertible {
        case REASON(code: Int, incomplete: Bool, message: String)
        public var description: String {
            if case let .REASON(code, incomplete, message) = self { return "[\(code), Incomplete:\(incomplete)] \(message)" }
            return "VJson: Error in Exception enum"
        }
    }
    
    
    /// Error info from the parser.
    
    public struct ParseError {
        public var code: Int
        public var incomplete: Bool
        public var message: String
        public init(code: Int, incomplete: Bool, message: String) {
            self.code = code
            self.incomplete = incomplete
            self.message = message
        }
        public init() {
            self.init(code: -1, incomplete: false, message: "")
        }
        public var description: String {
            return "[\(code), Incomplete:\(incomplete)] \(message)"
        }
    }
    
    
    /// Set this option to 'true' to help find unwanted type conversions (in the debugging phase?).
    /// - Note: Conversion to and from NULL remain possible, Thus to invoke a type change from NUMBER to STRING transition through NULL.
    
    public static var fatalErrorOnTypeConversion = true
    
    
    // =================================================================================================================
    // MARK: - type

    /// The JSON types.
    
    public enum JType: String {
        case NULL = "NULL"
        case BOOL = "BOOL"
        case NUMBER = "NUMBER"
        case STRING = "STRING"
        case OBJECT = "OBJECT"
        case ARRAY = "ARRAY"
    }

    
    /// The JSON type of this object.
    
    private var type: JType
    
    
    /// - Returns: True if this object contains a JSON NULL object.
    
    public var isNull: Bool { return self.type == JType.NULL }
    
    
    /// - Returns: True if this object contains a JSON BOOL object.
    
    public var isBool: Bool { return self.type == JType.BOOL }
    
    
    /// - Returns: True if this object contains a JSON NUMBER object.
    
    public var isNumber: Bool { return self.type == JType.NUMBER }

    
    /// - Returns: True if this object contains a JSON STRING object.

    public var isString: Bool { return self.type == JType.STRING }
    
    
    /// - Returns: True if this object contains a JSON ARRAY object.

    public var isArray: Bool { return self.type == JType.ARRAY }


    /// - Returns: True if this object contains a JSON OBJECT object.

    public var isObject: Bool { return self.type == JType.OBJECT }

    
    // =================================================================================================================
    // MARK: - Creating & initializing a JSON hierarchy
    
    
    // Default initializer
    
    private init(type: JType, name: String? = nil) {
        
        self.type = type
        self.name = name
        
        switch type {
        case .OBJECT, .ARRAY: children = Array<VJson>()
        default: break
        }
    }

    
    /// - Returns: An empty VJson hierarchy
    
    public convenience init() {
        self.init(type: .OBJECT)
    }
    
    
    /// Create a VJson hierarchy with the contents of the given file.
    /// - Parameter file: The URL that designates the file to be read.
    /// - Throws: Either an VJson.Error.REASON or an NSError if the VJson hierarchy could not be created or the file not be read.
    
    public static func parse(file: NSURL) throws -> VJson {
        let data = try NSData(contentsOfFile: file.path!, options: NSDataReadingOptions.DataReadingUncached)
        return try vJsonParser(UnsafePointer<UInt8>(data.bytes), numberOfBytes: data.length)
    }
    
    
    /// Create a VJson hierarchy with the contents of the given file.
    /// - Parameter file: The URL that designates the file to be read.
    /// - Parameter errorInfo: A (pointer to a) struct that will contain the error infor if an error occured during parsing (i.e. when the result of the function if nil). If the pointer is nil, no such information will be present.
    /// - Returns: On success the JSON hierarchy. On error a nil for the JSON hierarchy and the structure with error information filled if that structure was present on the call.
    
    public static func parse(file: NSURL, inout errorInfo: ParseError?) -> VJson? {
        do {
            return try parse(file)
        
        } catch let error as VJson.Exception {
        
            if case let .REASON(code, incomplete, message) = error {
                if errorInfo != nil {
                    errorInfo!.code = code
                    errorInfo!.incomplete = incomplete
                    errorInfo!.message = message
                }
            } else {
                if errorInfo != nil {
                    errorInfo!.code = -1
                    errorInfo!.incomplete = false
                    errorInfo!.message = "Could not retrieve error info from parse exception"
                }
            }
            return nil

        } catch {
            if errorInfo != nil {
                errorInfo!.code = -1
                errorInfo!.incomplete = false
                errorInfo!.message = "\(error)"
            }
            return nil
        }
    }
    
    
    /// Create a VJson hierarchy with the contents of the given buffer.
    /// - Parameter buffer: The buffer containing the data to be parsed.
    /// - Parameter length: The number of bytes in the buffer that should be parsed.
    /// - Throws: A VJson.Error.REASON if the parsing failed.

    public static func parse(buffer: UnsafePointer<UInt8>, length: Int) throws -> VJson {
        return try VJson.vJsonParser(buffer, numberOfBytes: length)
    }
    
    
    /// Create a VJson hierarchy with the contents of the given buffer.
    /// - Parameter buffer: The buffer containing the data to be parsed.
    /// - Parameter length: The number of bytes in the buffer that should be parsed.
    /// - Parameter errorInfo: A (pointer to a) struct that will contain the error infor if an error occured during parsing (i.e. when the result of the function if nil). If the pointer is nil, no such information will be present.
    /// - Returns: On success the JSON hierarchy. On error a nil for the JSON hierarchy and the structure with error information filled if that structure was present on the call.

    public static func parse(buffer: UnsafePointer<UInt8>, length: Int, inout errorInfo: ParseError?) -> VJson? {
        do {
            return try parse(buffer, length: length)
            
        } catch let error as VJson.Exception {
            
            if case let .REASON(code, incomplete, message) = error {
                if errorInfo != nil {
                    errorInfo!.code = code
                    errorInfo!.incomplete = incomplete
                    errorInfo!.message = message
                }
            } else {
                if errorInfo != nil {
                    errorInfo!.code = -1
                    errorInfo!.incomplete = false
                    errorInfo!.message = "Could not retrieve error info from parse exception"
                }
            }
            return nil
            
        } catch {
            if errorInfo != nil {
                errorInfo!.code = -1
                errorInfo!.incomplete = false
                errorInfo!.message = "\(error)"
            }
            return nil
        }
    }

    
    /// Create a VJson hierarchy with the contents of the given string.
    /// - Parameter string: The string containing the data to be parsed.
    /// - Throws: A VJson.Error.REASON if the parsing failed.

    public static func parse(string: String) throws -> VJson {
        guard let buffer = string.dataUsingEncoding(NSUTF8StringEncoding) else { throw VJson.Exception.REASON(code: 59, incomplete: false, message: "Could not convert string to UTF8") }
        return try VJson.vJsonParser(NSMutableData(data: buffer))
    }
    
    
    /// Create a VJson hierarchy with the contents of the given buffer.
    /// - Parameter string: The string containing the data to be parsed.
    /// - Parameter errorInfo: A (pointer to a) struct that will contain the error infor if an error occured during parsing (i.e. when the result of the function if nil). If the pointer is nil, no such information will be present.
    /// - Returns: On success the JSON hierarchy. On error a nil for the JSON hierarchy and the structure with error information filled if that structure was present on the call.
    
    public static func parse(string: String, inout errorInfo: ParseError?) -> VJson? {
        do {
            return try parse(string)
            
        } catch let error as VJson.Exception {
            
            if case let .REASON(code, incomplete, message) = error {
                if errorInfo != nil {
                    errorInfo!.code = code
                    errorInfo!.incomplete = incomplete
                    errorInfo!.message = message
                }
            } else {
                if errorInfo != nil {
                    errorInfo!.code = -1
                    errorInfo!.incomplete = false
                    errorInfo!.message = "Could not retrieve error info from parse exception"
                }
            }
            return nil
            
        } catch {
            if errorInfo != nil {
                errorInfo!.code = -1
                errorInfo!.incomplete = false
                errorInfo!.message = "\(error)"
            }
            return nil
        }
    }

    
    /**
     Create a a new JSON hierarchy from the mutable data object and removes the found JSON hierarchy from the mutable data object. If no valid JSON hierarchy was found, the mutable data object will be unchanged.
     
     - Returns: The JSON hierarchy.
     
     - Throws: A VJson.Exception if no JSON hierarchy could be read.
     */
    
    public static func parse(buffer: NSMutableData) throws -> VJson {
        return try VJson.vJsonParser(buffer)
    }

    
    /// Create a a new JSON hierarchy from the mutable data object and removes the found JSON hierarchy from the mutable data object. If no valid JSON hierarchy was found, the mutable data object will be unchanged.
    /// - Parameter buffer: The mutable data object containing the data to be parsed.
    /// - Parameter errorInfo: A (pointer to a) struct that will contain the error infor if an error occured during parsing (i.e. when the result of the function if nil). If the pointer is nil, no such information will be present.
    /// - Returns: On success the JSON hierarchy. On error a nil for the JSON hierarchy and the structure with error information filled if that structure was present on the call.
    
    public static func parse(buffer: NSMutableData, inout errorInfo: ParseError?) -> VJson? {
        do {
            return try parse(buffer)
            
        } catch let error as VJson.Exception {
            
            if case let .REASON(code, incomplete, message) = error {
                if errorInfo != nil {
                    errorInfo!.code = code
                    errorInfo!.incomplete = incomplete
                    errorInfo!.message = message
                }
            } else {
                if errorInfo != nil {
                    errorInfo!.code = -1
                    errorInfo!.incomplete = false
                    errorInfo!.message = "Could not retrieve error info from parse exception"
                }
            }
            return nil
            
        } catch {
            if errorInfo != nil {
                errorInfo!.code = -1
                errorInfo!.incomplete = false
                errorInfo!.message = "\(error)"
            }
            return nil
        }
    }

    
    // =================================================================================================================
    // MARK: - name
    
    // The name of this object if it is part of a name/value pair.
    
    private var name: String?
    
    /// - Parameter newValue: The new name for this object. If this object did not have a name, it will turn this object into a name/value pair.
    /// - Returns: The name part of a name/value pair. Nil if this object does not have a name.
    
    public var nameValue: String? {
        get {
            return name
        }
        set {
            name = newValue
        }
    }

    /// - Returns: True if this object is a name/value pair. False otherwise.
    
    public var hasName: Bool { return name != nil }
    
    
    // =================================================================================================================
    // MARK: - null

    /// - Parameter newValue: Writing (i.e. true or false) will always convert this value into a JSON NULL if it was not. If it was of a different type, old information will be discarded.
    /// - Returns: True if this is a JSON NULL item, nil otherwise.

    public var nullValue: Bool? {
        get {
            if type == .NULL {
                return true
            } else {
                return nil
            }
        }
        set {
            if !isNull {
                neutralize()
                type = .NULL
            }
            createdBySubscript = false // A previous null may have been created by a subscript accessor, this prevents it from being removed.
        }
    }
    
    
    /// - Returns: True if the type of this object is .NULL, false in all other cases.
    
    public var asNull: Bool { return type == .NULL }

    
    /// - Returns: A VJson NULL item.
    
    static func null(name: String? = nil) -> VJson {
        return VJson(type: VJson.JType.NULL, name: name)
    }
    
    
    // =================================================================================================================
    // MARK: - bool
    
    // The value if this is a .BOOL JSON value.
    
    private var bool: Bool?
    
    
    /// - Parameter newValue: The new bool value of this JSON item. Note that it will also convert this object into a JSON BOOL if it was of a different type, discarding old information in the process (if any)
    /// - Returns: The bool value of this object if the object is a JSON BOOL. Nil if this object is not a JSON BOOL item.
    
    public var boolValue: Bool? {
        get {
            return bool
        }
        set {
            if type != .BOOL {
                if VJson.fatalErrorOnTypeConversion && type != .NULL { fatalError("Type conversion error from \(type) to BOOL") }
                neutralize()
                type = .BOOL
            }
            bool = newValue
        }
    }
    
    
    /// - Returns: The bool value of this object if the object is a JSON BOOL. Otherwise it will try to interpret the value as a bool e.g. a NULL will be false, a NUMBER 1(.0) = true, other numbers are false, STRING "true" equals true, all other strings equal false. ARRAY and OBJECT both equal false.

    public var asBool: Bool {
        switch type {
        case .NULL: return false
        case .BOOL: return bool == nil ? false : bool!
        case .NUMBER: return number == nil ? false : number!.boolValue ?? false
        case .STRING: return string == nil ? false : string! == "true"
        case .OBJECT: return false
        case .ARRAY: return false
        }
    }
    
    
    /// - Returns: A VJson BOOL item with the given values.

    convenience init(_ value: Bool?, name: String? = nil) {
        self.init(type: VJson.JType.BOOL, name: name)
        bool = value
    }

    
    // =================================================================================================================
    // MARK: - number

    // The value if this is a .NUMBER JSON value.
    
    private var number: NSNumber?
    
    
    /// - Parameter newValue: The doubleValue of this NSNumber will be used to create a new NSNumber for this JSON item. Note that it will also convert this object into a JSON NUMBER if it was of a different type. Discarding old information in the process (if any)
    /// - Returns: A NSNumber copy of the doubleValue of the NSNumber in this object if this object is a JSON NUMBER. Nil otherwise.

    public var numberValue: NSNumber? {
        get {
            return number?.copy() as? NSNumber
        }
        set {
            if type != .NUMBER {
                if VJson.fatalErrorOnTypeConversion && type != .NULL { fatalError("Type conversion error from \(type) to NUMBER") }
                neutralize()
                type = .NUMBER
            }
            number = newValue?.copy() as? NSNumber
        }
    }

    
    /// - Returns: Attempts to interpret the value of this object as a number and then creates a new NSNumber with that value. For a NUMBER it returns a copy of that number, for NULL, OBJECT and ARRAY it returns a NSNumber with the value 0, for STRING it tries to read the string as a number (if that fails, it is regarded as a zero) and for a BOOL it creates a NSNumber with the bool as its value.
    
    public var asNumber: NSNumber {
        switch type {
        case .NULL, .OBJECT, .ARRAY: return NSNumber(int: 0)
        case .BOOL:   return bool == nil   ? NSNumber(int: 0) : NSNumber(bool: self.bool!)
        case .NUMBER: return number == nil ? NSNumber(int: 0) : number!.copy() as! NSNumber
        case .STRING: return string == nil ? NSNumber(int: 0) : NSNumber(double: (string! as NSString).doubleValue)
        }
    }
    
    
    /// - Parameter newValue: The value of this int will be used to create a new NSNumber for this JSON item. Note that it will also convert this object into a JSON NUMBER if it was of a different type, discarding old information in the process (if any)
    /// - Returns: A NSNumber copy of the integerValue of the NSNumber in this object if this object is a JSON NUMBER. Otherwise a value of zero.

    public var integerValue: Int? {
        get {
            return number?.integerValue
        }
        set {
            if newValue == nil {
                numberValue = nil
            } else {
                numberValue = NSNumber(integer: newValue!)
            }
        }
    }

    
    /// - Returns: Attempts to interpret the value of this object as a number and returns its integerValue. For a NUMBER it returns its integer value, for NULL, OBJECT and ARRAY it returns the value 0, for STRING it tries to read the string as a number (if that fails, it is regarded as a zero) and return its integer value and for a BOOL it creates a NSNumber with the bool as its value and returns the integer value of it.

    public var asInt: Int {
        return asNumber.integerValue
    }

    
    /// - Parameter newValue: The value of this double will be used to create a new NSNumber for this JSON item. Note that it will also convert this object into a JSON NUMBER if it was of a different type, discarding old information in the process (if any)
    /// - Returns: A NSNumber with the value of the doubleValue of the NSNumber in this object if this object is a JSON NUMBER. Otherwise a NSNumber with a value of zero.

    public var doubleValue: Double? {
        get {
            return number?.doubleValue
        }
        set {
            if newValue == nil {
                numberValue = nil
            } else {
                numberValue = NSNumber(double: newValue!)
            }
        }
    }

    
    /// - Returns: Attempts to interpret the value of this object as a number and returns its doubleValue. For a NUMBER it returns its double value, for NULL, OBJECT and ARRAY it returns the value 0.0, for STRING it tries to read the string as a number (if that fails, it is regarded as a zero) and return its double value and for a BOOL it creates a NSNumber with the bool as its value and returns the double value of it.

    public var asDouble: Double {
        return asNumber.doubleValue
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: Int?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: UInt?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }

    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: Int8?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }

    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: UInt8?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: Int16?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: UInt16?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }

    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: Int32?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: UInt32?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }

    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: Int64?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: UInt64?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        integerValue = value == nil ? nil : Int(value!)
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: Float?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        doubleValue = value == nil ? nil : Double(value!)
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: Double?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        doubleValue = value
    }
    
    
    /// - Returns: A VJson NUMBER item with the given values.
    
    convenience init(_ value: NSNumber?, name: String? = nil) {
        self.init(type: VJson.JType.NUMBER, name: name)
        number =  value == nil ? nil : (value!.copy() as! NSNumber)
    }

    
    // =================================================================================================================
    // MARK: - string
    
    // The value if this is a .STRING JSON value.
    
    private var string: String?
    
    /// - Parameter newValue: The value that will be used to update the string of this JSON item. Note that it will also convert this object into a JSON STRING if it was of a different type, discarding old information in the process (if any). If the newValue contains any double-quotes, these will be escaped.
    /// - Returns: A string value of this object if this object is a JSON STRING. If the JSON string contained escaped quotes, these escaped sequences will be replaced by a normal double quote. Otherwise nil.

    public var stringValue: String? {
        get {
            if string == nil { return nil }
            return self.string!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
        }
        set {
            if type != .STRING {
                if VJson.fatalErrorOnTypeConversion && type != .NULL { fatalError("Type conversion error from \(type) to STRING") }
                neutralize()
                type = .STRING
            }
            string = newValue?.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        }
    }

    
    /// - Returns: Attempts to interpret the value of this object as a string and returns it. NUMBER and BOOL return their string representation. NULL it returns "null" for OBJECT and ARRAY it returns an empty string.
    
    public var asString: String {
        switch type {
        case .NULL: return "null"
        case .BOOL: return bool == nil ? "null" : "\(bool!)"
        case .STRING: return string == nil ? "null" : string!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
        case .NUMBER: return number == nil ? "null" : number!.stringValue
        case .ARRAY, .OBJECT: return ""
        }
    }
    
    
    /// - Returns: A VJson STRING item with the given values.
    
    convenience init(_ value: String?, name: String? = nil) {
        self.init(type: VJson.JType.STRING, name: name)
        string = value
    }

    
    // =================================================================================================================
    // MARK: - array/object
    
    // Contains the child elements, be they array elements of name/value pairs.
    
    private var children: Array<VJson>?
    
    
    /// - Returns: True if this object contains any childeren, either ARRAY items or OBJECT items. False if this object does not have any children.
    
    public var hasChildren: Bool {
        if children == nil { return false }
        return children!.count > 0
    }
    
    
    /// - Returns: The number of child objects this object contains. Always returns 0 if this object is neither an OBJECT or an ARRAY.
    
    public var nofChildren: Int {
        if !hasChildren { return 0 }
        return children!.count
    }
    
    
    /// - Parameter newValue: Copies of the content of this array will replace the existing children.
    /// - Returns: An array containing a copy of all children if this is an ARRAY or OBJECT item. For all other types it returns an empty array.
    
    public var arrayValue: Array<VJson>? {
        guard type == .ARRAY || type == .OBJECT else { return nil }
        var arr: Array<VJson> = []
        for child in children! {
            arr.append(child.copy)
        }
        return arr
    }
    
    
    /// - Parameter newValue: Copies of the content of this dictionary will replace the existing children.
    /// - Returns: A dictionary containing a copy of all children if this is an OBJECT item. For all other types it returns an empty array.

    public var dictionaryValue: Dictionary<String, VJson>? {
        if type != .OBJECT { return nil }
        var dict: Dictionary<String, VJson> = [:]
        for child in children! {
            dict[child.name!] = child.copy
        }
        return dict
    }

    
    /// - Returns an empty JSON ARRAY item with the given name
    
    public static func array(name: String? = nil) -> VJson {
        return VJson([VJson?](), name: name)
    }
    
    
    /// - Returns an empty JSON OBJECT item with the given name
    
    public static func object(name: String? = nil) -> VJson {
        return VJson([String:VJson](), name: name)
    }
    
    
    /// - Returns: A JSON ARRAY item with the specified children. Array elements that are 'nil' will not be included unless the "includeNil" parameter is set to 'true'. When 'nil' items are included they are included as NULL items.

    convenience init(_ children: [VJson?], name: String? = nil, includeNil: Bool = false) {
        self.init(type: VJson.JType.ARRAY, name: name)
        if includeNil {
            self.children!.appendContentsOf(children.map(){ $0 ?? VJson.null()})
        } else {
            self.children!.appendContentsOf(children.flatMap(){$0})
        }
    }
    
    
    /// - Returns: A JSON ARRAY item with the specified children. Array elements that are 'nil' will not be included unless the "includeNil" parameter is set to 'true'. When 'nil' items are included they are included as NULL items.
    
    convenience init(_ children: [VJsonSerializable?], name: String? = nil, includeNil: Bool = false) {
        self.init(children.map({$0?.json}), name: name, includeNil: includeNil)
    }

    
    /// - Returns: A JSON OBJECT item with the children from the dictionary.
    
    convenience init(_ children: [String:VJson], name: String? = nil) {
        self.init(type: VJson.JType.OBJECT, name: name)
        var newChildren: [VJson] = []
        for (name, child) in children {
            child.name = name
            newChildren.append(child)
        }
        self.children!.appendContentsOf(newChildren)
    }
    
    
    /// - Returns: A JSON OBJECT item with the children from the dictionary.
    
    convenience init(_ children: [String:VJsonSerializable], name: String? = nil) {
        self.init(type: VJson.JType.OBJECT, name: name)
        var newChildren: [VJson] = []
        for (name, child) in children {
            let jchild = child.json
            jchild.name = name
            newChildren.append(jchild)
        }
        self.children!.appendContentsOf(newChildren)
    }

    
    /// - Returns: True if self is an ARRAY that could be turned into an OBJECT without information loss. Otherwise false.
    /// - Note: The prupose of this operation is to turn an array into an object. Which can only succeed if all elements of the array have a name.
    
    func arrayToObject() -> Bool {
        if type != .ARRAY { return false }
        for c in children! {
            if !c.hasName { return false }
        }
        self.type = .OBJECT
        return true
    }

    
    /// - Returns: Self as a JSON ARRAY item if self was a JSON ARRAY or OBJECT. Otherwise nil.
    
    func objectToArray() -> Bool {
        if type != .OBJECT { return false }
        type = .ARRAY
        return true
    }
    
    
    // =================================================================================================================
    // MARK: - Type conversion support
    
    // If this object was created to fullfill a subscript access, this property is set to 'true'. It is false for all other objects.
    
    private var createdBySubscript: Bool = false

    
    private func neutralize() {
        children = nil
        createdBySubscript = false
        bool = nil
        number = nil
        string = nil
    }

    
    // =================================================================================================================
    // MARK: - Child access/management
    
    /**
     Inserts the given child at the given index. Self must be a JSON ARRAY item.
     
     - Parameter child: The VJson object to be inserted.
     - Parameter at: The index at which it will be inserted. Must be <= nofChildren to succeed.
     
     - Returns: The child if the operation succeeded, nil if nothing was done.

     */
    
    public func insert(child: VJson?, at index: Int) -> VJson? {

        guard let child = child else { return nil }
        
        guard type == .ARRAY else { return nil }
        guard index <= nofChildren else { return nil }
        
        children!.insert(child, atIndex: index)
        
        return child
    }
    
    
    /**
     Appends the given object to the end of the array. Self must be a JSON ARRAY item or newly created through a subscript operation.
     
     - Parameter child: The VJson object to be appended.
     
     - Returns: The child if the operation succeeded, nil if nothing was done.
     */
    
    public func append(child: VJson?) -> VJson? {
        
        guard let child = child else { return nil }
        
        if type == .NULL { changeToArrayType() }

        guard type == .ARRAY else { return nil }
        
        children!.append(child)
        
        return child
    }
    
    
    /**
     Replaces the child at the given index with the given child. Self must be a JSON ARRAY item.
     
     - Parameter childAt: The index of the child to be replaced
     - Parameter child: The VJson object to be inserted.
     
     - Returns: The new child if the operation succeeded, nil if nothing was done.
     */
    
    public func replace(childAt index: Int, with child: VJson? ) -> VJson? {
        
        guard let child = child else { return nil }

        guard type == .ARRAY else { return nil }
        guard index < nofChildren else { return nil }

        children![index] = child
        
        return child
    }
    
    
    /// - Returns the index of the first child with identical contents as the given child. Nil if no comparable child is found. Self must be a JSON ARRAY item.
    
    public func indexOf(child: VJson?) -> Int? {
        
        guard let child = child else { return nil }
        guard type == .ARRAY else { return nil }
        
        for (index, myChild) in children!.enumerate() {
            if myChild === child { return index }
            if myChild == child { return index }
        }
        
        return nil
    }
    
    
    /// Removes all children with identical contents as the given child from the hierarchy. Self must be a JSON ARRAY item or a JSON OBJECT item.
    /// - Returns: True if a child was removed, false if not.
    
    public func remove(child: VJson?) -> Bool {
        
        guard let child = child else { return false }
        guard children != nil else { return false }

        let preCount = children!.count
        
        self.children = self.children?.filter(){ $0 != child }
        
        return children!.count != preCount
    }
    
    
    /// Removes all children from this object.
    
    public func removeAll() {
        if children != nil { children!.removeAll() }
    }
    
    
    /**
     Add a new item with the given name or replace a current item with that same name (when "replace" = 'true'). Self must be a JSON OBJECT item or a NULL. If it is a NULL it will be converted into an OBJECT.
    
     - Parameter child: The child that should replace or be appended. The child must have a name or a name must be provided in the parameter "forName". If a name is provided in "forName" then that name will take precedence and replace the name contained in the child item.
     - Parameter forName: If nil, the child must already have a name. If non-nil, then this name will be used and the name of the child (if present) will be overwritten.
     - Parameter replace: If 'true' (default) it will replace all existing items with the same name. If 'false', then the child will be added and no check on duplicate names will be performed.
    
     - Returns: The child if the operation succeeded, nil if nothing was done.
    */
 
    public func add(child: VJson?, forName name: String? = nil, replace: Bool = true) -> VJson? {
        
        guard let child = child else { return nil }
        
        if type == .NULL { changeToObjectType() }

        guard type == .OBJECT else { return nil }
        if name == nil && !child.hasName { return nil }
        
        if name != nil { child.name = name }
        
        if replace { removeChildren(child.name!) }

        children!.append(child)

        return child
    }

    
    /// Removes all children with the given name. Self must be a JSON OBJECT item.
    /// - Returns: True if a child was removed.
    
    public func removeChildren(withName: String) -> Bool {
        
        guard type == .OBJECT else { return false }
        
        let count = children!.count
        
        self.children = self.children!.filter(){ $0.name != withName }
        
        return count != children!.count
    }
    
    
    /// Return all childs with the given name. The count will be zero if no child with the given name exists.

    public func children(withName: String) -> [VJson] {
        
        guard type == .OBJECT else { return [] }
        
        return self.children!.filter(){ $0.name == withName }
    }
    

    // MARK: - Sequence and Generator protocol

    public struct MyGenerator: GeneratorType {
        
        public typealias Element = VJson
        
        // The object for which the generator generates
        let source: VJson
        
        // The objects already delivered through the generator
        var sent: Array<VJson> = []
        
        init(source: VJson) {
            self.source = source
        }
        
        mutating public func next() -> Element? {
            
            // Only when the source has values to deliver
            if let values = source.children {
                
                // Find a value that has not been sent already
                OUTER: for i in values {
                    
                    // Check if the value has not been sent already
                    for s in sent {
                        
                        // If it was sent, then try the next value
                        if i === s { continue OUTER }
                    }
                    
                    // Found a value that was not sent yet
                    // Remember that it will be sent
                    sent.append(i)
                    
                    // Send it
                    return i
                }
            }
            
            // Nothing left to send
            return nil

        }
    }
    
    public typealias Generator = MyGenerator
    public func generate() -> Generator { return MyGenerator(source: self) }
    
    
    // MARK: - Subscript accessors
    
    public subscript(index: Int) -> VJson {
        
        set {
            
            // If this is an ARRAY object, then make sure there are enough elements and create the requested element
            
            if type != .ARRAY {


                // Create a fatal error when type conversions are unwanted
            
                if VJson.fatalErrorOnTypeConversion && type != .NULL { fatalError("Type conversion error from \(type) to ARRAY") }

            
                // If this is not an ARRAY and not an OBJECT, then turn it into an ARRAY and create the requested element
            
                if type == .OBJECT {
                    objectToArray()
                } else {
                    changeToArrayType()
                }
            
            }
            
            
            // Ensure that enough elements are present in the array
                
            if index >= children!.count {
                for _ in children!.count ... index {
                    let newObject = VJson.null()
                    newObject.createdBySubscript = true
                    children!.append(newObject)
                }
            }
                
            children![index] = newValue
            
            return
        }
        
        get {
            
            
            // If this is an ARRAY object, then make sure there are enough elements and return the requested element
            
            if type != .ARRAY {
                

                // Create a fatal error when type conversions are unwanted
                
                if VJson.fatalErrorOnTypeConversion && type != .NULL { fatalError("Type conversion error from \(type) to ARRAY") }
                
                
                // If this is not an ARRAY and not an OBJECT, then turn it into an ARRAY and return the requested element
                
                if type == .OBJECT {
                    objectToArray()
                } else {
                    changeToArrayType()
                }
            }
            
            
            // Ensure that enough elements are present in the array
                
            if index >= children!.count {
                for _ in children!.count ... index {
                    let newObject = VJson.null()
                    newObject.createdBySubscript = true
                    children!.append(newObject)
                }
            }
                
            return children![index]
        }
    }

    
    // Subscript getter/setter for a JSON OBJECT type.
    
    public subscript(key: String) -> VJson {
        
        set {
            
            
            // If this is not an object type, change it into an object
            
            if type != .OBJECT {
                
                
                // Create a fatal error when type conversions are unwanted
                
                if VJson.fatalErrorOnTypeConversion && type != .NULL { fatalError("Type conversion error from \(type) to OBJECT") }

                changeToObjectType()
            }

            add(newValue, forName: key)
        }
        
        get {
            
            
            // If this is not an object type, change it into an object
            
            if type != .OBJECT {
                
                
                // Create a fatal error when type conversions are unwanted
                
                if VJson.fatalErrorOnTypeConversion && type != .NULL { fatalError("Type conversion error from \(type) to OBJECT") }
                
                changeToObjectType()
            }
            

            // If the requested object exist, return it
            
            let arr = children(key)
            
            if arr.count > 0 { return arr[0] }

            
            // If the request value does not exist, create it
            // This allows object creation for 'object["key1"]["key2"]["key3"] = SwifterJSON(12)' constructs.
            
            let newObject = VJson.null()
            newObject.createdBySubscript = true
            add(newObject, forName: key)
            
            return newObject
        }
    }

    private func changeToArrayType() {
        neutralize()
        children = Array<VJson>()
        type = .ARRAY
    }
    
    private func changeToObjectType() {
        neutralize()
        children = Array<VJson>()
        type = .OBJECT
    }

    
    /// - Returns: the item at the given path if it exists and is of the given type. Otherwise nil.
    
    public func item(ofType: JType, atPath path: [String]) -> VJson? {
        
        if path.count == 0 {
         
            if self.type == ofType { return self }
            return nil
        
        } else {
        
            switch self.type {
                
            case .ARRAY:
                
                let i = (path[0] as NSString).integerValue
                
                if i >= self.nofChildren { return nil }
                
                var newPath = path
                newPath.removeFirst()
                
                return children![i].item(ofType, atPath: newPath)
                
                
            case .OBJECT:
                
                for child in children! {
                    if child.name == nil { return nil } // Should not be possible
                    if child.name == path[0] {
                        
                        var newPath = path
                        newPath.removeFirst()
                        
                        return child.item(ofType, atPath: newPath)
                    }
                }
                return nil
                

            default: return nil
            }
        }
    }
    
    
    /// - Returns: the object at the given path if it exists and is of the given type. Otherwsie nil.

    public func item(ofType: JType, atPath path: String ...) -> VJson? {
        return item(ofType, atPath: path)
    }

    
    // Remove empty objects that resulted from subscript access.
    
    private func removeEmptySubscriptObjects() {

        
        // For JSON OBJECTs, remove all name/value pairs that are created by a subscript and do not contain any non-subscript generated value
        
        if type == .OBJECT {
            
            
            // Itterate over all name/value pairs
            
            for child in children! {
                
                
                // Make sure that this value has all its subscript generated values removed
                
                if child.nofChildren > 0 { child.removeEmptySubscriptObjects() }
                
                
                // Remove the value if it is generated by subscript and contains no usefull items
                
                if child.createdBySubscript && child.nofChildren == 0 {
                    self.remove(child)
                }
            }
            
            return
        }
        
        
        // For JSON ARRAYs, remove all values that are createdby a subscript and do not contain any non-subscript generated value
        
        if type == .ARRAY {
            
            
            // This array will contain the indicies of all values that should be removed
            
            var itemsToBeRemoved = [Int]()
            
            
            // Loop over all values, backwards. As soon as a value is hit that cannot be removed, stop iterating
            
            if children!.count > 0 {
                
                for index in (0 ..< children!.count).reverse() {
                    
                    let child = children![index]
                    
                    
                    // Make sure that this value has all its subscript generated values removed
                    
                    if child.nofChildren > 0 { child.removeEmptySubscriptObjects() }
                    
                    
                    // If this value is created by subscript, then check if it has content
                    
                    if child.createdBySubscript && child.nofChildren == 0 {
                        itemsToBeRemoved.append(index)
                    } else {
                        break
                    }
                }
                
                
                // Actually remove items, if any.
                // Note: Because of the reverse loop above, the indexes in itemsToBeRemoved count down.
                
                for i in itemsToBeRemoved { children!.removeAtIndex(i) }
            }
        }
    }


    // MARK: - Auxillary stuff and object management
    
    
    /// The custom string convertible protocol.
    /// - Note: Do not use this function to obtain a fully formed JSON code.
    
    public var description: String {
        
        // Get rid of subscript generated objects that no longer serve a purpose
        
        self.removeEmptySubscriptObjects()
        
        var str = ""
        
        switch type {
            
        case .NULL:
        
            str += "null"
        
        
        case .BOOL:
            
            if bool == nil {
                str += "null"
            } else {
                str += "\(self.bool!)"
            }
            
        
        case .NUMBER:
            
            if number == nil {
                str += "null"
            } else {
                str += "\(self.number!)"
            }
            
            
        case .STRING:
            
            if string == nil {
                str += "null"
            } else {
                str += "\"\(self.string!)\""
            }
        
            
        case .OBJECT:
            
            str += "{"
            
            if children!.count > 0 {
                let firstChild = children!.removeAtIndex(0)
                str += children!.reduce("\"\(firstChild.name!)\":\(firstChild)") { $0 + ",\"\($1.name!)\":\($1)" }
                children!.insert(firstChild, atIndex: 0)
            }

            str += "}"

            
        case .ARRAY:
            
            str += "["
            
            if children!.count > 0 {
                let firstChild = children!.removeAtIndex(0)
                str += children!.reduce("\(firstChild)") { $0 + ",\($1)" }
                children!.insert(firstChild, atIndex: 0)
            }

            str += "]"
        }
                
        return str
    }
    
    
    
    
    /// - Returns: A full in-depth copy of this JSON object. I.e. all child elements are also copied.
    
    public var copy: VJson {
        let copy = VJson(type: self.type, name: self.name)
        switch type {
        case .NULL: break
        case .BOOL: copy.bool = self.bool!
        case .NUMBER: copy.number = self.number!.copy() as? NSNumber
        case .STRING: copy.string = self.string!
        case .ARRAY, .OBJECT:
            for c in self.children! {
                copy.children!.append(c.copy)
            }
        }
        copy.createdBySubscript = createdBySubscript
        return copy
    }
    
    
    /**
     Tries to saves the contents of the JSON hierarchy to the specified file.
     
     - Returns: Nil on success, Error description on fail.
     */
    
    public func save(url: NSURL) -> String? {
        let str = self.description
        do {
            try str.writeToURL(url, atomically: false, encoding: NSUTF8StringEncoding)
            return nil
        } catch let error as NSError {
            return error.localizedDescription
        }
    }
    
    
    // MARK: Parser functions
    
    /**
     Parses the given sequence of bytes (ASCII or UTF8 encoded) according to ECMA-404, 1st edition October 2013. The sequence should contain exactly one JSON hierarchy. Any errors will result in a throw.
    
     - Parameter buffer: The sequence of bytes to be parsed.
     - Parameter numberOfBytes: The number of bytes to be parsed.
    
     - Returns: On success only, a VJson hierarchy of the parse results.
    
     - Throws: If an error is countered during parsing, the VJson.Exception is thrown.
     */
    
    private static func vJsonParser(buffer: UnsafePointer<UInt8>, numberOfBytes: Int) throws -> VJson {
              
        guard numberOfBytes > 0 else { throw Exception.REASON(code: 1, incomplete: true, message: "Empty buffer") }
        
        
        // Start at the beginning
        
        var offset: Int = 0
        
        
        // Top level, a value is expected
        
        let val = try readValue(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        
        // Only whitespaces allowed after the value
        
        if offset < numberOfBytes {
            
            skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
            if offset < numberOfBytes { throw Exception.REASON(code: 2, incomplete: false, message: "Unexpected characters after end of parsing at offset \(offset - 1)") }
        }
        
        return val
    }
    
    
    /**
     Parses the data in the buffer according to ECMA-404, 1st edition October 2013, and creates a VJson hierarchy from it. On success it will also remove the processed data from (front of) the buffer. On failure the buffer will be unaffected.
     
     - Parameter buffer: A buffer containing ASCII or UTF8 characters.
     
     - Returns: A VJson hierarchy of the buffer contents up to the end of the first VJson hierarchy encountered. On success the VJson hierarchy will be removed from the buffer. On failure the buffer will remain unaffected.
     
     - Throws: If an error is countered during parsing, the VJson.Exception is thrown. This exception contains flag that can be used to determine if the error occured due to an incomplete JSON code. The callee then has the opportunity to add more data before trying again.
     */
    
    private static func vJsonParser(buffer: NSMutableData) throws -> VJson {
        
        guard buffer.length > 0 else { throw Exception.REASON(code: 3, incomplete: true, message: "Empty buffer") }
        
        
        // Start at the beginning
        
        var offset: Int = 0
        
        
        // Top level, a value is expected
        
        let val = try readValue(UnsafePointer<UInt8>(buffer.bytes), numberOfBytes: buffer.length, offset: &offset)
        
        
        // Remove consumed bytes

        if offset > 0 {
            let range = NSMakeRange(0, offset)
            buffer.replaceBytesInRange(range, withBytes: nil, length: 0)
        }
        
        return val
    }
    
    
    // MARK: - Private stuff
    
    // The number formatter for the number value
    
    private static var formatter: NSNumberFormatter?
    
    
    // The conversion from string to number using the above number formatter
    
    private static func toDouble(str: String) -> Double? {
        if VJson.formatter == nil {
            VJson.formatter = NSNumberFormatter()
            VJson.formatter!.decimalSeparator = "."
        }
        return VJson.formatter!.numberFromString(str)!.doubleValue
    }
    
    
    // Read the last three characters of a "true" value
    
    private static func readTrue(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {

        if offset >= numberOfBytes { throw Exception.REASON(code: 4, incomplete: true, message: "Illegal value, missing 'r' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_r { throw Exception.REASON(code: 5, incomplete: false, message: "Illegal value, no 'r' in 'true' at offset \(offset)") }
        offset += 1
        
        if offset >= numberOfBytes { throw Exception.REASON(code: 6, incomplete: true, message: "Illegal value, missing 'u' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_u { throw Exception.REASON(code: 7, incomplete: false, message: "Illegal value, no 'u' in 'true' at offset \(offset)") }
        offset += 1
        
        if offset >= numberOfBytes { throw Exception.REASON(code: 8, incomplete: true, message: "Illegal value, missing 'e' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_e { throw Exception.REASON(code: 9, incomplete: false, message: "Illegal value, no 'e' in 'true' at offset \(offset)") }
        offset += 1
        
        return VJson(true)
    }
    
    
    // Read the last four characters of a "false" value

    private static func readFalse(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {

        if offset >= numberOfBytes { throw Exception.REASON(code: 10, incomplete: true, message: "Illegal value, missing 'a' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_a { throw Exception.REASON(code: 11, incomplete: false, message: "Illegal value, no 'a' in 'true' at offset \(offset)") }
        offset += 1

        if offset >= numberOfBytes { throw Exception.REASON(code: 12, incomplete: true, message: "Illegal value, missing 'l' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_l { throw Exception.REASON(code: 13, incomplete: false, message: "Illegal value, no 'l' in 'true' at offset \(offset)") }
        offset += 1

        if offset >= numberOfBytes { throw Exception.REASON(code: 14, incomplete: true, message: "Illegal value, missing 's' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_s { throw Exception.REASON(code: 15, incomplete: false, message: "Illegal value, no 's' in 'true' at offset \(offset)") }
        offset += 1

        if offset >= numberOfBytes { throw Exception.REASON(code: 16, incomplete: true, message: "Illegal value, missing 'e' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_e { throw Exception.REASON(code: 17, incomplete: false, message: "Illegal value, no 'e' in 'true' at offset \(offset)") }
        offset += 1

        return VJson(false)
    }
    
    
    // Read the last three characters of a "null" value

    private static func readNull(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {

        if offset >= numberOfBytes { throw Exception.REASON(code: 18, incomplete: true, message: "Illegal value, missing 'u' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_u { throw Exception.REASON(code: 19, incomplete: false, message: "Illegal value, no 'u' in 'true' at offset \(offset)") }
        offset += 1
        
        if offset >= numberOfBytes { throw Exception.REASON(code: 20, incomplete: true, message: "Illegal value, missing 'l' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_l { throw Exception.REASON(code: 21, incomplete: false, message: "Illegal value, no 'l' in 'true' at offset \(offset)") }
        offset += 1
        
        if offset >= numberOfBytes { throw Exception.REASON(code: 22, incomplete: true, message: "Illegal value, missing 'l' in 'true' at end of buffer") }
        if buffer[offset] != ASCII_l { throw Exception.REASON(code: 23, incomplete: false, message: "Illegal value, no 'l' in 'true' at offset \(offset)") }
        offset += 1
        
        return VJson.null()
    }
    
    
    // Read the next characters as a string, ends with non-escaped double quote

    private static func readString(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {
        
        if offset >= numberOfBytes { throw Exception.REASON(code: 24, incomplete: true, message: "Missing end of string at end of buffer") }

        var strbuf = Array<UInt8>()

        var stringEnd = false
        
        while !stringEnd {
            
            if buffer[offset] == ASCII_DOUBLE_QUOTES {
                stringEnd = true
            } else {
                
                if buffer[offset] == ASCII_BACKSLASH {
                    
                    offset += 1
                    if offset >= numberOfBytes { throw Exception.REASON(code: 25, incomplete: true, message: "Missing end of string at end of buffer") }
                    
                    switch buffer[offset] {
                    case ASCII_DOUBLE_QUOTES, ASCII_BACKWARD_SLASH, ASCII_FOREWARD_SLASH: strbuf.append(buffer[offset])
                    case ASCII_b: strbuf.append(ASCII_BACKSPACE)
                    case ASCII_f: strbuf.append(ASCII_FORMFEED)
                    case ASCII_n: strbuf.append(ASCII_NEWLINE)
                    case ASCII_r: strbuf.append(ASCII_CARRIAGE_RETURN)
                    case ASCII_t: strbuf.append(ASCII_TAB)
                    case ASCII_u:
                        strbuf.append(buffer[offset])
                        offset += 1
                        if offset >= numberOfBytes { throw Exception.REASON(code: 26, incomplete: true, message: "Missing second byte after \\u in string") }
                        strbuf.append(buffer[offset])
                        offset += 1
                        if offset >= numberOfBytes { throw Exception.REASON(code: 27, incomplete: true, message: "Missing third byte after \\u in string") }
                        strbuf.append(buffer[offset])
                        offset += 1
                        if offset >= numberOfBytes { throw Exception.REASON(code: 28, incomplete: true, message: "Missing fourth byte after \\u in string") }
                        strbuf.append(buffer[offset])
                    default:
                        throw Exception.REASON(code: 29, incomplete: false, message: "Illegal character after \\ in string")
                    }
                    
                } else {
                    
                    strbuf.append(buffer[offset])
                }
            }
            
            offset += 1
            if offset >= numberOfBytes { throw Exception.REASON(code: 30, incomplete: true, message: "Missing end of string at end of buffer") }
        }
        
        if let str: String = String(bytes: strbuf, encoding: NSUTF8StringEncoding) {
            return VJson(str)
        } else {
            throw Exception.REASON(code: 31, incomplete: false, message: "NSUTF8StringEncoding conversion failed at offset \(offset - 1)")
        }

    }
    
    private static func readNumber(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {

        var numbuf = Array<UInt8>()
        
        // Sign
        if buffer[offset] == ASCII_MINUS {
            numbuf.append(buffer[offset])
            offset += 1
            if offset >= numberOfBytes { throw Exception.REASON(code: 32, incomplete: true, message: "Missing number at end of buffer") }
        }
        
        // First digit series
        if buffer[offset].isAsciiNumber {
            while buffer[offset].isAsciiNumber {
                numbuf.append(buffer[offset])
                offset += 1
                // If the original string is a fraction, it could end right after the number
                if offset >= numberOfBytes {
                    if let numstr = String(bytes: numbuf, encoding: NSUTF8StringEncoding) {
                        if let double = toDouble(numstr) {
                            return VJson(double)
                        } else {
                            throw Exception.REASON(code: 33, incomplete: false, message: "Could not convert to double at end of buffer") // Probably impossible
                        }
                    } else {
                        throw Exception.REASON(code: 34, incomplete: false, message: "NSUTF8StringEncoding conversion failed at end of buffer")
                    }
                }
            }
        } else {
            throw Exception.REASON(code: 35, incomplete: false, message: "Illegal character in number at offset \(offset)")
        }
        
        // Fraction
        if buffer[offset] == ASCII_DOT {
            numbuf.append(buffer[offset])
            offset += 1
            if offset >= numberOfBytes { throw Exception.REASON(code: 36, incomplete: true, message: "Missing digits (expecting fraction) at offset \(offset - 1)") }
            if buffer[offset].isAsciiNumber {
                while buffer[offset].isAsciiNumber {
                    numbuf.append(buffer[offset])
                    offset += 1
                    // If the original string is a fraction, it could end right after the number
                    if offset >= numberOfBytes {
                        if let numstr = String(bytes: numbuf, encoding: NSUTF8StringEncoding) {
                            if let double = toDouble(numstr) {
                                return VJson(double)
                            } else {
                                throw Exception.REASON(code: 37, incomplete: false, message: "Could not convert to double at end of buffer") // Probably impossible
                            }
                        } else {
                            throw Exception.REASON(code: 38, incomplete: false, message: "NSUTF8StringEncoding conversion failed at end of buffer")
                        }
                    }
                }
            } else {
                throw Exception.REASON(code: 39, incomplete: false, message: "Illegal character in fraction at offset \(offset)")
            }
        }
        
        // Mantissa
        if buffer[offset] == ASCII_e || buffer[offset] == ASCII_E {
            numbuf.append(buffer[offset])
            offset += 1
            if offset >= numberOfBytes { throw Exception.REASON(code: 40, incomplete: true, message: "Missing mantissa at buffer end") }
            if buffer[offset] == ASCII_MINUS || buffer[offset] == ASCII_PLUS {
                numbuf.append(buffer[offset])
                offset += 1
                if offset >= numberOfBytes { throw Exception.REASON(code: 41, incomplete: true, message: "Missing mantissa at buffer end") }
            }
            if buffer[offset].isAsciiNumber {
                while buffer[offset].isAsciiNumber {
                    numbuf.append(buffer[offset])
                    offset += 1
                    if offset >= numberOfBytes { break }
                }
            } else {
                throw Exception.REASON(code: 42, incomplete: false, message: "Illegal character in mantissa at offset \(offset)")
            }
        }
        
        // Number completed
        
        if let numstr = String(bytes: numbuf, encoding: NSUTF8StringEncoding) {
            return VJson((toDouble(numstr) ?? Double(0.0)))
        } else {
            throw Exception.REASON(code: 43, incomplete: false, message: "NSUTF8StringEncoding conversion failed for number ending at offset \(offset - 1)")
        }
        
    }
    
    private static func readArray(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {

        skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        if offset >= numberOfBytes { throw Exception.REASON(code: 44, incomplete: true, message: "Missing array end at end of buffer") }
        

        let result = VJson(type: .ARRAY, name: nil)

        
        // Index points at value or end-of-array bracket
        
        if buffer[offset] == ASCII_SQUARE_BRACKET_CLOSE {
            offset += 1
            return result
        }

        
        // The offset should point at a value

        while offset < numberOfBytes {
            
            let value = try readValue(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
            // Value received, walk to the next "]" or "," or end of json
            
            skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
            if offset >= numberOfBytes { throw Exception.REASON(code: 45, incomplete: true, message: "Missing array end at end of buffer") }
            
            if buffer[offset] == ASCII_COMMA {
                result.append(value)
                offset += 1
            } else if buffer[offset] == ASCII_SQUARE_BRACKET_CLOSE {
                offset += 1
                result.append(value)
                return result
            } else {
                throw Exception.REASON(code: 58, incomplete: false, message: "Expected comma or end-of-array bracket")
            }
        }
        
        throw Exception.REASON(code: 46, incomplete: true, message: "Missing array end at end of buffer")
    }


    // The value should never return an .ERROR type. If an error occured it should be reported through the errorString and errorReason.
    
    private static func readValue(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {

        skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        if offset >= numberOfBytes { throw Exception.REASON(code: 47, incomplete: true, message: "Missing value at end of buffer") }
            
        
        // index points at non-whitespace
            
        var val: VJson
        
        switch buffer[offset] {
        
        case ASCII_BRACE_OPEN:
            offset += 1
            val = try readObject(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        case ASCII_SQUARE_BRACKET_OPEN:
            offset += 1
            val = try readArray(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        case ASCII_DOUBLE_QUOTES:
            offset += 1
            val = try readString(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        case ASCII_MINUS:
            val = try readNumber(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
        case ASCII_0...ASCII_9:
            val = try readNumber(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        case ASCII_n:
            offset += 1
            val = try readNull(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        case ASCII_f:
            offset += 1
            val = try readFalse(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        case ASCII_t:
            offset += 1
            val = try readTrue(buffer, numberOfBytes: numberOfBytes, offset: &offset)
        
        default: throw Exception.REASON(code: 48, incomplete: false, message: "Illegal character at start of value at offset \(offset)")
        }
        
        return val
    }
   
    private static func readObject(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) throws -> VJson {

        skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)

        if offset >= numberOfBytes { throw Exception.REASON(code: 49, incomplete: true, message: "Missing object end at end of buffer") }
        
        
        // Result object
        
        let result = VJson(type: .OBJECT, name: nil)
        
        
        // Index points at non-whitespace
        
        if buffer[offset] == ASCII_BRACE_CLOSE {
            offset += 1
            return result
        }
        
        
        // Add name/value pairs
        
        while offset < numberOfBytes {
            
            
            // The offset should point at "
            
            var name: String
            
            if buffer[offset] == ASCII_DOUBLE_QUOTES {
            
                offset += 1
                let str = try readString(buffer, numberOfBytes: numberOfBytes, offset: &offset)
                
                if str.type == .STRING {
                    name = str.string!
                } else {
                    throw Exception.REASON(code: 50, incomplete: false, message: "Programming error")
                }
                
            } else {
                throw Exception.REASON(code: 51, incomplete: false, message: "Expected double quotes of name in name/value pair at offset \(offset)")
            }
            
            
            // The colon is next

            skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
            if offset >= numberOfBytes { throw Exception.REASON(code: 52, incomplete: true, message: "Missing ':' in name/value pair at offset \(offset - 1)") }
            
            if buffer[offset] != ASCII_COLON {
                throw Exception.REASON(code: 53, incomplete: false, message: "Missing ':' in name/value pair at offset \(offset)")
            }
            
            offset += 1 // Consume the ":"
            
            
            // A value should be next
            
            skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
            if offset >= numberOfBytes { throw Exception.REASON(code: 54, incomplete: true, message: "Missing value of name/value pair at buffer end") }
            
            let val = try readValue(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
            
            // Add the name/value pair to this object
            
            val.name = name
            result.add(val, forName: name)
            
            
            // A comma or brace end should be next
            
            skipWhitespaces(buffer, numberOfBytes: numberOfBytes, offset: &offset)
            
            if offset >= numberOfBytes { throw Exception.REASON(code: 55, incomplete: true, message: "Missing end of object at buffer end") }
            
            if buffer[offset] == ASCII_BRACE_CLOSE {
                offset += 1
                return result
            }
                
            if buffer[offset] != ASCII_COMMA { throw Exception.REASON(code: 56, incomplete: false, message: "Unexpected character, expected comma at offset \(offset)") }
            
            offset += 1
            
        }
        
        throw Exception.REASON(code: 57, incomplete: true, message: "Missing name in name/value pair of object at buffer end")
    }
    
    private static func skipWhitespaces(buffer: UnsafePointer<UInt8>, numberOfBytes: Int, inout offset: Int) {

        if offset >= numberOfBytes { return }
        while buffer[offset].isAsciiWhitespace {
            offset += 1
            if offset >= numberOfBytes { break }
        }
    }
}