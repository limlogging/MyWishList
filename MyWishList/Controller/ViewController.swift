//
//  ViewController.swift
//  MyWishList
//
//  Created by imhs on 4/15/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    // currentProduct가 set되면, imageView. titleLabel, descriptionLabel, priceLabel에 각각 적절한 값을 지정합니다.
    private var currentProduct: ProductsManager? = nil {
        didSet {
            guard let currentProduct = self.currentProduct else { return }
            
            //메인 스레드에서 UI 업데이트를 수행
            DispatchQueue.main.async {
                self.productImageView.image = nil
                self.productTitleLabel.text = currentProduct.title
                self.productDescriptionLabel.text = currentProduct.description
                self.productPriceLabel.text = "\(currentProduct.price)$"
            }
            
            // 백그라운드 스레드에서 제품의 섬네일 이미지를 비동기적으로 가져오기
            DispatchQueue.global().async { [weak self] in
                // 제품의 섬네일 이미지 데이터를 가져와 UIImage로 변환
                if let thumbnailURL = URL(string: currentProduct.thumbnail), // 문자열을 URL로 변환
                   let data = try? Data(contentsOf: thumbnailURL), // URL로 데이터 가져오기
                    let image = UIImage(data: data) {
                    
                    // 가져온 이미지를 메인 스레드에서 productImageView에 설정하여 이미지 출력
                    DispatchQueue.main.async {
                        self?.productImageView.image = image
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    // MARK: - 위시리스트 보기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getData()
    }
    
    // MARK: - 다른 상품 보기 버튼 선택
    @IBAction func otherProductButtonTapped(_ sender: UIButton) {
        self.getData()
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
    
    func getData() {
        let productID: Int = Int.random(in: 1...100)
   
        if let url = URL(string: "https://dummyjson.com/products/\(productID)") {
            print("url: \(url)")
            
            //URLSessionDataTask를 사용하여 비동기적으로 데이터 요청
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        let product = try JSONDecoder().decode(ProductsManager.self, from: data)
                        self.currentProduct = product   //데이터 설정
                        
                    } catch {
                        print("Decode Error: \(error)")
                    }
                }
            }
            task.resume()
        }
    }
}

