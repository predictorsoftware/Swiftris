//
//  File.swift
//  Swiftris
//
//  Created by Gru on 03/09/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//
// 'Block Party'
//
// NOTES:

import SpriteKit

// #1
 let NumberOfColors: UInt32 = 6

// #2
 enum BlockColor: Int, Printable {

// #3
     case Blue = 0, Orange, Purple, Red, Teal, Yellow

// #4
     var spriteName: String {
         switch self {
         case .Blue:
             return "blue"
         case .Orange:
           return "orange"
         case .Purple:
           return "purple"
         case .Red:
             return "red"
         case .Teal:
           return "teal"
         case .Yellow:
             return "yellow"
         }
     }

// #5
     var description: String {
         return self.spriteName
     }

// #6
     static func random() -> BlockColor {
         return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
     }
 }

// #1A
class Block: Hashable, Printable {
    // #2B
    // Constants
    let color: BlockColor

    // #3C
    // Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?

    // #4D
    var spriteName: String {
        return color.spriteName
    }

    // #5E
    var hashValue: Int {
        return self.column ^ self.row
    }

    // #6F
    var description: String {
        return "\(color): [\(column), \(row)]"
    }

    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

// #7G
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}