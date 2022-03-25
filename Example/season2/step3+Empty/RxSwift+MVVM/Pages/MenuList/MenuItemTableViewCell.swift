//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var count: UILabel!
    @IBOutlet var price: UILabel!

    var onChange: ((Int) -> ())?
    
    @IBAction func onIncreaseCount() {
        onChange?(+1)
    }

    @IBAction func onDecreaseCount() {
        onChange?(-1)
    }
    
    // func setViewModel(viewModel: CellViewModel) { viewModel.title.bind(title.rx.text)... }
    
//    override func prepareForReuse() {
//        disposeBag = DisposeBag()
//    }
    
    
}
