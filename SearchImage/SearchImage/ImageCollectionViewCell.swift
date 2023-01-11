//
//  ImageCollectionViewCell.swift
//  SearchImage
//
//  Created by Shantanu Barnawal on 10/1/2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var representedIdentifier: String = ""
  
    var image: UIImage? {
      didSet {
        imageView.image = image
      }
    }
}
