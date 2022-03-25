//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by Sang hun Lee on 2022/03/24.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
// Model: View를 위한 Model 
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(
            id: id,
            name: item.name,
            price: item.price,
            count: 0)
    }
}
