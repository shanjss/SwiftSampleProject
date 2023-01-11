//
//  DetailViewController.swift
//  SearchImage
//
//  Created by Shantanu Barnawal on 10/1/2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImageView.image = image
    }
    
}

