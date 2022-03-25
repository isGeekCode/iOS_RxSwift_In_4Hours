//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by Sang hun Lee on 2022/03/24.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    
    // 만약 cell 마다 viewModel을 구성하여 활용한다고 한다면
    // var cellViewModel: [CellViewModel] = []
    
    // input 하나를 갈래로 3가지의 스트림 구성
    // 화면에 보여지는 요소들을 관리 - 뷰는 변화시 구독하여 변동
    // var menuObservable = BehaviorSubject<[Menu]>(value: [])
    // 에러가 나도 끊어지지 않음
    var menuObservable = BehaviorRelay<[Menu]>(value: [])
    
    lazy var itemsCount = menuObservable.map { menus in
        menus
        .map { $0.count }
        .reduce(0, +)
    }
    
    lazy var totalPrice = menuObservable.map { menus in
        menus
        .map { $0.price * $0.count }
        .reduce(0, +)
    }
    
    // Subject - PublishSubject, BehaviorSubject
    // Observable처럼 subcribe를 통해 값을 받을 수도 있지만,
    // 외부에서 값을 통제하는 것이 가능
    
    init() {
//        let menus: [Menu] = [
//            Menu(id: 0, name: "오징어튀김", price: 600, count: 0),
//            Menu(id: 1, name: "야채튀김", price: 600, count: 0),
//            Menu(id: 2, name: "고구마튀김", price: 600, count: 0),
//            Menu(id: 3, name: "새우튀김", price: 1000, count: 0),
//            Menu(id: 4, name: "닭튀김", price: 1000, count: 0),
//            Menu(id: 5, name: "계란튀김", price: 600, count: 0),
//            Menu(id: 6, name: "핫도그", price: 1500, count: 0)
//        ]
//        menuObservable.onNext(menus)
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try!
                        JSONDecoder().decode(Response.self, from: data)
                return response.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { (index, item) in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .bind(to: menuObservable)
    }
    
    func clearAllItemSelections() {
        _ = menuObservable
            .map { menus in
                return menus.map { old in
                    Menu(id: old.id,
                         name: old.name,
                         price: old.price,
                         count: 0)
                }
            }
            .take(1)
            .subscribe {
                self.menuObservable.accept($0)
            }
    }
    
    func changeCount(item: Menu, increase: Int) {
        _ = menuObservable
            .map { menus in
                menus.map { old in
                    if old.id == item.id {
                        return Menu(
                            id: old.id,
                            name: old.name,
                            price: old.price,
                            count: max(old.count + increase, 0))
                    } else {
                        return Menu(
                            id: old.id,
                            name: old.name,
                            price: old.price,
                            count: old.count)
                    }
                }
            }
            .take(1)
            .subscribe {
                self.menuObservable.accept($0)
            }
    }
    
    func onOrder() {
        
    }
}
