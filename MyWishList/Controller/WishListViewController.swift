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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishListTableViewCell", for: indexPath) as? WishListTableViewCell
                
        let id = "[" + (productList[indexPath.row].id ?? "") + "]"
        let title = productList[indexPath.row].title
        let price = productList[indexPath.row].price
        
        cell?.productIdLabel.text = id
        cell?.productTitleLabel.text = title
        cell?.productPriceLabel.text = price
        
        return cell ?? UITableViewCell()
        
    }
}
