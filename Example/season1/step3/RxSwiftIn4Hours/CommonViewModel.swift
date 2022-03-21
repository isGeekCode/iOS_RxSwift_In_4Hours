//
//  CommonViewModel.swift
//  RxSwiftIn4Hours
//
//  Created by Sang hun Lee on 2022/03/21.
//  Copyright © 2022 n.code. All rights reserved.
//

import Foundation
import RxSwift

protocol CommonViewModel {
    associatedtype Input
    associatedtype Output
    func transform() -> ()
    var disposeBag: DisposeBag { get set }
}
