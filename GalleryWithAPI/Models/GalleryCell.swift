//
//  GalleryCell.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 16.02.23.
//

import Foundation
import UIKit

struct GalleryCellModel {
    
    var imageUrl: URL?
}

class GalleryCell: UICollectionViewCell {
    
    var imageInGallery = UIImageView()
    var dataTask: URLSessionDataTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellLayout()
        setupImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dataTask?.cancel()
        imageInGallery.image = nil
    }
    
    func setupCellLayout() {
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.systemGray.cgColor
        self.layer.cornerRadius = 5
        
        self.backgroundColor = UIColor(red:197/255.0, green:197/255.0, blue:197/255.0, alpha:1/1.0)
    }
    
    func setupImage() {
        contentView.addSubview(imageInGallery)
        
        imageInGallery.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageInGallery.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageInGallery.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageInGallery.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageInGallery.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        imageInGallery.layer.cornerRadius = 6
        imageInGallery.clipsToBounds = true
        imageInGallery.contentMode = .scaleAspectFill
    }
    
    func setupCollectionItem(model: GalleryCellModel) {
        guard let url = model.imageUrl else {
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self?.imageInGallery.image = UIImage(data: data)
                }
            }
        }
        task.resume()
        dataTask = task
    }
    
}
