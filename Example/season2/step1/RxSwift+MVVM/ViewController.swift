//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

// 유사 Observable
//class Observable<T> {
//    private let task: (@escaping (T) -> ()) -> ()
//
//    init(task: @escaping (@escaping (T) -> ()) -> ()) {
//        self.task = task
//    }
//
//    func subscribe(_ f: @escaping (T) -> ()) {
//        task(f)
//    }
//}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // Observable의 생명주기
    // 1. Create
    // 2. Subscribe
    // 3. onNext
    // ---- End ----
    // 4. onCompleted / onError
    // 5. Disposed
    
    // completionHandler를 옵셔널 함수로 했을 때 escaping이 default: (String?) -> ())?
    // 비동기로 생기는 return 값을 받을 수 있을 지 생각 - utility: PromiseKit, Bolt, RxSwift
    // 비동기로 생기는 결과값을 completion이 아닌, 나중에 return 값으로 전달하기 위해 만들어진 유틸리티
    // Observable 형태로 감싸서 return 하면 나중에 생기는 데이터
    // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
    func downloadJson(_ url: String) -> Observable<String?> {
        return Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emitter.onNext(json)
                }
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create() {
                task.cancel()
            }
        }
        
        
//        return Observable() { f in
        
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted()
//                }
//            }
//            // Observable이 create가 끝날 때는 Disposables 항시 리턴
//            return Disposables.create()
//        }
    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    // 2. Observable로 오는 데이터를 받아서 처리하는 방법
    // subscribe시 3유형의 이벤트 발생 - next, complete, error(여러가지 옵션)
    // 순환참조의 문제 발생 - 디버깅 방식
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
    
        _ = downloadJson(MEMBER_LIST_URL)
//            .subscribe { json in
//                self.editView.text = json
//                self.setVisibleWithAnimation(self.activityIndicator, false)
//            }
            .debug()
            .subscribe { [weak self] (event) in
                switch event {
                case .next(let json):
                    DispatchQueue.main.async {
                        self?.editView.text = json
                        self?.setVisibleWithAnimation(self?.activityIndicator, false)
                    }
                case .error:
                    break
                case .completed:
                    break
                }
            }
    }
}
