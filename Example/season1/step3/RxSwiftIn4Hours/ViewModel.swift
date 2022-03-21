//
//  ViewModel.swift
//  RxSwiftIn4Hours
//
//  Created by Sang hun Lee on 2022/03/21.
//  Copyright © 2022 n.code. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel: CommonViewModel {
    var disposeBag = DisposeBag()
    
    let input = Input()
    let output = Output()
    
    struct Input {
        let idInputText = PublishSubject<String>()
        let pwInputText = PublishSubject<String>()
    }
    
    struct Output {
        // Subject 나중에 데이터 변경이 발생하면 외부에서 주입이 가능, Observe도 가능
        // 중간에 한 번 error가 나면 subscribe 하고 있는 모든 곳에 error 전달
        let idValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let pwValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let isButtonEnable: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    }
    
    func transform() {
        input.idInputText
            .map(checkEmailValid)
            .bind(to: output.idValid)
            .disposed(by: disposeBag)
        
        input.pwInputText
            .map(checkPasswordValid)
            .bind(to: output.pwValid)
            .disposed(by: disposeBag)
        
        // 합성
        // zip: 두 개 데이터가 모두 생성이 되었을 때 그제서야 next 전달
        // merge: 두 개의 스트림을 받아 순서대로 합쳐서 전달
        Observable.combineLatest(output.idValid, output.pwValid, resultSelector: { $0 && $1 })
            .bind(to: output.isButtonEnable)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Logic
    
    private func checkEmailValid(email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z.]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        if let _ = regex?.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) {
            return true
        }
        return false
    }

    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
    
    init() {
        print("===ViewModel Init===")
        transform()
    }
    
    deinit {
        print("===ViewModel Deinit===")
    }
}
