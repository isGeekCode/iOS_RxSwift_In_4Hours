//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class ViewController: UIViewController {
    let viewModel = ViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindInput()
        bindOutput()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        disposeBag = DisposeBag()
//    }

    // MARK: - IBOutler

    @IBOutlet var idField: UITextField!
    @IBOutlet var pwField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var idValidView: UIView!
    @IBOutlet var pwValidView: UIView!

    // MARK: - Bind UI
    
    func invert(_ bool: Bool) -> Bool { return !bool }

    private func bindInput() {
        // input: id, pw 입력
        idField.rx.text.orEmpty
            .asDriver()
            .drive(viewModel.input.idInputText)
            .disposed(by: disposeBag)

        pwField.rx.text.orEmpty
            .asDriver()
            .drive(viewModel.input.pwInputText)
            .disposed(by: disposeBag)
    }
    
    // drive 메인스레드로 돌리는 역할 
    func bindOutput() {
        // output: 불릿 뷰, 버튼
        viewModel.output.idValid
            .observeOn(MainScheduler.instance)
            .bind(to: self.idValidView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.pwValid
            .observeOn(MainScheduler.instance)
            .bind(to: self.pwValidView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.isButtonEnable
            .observeOn(MainScheduler.instance)
            .bind(to: self.loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
