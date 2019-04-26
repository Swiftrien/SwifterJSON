// =====================================================================================================================
//
//  File:       Sequence.swift
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
// 0.16.0 - Updated header
// 0.15.0 - Harmonized names, now uses 'item' or 'items' for items contained in OBJECTs instead of 'child'
//          or 'children'. The name 'child' or 'children' is now used exclusively for operations transcending
//          OBJECTs or ARRAYs.
//          General overhaul of comments and documentation.
// 0.10.8 - Split off from VJson.swift
// =====================================================================================================================

import Foundation


extension VJson: Sequence {
    
    
    /// The generator for the VJson object.
    
    public struct MyGenerator: IteratorProtocol {
        
        public typealias Element = VJson
        
        // The object for which the generator generates
        private let source: VJson
        
        // The objects already delivered through the generator
        private var sent: Array<VJson> = []
        
        fileprivate init(source: VJson) {
            self.source = source
        }
        
        /// Returns the next subitem
        ///
        /// - Returns: The next subitem.
        
        mutating public func next() -> Element? {
            
            // Only when the source has values to deliver
            if let values = source.children?.items {
                
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
    
    
    /// defines the struct used as the iterator
    
    public typealias Iterator = MyGenerator
    
    
    /// Creates an iterator
    ///
    /// - Returns: A new iterator.
    
    public func makeIterator() -> Iterator { return MyGenerator(source: self) }
}
