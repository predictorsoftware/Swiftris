//
//  Array2D.swift
//  Swiftris
//
//  Created by Gru on 03/09/15.
//  Copyright (c) 2015 GruTech. All rights reserved.
//
//
// NOTES:
//     'And Array We Go'
// (1) Defining class, 'Array2D'.  Generic arrays in Swift are actually of type 'struct',
//     not 'class' but we need a class in this case since class objects are passed by
//     reference, whereas structures are passed by value (copied).
//     This game logic will require a single copy of this data structure to persist
//     across the entire.

class Array2D<T> {          // (1)

    let columns:    Int
    let rows:       Int

    var array: Array<T?>    // (2)  Declare a Swift array

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows    = rows

        // (3)
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }

    // (4)
    subscript(column: Int, row: Int) -> T? {
        // 'getter'
        get {
            return array[(row * columns) + column]
        }

        // 'setter'
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}
