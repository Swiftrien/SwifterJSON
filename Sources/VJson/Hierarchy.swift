// =====================================================================================================================
//
//  File:       Hierarchy.swift
//  Project:    VJson
//
//  Version:    0.10.8
//
//  Author:     Marinus van der Lugt
//  Company:    http://balancingrock.nl
//  Website:    http://swiftfire.nl/projects/swifterjson/swifterjson.html
//  Git:        https://github.com/Balancingrock/VJson
//
//  Copyright:  (c) 2014-2017 Marinus van der Lugt, All rights reserved.
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
// 0.10.8  - Split off from VJson.swift
// =====================================================================================================================

import Foundation


public extension VJson {
    
    
    /// Looks for an item in the hierachy.
    ///
    /// - Parameters:
    ///   - at: An array of strings describing the path at which the item should exist. Note that integer indexing will convert the string into an index before using. Hence a path of ["12"] can refer to the item at index 12 as well as the item for name "12".
    ///
    /// - Returns: the item at the given path if it exists. Otherwise nil.
    
    public func item(at path: [String]) -> VJson? {
        
        if path.count == 0 {
            
            return self
            
        } else {
            
            switch self.type {
                
            case .array:
                
                let i = (path[0] as NSString).integerValue
                
                if i >= self.nofChildren { return nil }
                
                var reducedPath = path
                reducedPath.removeFirst()
                
                return children?.items[i].item(at: reducedPath)
                
                
            case .object:
                
                for child in children?.items ?? [] {
                    if child.name == nil { return nil } // Should not be possible
                    if child.name == path[0] {
                        
                        var reducedPath = path
                        reducedPath.removeFirst()
                        
                        return child.item(at: reducedPath)
                    }
                }
                return nil
                
                
            default: return nil
            }
        }
    }
    
    /// Looks for a specific item in the hierachy.
    ///
    /// - Parameters:
    ///   - at: A set of strings describing the path at which the item should exist. Note that integer indexing will convert the string into an index before using. Hence a path of "12" can refer to the item at index 12 as well as the item for name "12".
    ///
    /// - Returns: the item at the given path if it exists. Otherwise nil.
    
    public func item(at path: String ...) -> VJson? {
        return item(at: path)
    }
    
    
    /// Looks for a specific item in the hierachy.
    ///
    /// - Parameters:
    ///   - of: The JSON TYPE of object to look for.
    ///   - at path: An array of strings describing the path at which the item should exist. Note that integer indexing will convert the string into an index before using. Hence a path of ["12"] can refer to the item at index 12 as well as the item for name "12".
    ///
    /// - Returns: the item at the given path if it exists and is of the given type. Otherwise nil.
    
    public func item(of type: JType, at path: [String]) -> VJson? {
        
        if let item = item(at: path), item.type == type { return item }
        
        return nil
    }
    
    
    /// Looks for a specific item in the hierachy.
    ///
    /// - Parameters:
    ///   - of: The JSON TYPE of object to look for.
    ///   - at path: A set of strings describing the path at which the item should exist. Note that integer indexing will convert the string into an index before using. Hence a path of "12" can refer to the item at index 12 as well as the item for name "12".
    ///
    /// - Returns: the item at the given path if it exists and is of the given type. Otherwise nil.
    
    public func item(of: JType, at path: String ...) -> VJson? {
        return item(of: of, at: path)
    }
}