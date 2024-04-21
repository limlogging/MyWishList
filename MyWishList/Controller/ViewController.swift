//
//  ViewController.swift
//  MyWishList
//
//  Created by imhs on 4/15/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var currentProduct: Product?    //현재 상품이 저장되는 변수
    //코어데이터 사용을 위한 설정
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    @IBOutlet weak var productScrollView: UIScrollView!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    // MARK: - 위시리스트 보기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getData(completionHandler: { product in
            self.currentProduct = product
        })
        
        self.productScrollView.refreshControl = UIRefreshControl()
        self.productScrollView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    //새로고침 추가 
    @objc func refresh() {
        self.getData { product in
            self.currentProduct = product
            DispatchQueue.main.async {
                self.productScrollView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - 다른 상품 보기 버튼 선택
    @IBAction func otherProductButtonTapped(_ sender: UIButton) {
        self.getData(completionHandler: { product in
            self.currentProduct = product
        })
    }
    
    // MARK: - 위시 리스트 담기 버튼 선택
    @IBAction func addToWishListButtonTapped(_ sender: UIButton) {
        guard let product = self.currentProduct else { return }
        
        // 위시리스트 담기 전 중복 확인
        if checkId(String(product.id)) {
            let alertController = UIAlertController(title: "중복 확인", message: "이미 위시 리스트에 포함되어 있습니다.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "확인", style: .cancel, handler: { _ in return })
            
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        } else {
            //코어데이터에 저장
            guard let context = self.persistentContainer?.viewContext else { return }
            let myWishList = MyWishList(context: context)
            
            myWishList.id = String(product.id)
            myWishList.title = product.title
            myWishList.price = String(product.price)
            //저장
            try? context.save()
            
            let alertController = UIAlertController(title: "위시 리스트 담기", message: "해당 상품을 위시 리스트에 담았습니다.", preferredStyle: .alert)
            let addToWishList = UIAlertAction(title: "확인", style: .default, handler: { _ in return })
            
            alertController.addAction(addToWishList)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - 중복 ID 체크
    func checkId(_ id: String) -> Bool {
        //true 중복, false 중복아님
        guard let context = self.persistentContainer?.viewContext else { return true }
        let request = MyWishList.fetchRequest()
        guard let myWishList = try? context.fetch(request) else { return true }
        
        if myWishList.filter({ $0.id == id}).count != 0 {
            //중복
            return true
        } else {
            //중복 아님
            return false
        }
    }
    
    //비동기적으로 실행되는 urlsession이 끝나면 데이터를 저장하기 위한 콜백함수 사용
    func getData(completionHandler: @escaping (Product?) -> Void) {
        let productID: Int = Int.random(in: 1...100)
        
        //1. url 구조체 만들어주기
        guard let url = URL(string: "https://dummyjson.com/products/\(productID)") else {
            print("URL 주소를 불러오는데 실패했습니다.")
            completionHandler(nil)
            return
        }
        print("url: \(url)")
        
        //2. session 만들기
        let session = URLSession.shared
        
        //3. 비동기적으로 데이터 요청 테스크 생성
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("Error: \(error!)")
                completionHandler(nil)
                return
            }
            guard let data = data else {
                completionHandler(nil)
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                //에러 등 기타 처리
                return
            }
            
            do {
                let product = try JSONDecoder().decode(Product.self, from: data)
                completionHandler(product)
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                let dollarPriceText = "$ " + (formatter.string(from: product.price as NSNumber) ?? "")
                let wonPriceText = "￦ " + (formatter.string(from: product.price * 1400 as NSNumber) ?? "")
                
                DispatchQueue.main.async {
                    self.productPriceLabel.text = "\(dollarPriceText) (\(wonPriceText))"
                    self.productTitleLabel.text = product.title
                    self.productDescriptionLabel.text = product.description
                }
                                
                //이미지 작업과 같은 내용은 오래걸리기때문에 새로 요청
                //연속된 요청을 해야할때 복잡한 코드가 됨
                if let thumbnailURL = URL(string: product.thumbnail) {
                    let imageRequest = URLRequest(url: thumbnailURL)
                    let imageTask = URLSession.shared.dataTask(with: imageRequest) { data, response, error in
                        if let data = data {
                            //화면을 다시그릴때는 메인큐에서 작업
                            DispatchQueue.main.async {
                                let image = UIImage(data: data)
                                self.productImageView.image = image
                            }
                        }
                    }
                    imageTask.resume()
                }
            } catch {
                print("Decode Error: \(error)")
            }
        }
        //4. 작업 시작
        task.resume()
    }
}

