//
//  WishListViewController.swift
//  MyWishList
//
//  Created by imhs on 4/16/24.
//

import UIKit
import CoreData

class WishListViewController: UIViewController {
    // MARK: - 코어데이터를 사용하기 위한 설정
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    var productList: [MyWishList] = []
    
    @IBOutlet weak var wishListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wishListTableView.dataSource = self
                
        getCoreData()
    }
    
    // MARK: - CoreData에서 데이터 가져오기
    func getCoreData() {
        guard let context = self.persistentContainer?.viewContext else { return }
    
        let request = MyWishList.fetchRequest()
    
        if let products = try? context.fetch(request) {
            self.productList = products
        }
    }
}

extension WishListViewController: UITableViewDataSource {
    // MARK: - tableView Row 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    // MARK: - row에 들어갈 데이터 선택
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishListTableViewCell", for: indexPath) as? WishListTableViewCell
                
        let id = "[" + (productList[indexPath.row].id ?? "") + "]"
        let title = productList[indexPath.row].title
        //let price = productList[indexPath.row].price
             
        cell?.productIdLabel.text = id
        cell?.productTitleLabel.text = title
        
        if let productPrice = Double(productList[indexPath.row].price ?? "0.0") {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let dollarPriceText = "$ " + (formatter.string(from: productPrice as NSNumber) ?? "")
            let wonPriceText = "￦ " + (formatter.string(from: productPrice * 1400 as NSNumber) ?? "")
            cell?.productPriceLabel.text = "\(dollarPriceText) (\(wonPriceText))"
        }
        
        return cell ?? UITableViewCell()
    }
    
    // MARK: - 삭제 기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = self.persistentContainer?.viewContext else { return }
            
            let request = MyWishList.fetchRequest()
            guard let products = try? context.fetch(request) else { return }
            
            // 선택한 특정 인덱스의 객체를 가져옴
            let productToDelete = products[indexPath.row]
            
            context.delete(productToDelete)
            
            // 변경 사항 저장
            try? context.save()
            
            //CoreData에서 데이터 가져오기
            getCoreData()
            //테이블뷰리로드
            wishListTableView.reloadData()
        }
    }
}
