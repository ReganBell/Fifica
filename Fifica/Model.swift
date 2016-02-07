//
//  Model.swift
//  Fifica
//
//  Created by Regan Bell on 2/1/16.
//  Copyright © 2016 Ben Griswold. All rights reserved.
//

import Foundation

struct User {
    let name: String
    let leagues: [League]
}

struct StubLeague {
    let name: String
    let users: Int
}

struct League {
    let users: Set<String>
    let name: String
}