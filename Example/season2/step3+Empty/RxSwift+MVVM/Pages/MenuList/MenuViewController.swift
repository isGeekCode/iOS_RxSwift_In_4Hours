//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa // 뷰에 접목

class MenuViewController: UIViewController {
    // MARK: - Life Cycle

    let cellId = "MenuItemTableViewCell"
    let viewModel = MenuListViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.menuObservable
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: cellId, cellType: MenuItemTableViewCell.self)) { index, item, cell in
                cell.title.text = item.name
                cell.price.text = "\(item.price)"
                cell.count.text = "\(item.count)"
                
                // 만약 cell 마다 viewModel을 구성한다고 한다면
                // let cellViewModel = self.viewModel.cellViewModels[index]
                // cell.setViewModel(cellViewModel)
                // title, price, count 등은 cell 내부 setViewModel 안에서 처리
    
                cell.onChange = { [weak self] increase in
                    self?.viewModel.changeCount(item: item, increase: increase)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.itemsCount
            .map { "\($0)" }
            // UI 관련하여 드라이브를 통해서 에러나 가는 경우 디폴트로 바꿔서 처리
            // Main 쓰레드 동작
            .asDriver(onErrorJustReturn: "")
            .drive(itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        Observable.just("경고")
            .flatMap{ self.showAlert($0, "경고 알람이 왔어요") }
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .take(1)
            .subscribe { alert in
                alert.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
            .map { $0.currencyKR() }
            // 타이머 지정
            // .delay(.seconds(3), scheduler: MainScheduler.instance)
            .catchErrorJustReturn("")
            .observeOn(MainScheduler.instance)
            // 순환참조 없이 bind로 해결 가능
//            .subscribe { [weak self] (price) in
//                self?.totalPrice.text = price
//            }
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) -> Observable<UIAlertController> {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
//        execute(after: 3) {
//
//        }
        return Observable.just(alertVC)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
        viewModel.clearAllItemSelections()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
        viewModel.onOrder()
    }
}
