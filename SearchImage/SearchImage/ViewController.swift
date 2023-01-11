//
//  ViewController.swift
//  SearchImage
//
//  Created by Shantanu Barnawal on 10/1/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    let networkShared = NetworkManager.shared

    var imageEntities: [ImageEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageEntities.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell",
                                               for: indexPath) as! ImageCollectionViewCell
        
        let imageDetail = imageEntities[indexPath.item]
        collectionViewCell.image = nil
        
        let representedIdentifier = imageDetail.id
        collectionViewCell.representedIdentifier = representedIdentifier
        collectionViewCell.activityIndicator.isHidden = false
        collectionViewCell.activityIndicator.startAnimating()

        networkShared.image(imageDetail: imageDetail) { downloadedImage, error in
            var image = UIImage(named: "ImageNotFound")
            if let tempImage = downloadedImage {
                image = tempImage
            }
            DispatchQueue.main.async {
                collectionViewCell.activityIndicator.stopAnimating()
                collectionViewCell.activityIndicator.isHidden = true
                if (collectionViewCell.representedIdentifier == representedIdentifier) {
                    collectionViewCell.image = image
                }
            }
        }        
        return collectionViewCell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewController =
            storyboard?.instantiateViewController(identifier: "detailView") as? DetailViewController
        if let collectionCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            if let detailVC = detailViewController {
                detailVC.image = collectionCell.image
                present(detailVC, animated: true)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width / 3) - 3 ,
                      height: (view.frame.size.width / 3) - 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension ViewController: UISearchBarDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let searchView: UICollectionReusableView =
            collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                            withReuseIdentifier: "SearchBar",
                                                            for: indexPath)
        return searchView
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let input = searchBar.text, !input.isEmpty else {
            return
        }
        networkShared.query(with: input) { [weak self] gallery, error in
            if let error = error {
                print("Fetching List Error: ", error)
                return
            }
            self?.imageEntities = Utility.getImageList(gallery!)
            DispatchQueue.main.async {
                if self?.imageEntities.isEmpty ?? false {
                    let alert = UIAlertController(title: "Error", message: "No image found", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self?.present(alert, animated: true)
                }
                self?.collectionView.reloadData()
            }
        }
    }
}
