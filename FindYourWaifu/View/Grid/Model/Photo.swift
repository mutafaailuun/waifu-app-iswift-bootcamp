//
//  Model.swift
//  FindYourWaifu
//
//  Created by Jaliel on 10/02/24.
//

import Foundation

struct Photo: Hashable, Decodable {
    let anime: String
    let name: String
    let image: String
}
