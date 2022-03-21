//
//  ViewController.swift
//  RxSwiftIn4Hours
//
//  Created by iamchiwon on 21/12/2018.
//  Copyright © 2018 n.code. All rights reserved.
//

import RxSwift
import UIKit

class ViewController: UITableViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // just - 해당 데이터 스트림을 그대로 전달
    // subscribe - 연산자의 사용이 끝나고 나서 사용에 대한 명령
    // 스트림은 error, complete 시 종료
    @IBAction func exJust1() {
        Observable.just("Hello World")
            .subscribe{ event in
                switch event {
                case .next(let str):
                    print(str)
                case .error(let err):
                    break
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    @IBAction func exJust2() {
        Observable.just(["Hello", "World"])
            .subscribe(onNext: { arr in
                print(arr)
            })
            .disposed(by: disposeBag)
    }
    
    func output(_ any: Any) -> () {
        print(any)
    }
    
    // from - 데이터 스트림의 원소를 하나식 onNext
    @IBAction func exFrom1() {
        Observable.from(["RxSwift", "In", 4, "Hours"])
            .subscribe(onNext: output, onError: { err in
                print(err.localizedDescription)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            })
//            .subscribe{ event in
//                switch event {
//                case .next(let str):
//                    print("next: \(str)")
//                    break
//                case .error(let err):
//                    print("error: \(err.localizedDescription)")
//                    break
//                case .completed:
//                    print("completed")
//                    break
//                }
//            }
            .disposed(by: disposeBag)
    }
    
    // map - 스트림 데이터 형식 변환
    @IBAction func exMap1() {
        Observable.just("Hello")
            .map { str in "\(str) RxSwift" }
            .subscribe(onNext: { str in
                print(str)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func exMap2() {
        Observable.from(["with", "곰튀김"])
            .map { $0.count }
            .subscribe(onNext: { str in
                print(str)
            })
            .disposed(by: disposeBag)
    }

    // filter - 스트림에서 원하는 요소만 캐치 
    @IBAction func exFilter() {
        Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
            .filter { $0 % 2 == 0 }
            .subscribe(onNext: { n in
                print(n)
            })
            .disposed(by: disposeBag)
    }

    @IBAction func exMap3() {
        Observable.just("800x600")
            .map { $0.replacingOccurrences(of: "x", with: "/") }
            .map { "https://picsum.photos/\($0)/?random" }
            .map { URL(string: $0) }
            .filter { $0 != nil }
            .map { $0! }
            // subscribe가 되는 순간 시작, 어느 위치던지 해당 스트림의 시작부터 해당 스케쥴러 적용, 처음 받아오는 부분에서 부터 비동기적으로 처리해야할 경우
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
//  원하는 시점, 상황에서 비동기적으로 처리해야할 경우
//            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .map { try Data(contentsOf: $0) }
            .map { UIImage(data: $0) }
            .observeOn(MainScheduler.instance)
            .do(onNext: { image in
                // side effect 처리에 있어서 do
                print(image?.size)
            })
            .subscribe(onNext: { image in
                // side effect
                self.imageView.image = image
            })
            .disposed(by: disposeBag)
    }
}
