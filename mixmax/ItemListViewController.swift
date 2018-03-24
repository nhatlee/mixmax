//
//  ItemListViewController.swift
//  mixmax
//
//  Created by Vinh Nguyen on 4/25/17.
//  Copyright © 2017 Vinh Nguyen. All rights reserved.
//

import UIKit
import RxSwift

class ItemListViewController: UIViewController {
    
    @IBOutlet weak var itemListCollectionView: UICollectionView!
    
    fileprivate var items = [Item]()
    
    var item = Item()
    
    private let cloudService = CloudService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNibs()
        let vc = self.slideMenuController()?.rightViewController as! MenuViewController
        vc.currentIndex.asObservable().subscribe(onNext: { cloudType in
            print("@@Get cloudn")
            self.cloudService.callItems(from: self.item, cloudType: cloudType) { [weak self] (items) in
                self?.items = items
                self?.itemListCollectionView.reloadData()
            }
        })
    }
    
    @IBAction func closeIButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func prepareNibs() {
        itemListCollectionView.register(UINib(nibName: "ItemListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemListCollectionViewCell")
    }
    
}

extension ItemListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListCollectionViewCell",
                                                      for: indexPath) as! ItemListCollectionViewCell
        let item = items[indexPath.row]
        cell.configure(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if let url = item.track.url {
            self.item = item
            let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
            if let playerViewController = storyboard.instantiateViewController(withIdentifier :"PlayerViewController") as? PlayerViewController {
                playerViewController.item = item
                present(playerViewController, animated: true)
            }
            
            return
        }
        
        let storyboard = UIStoryboard(name: "ItemListViewController", bundle: nil)
        if let itemListViewController = storyboard.instantiateViewController(withIdentifier :"ItemListViewController") as? ItemListViewController {
            let item = items[indexPath.row]
            itemListViewController.item = item
            navigationController?.pushViewController(itemListViewController, animated: true)
        }
    }
}
