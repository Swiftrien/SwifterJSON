// =====================================================================================================================
//
//  File:       Code.swift
//  Project:    VJson
//
//  Version:    0.16.0
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterjson/swifterjson.html
//  Git:        https://github.com/Balancingrock/VJson
//
//  Copyright:  (c) 2014-2019 Marinus van der Lugt, All rights reserved.
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
//  I strongly believe that voluntarism is the way for societies to function optimally. So you can pay whatever you
//  think our code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  wishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to check the website http://www.balancingrock.nl before payment)
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
// History
//
// 0.16.0 - Removed warnings for Swift 5
// 0.15.6 - Improved handling of top level named tems, now supports fragments at all levels.
// 0.14.0 - Added name to top level item (if the top level item has a name)
// 0.10.8 - Split off from VJson.swift
// =====================================================================================================================

import Foundation


public extension VJson {
    
    
    /// Returns the JSON code that represents the hierarchy of this item. Will return a fragment if self has a name.
    
    var code: String {
        
        if let name = name {
            return "\"\(name)\":\(_code)"
        } else {
            return _code
        }
    }
    
    
    /// Returns the JSON code that represents the hierarchy of this item without a leading name.

    fileprivate var _code: String {
        
        // Get rid of subscript generated objects that no longer serve a purpose
        
        self.removeEmptySubscriptObjects()
        
        var str = ""
        
        switch type {
            
        case .null:
            
            str += "null"
            
            
        case .bool:
            
            if bool == nil {
                str += "null"
            } else {
                str += "\(self.bool!)"
            }
            
            
        case .number:
            
            if number == nil {
                str += "null"
            } else {
                str += "\(self.number!)"
            }
            
            
        case .string:
            
            if string == nil {
                str += "null"
            } else {
                str += "\"\(self.string!)\""
            }
            
            
        case .object:
            
            str += "{"
            
            for i in 0 ..< (children?.count ?? 0) {
                if let child = children?.items[i], let name = child.name {
                    if i != (children?.count ?? 0) - 1 {
                        str += "\"\(name)\":\(child._code),"
                    } else {
                        str += "\"\(name)\":\(child._code)"
                    }
                } else {
                    str += "*** ERROR ***"
                }
            }
            
            str += "}"
            
            
        case .array:
            
            str += "["
            
            for i in 0 ..< (children?.count ?? 0) {
                if let child = children?.items[i] {
                    if i != children!.count - 1 {
                        str += "\(child._code),"
                    } else {
                        str += "\(child._code)"
                    }
                } else {
                    str += "*** ERROR ***"
                }
            }
            
            str += "]"
        }
        
        return str
    }
}
