//
//  GalleryCell.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 16.02.23.
//

import Foundation
import UIKit
import SnapKit

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
        self.layer.shadowOffset = CGSize(width: 1, height: 7)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.systemGray.cgColor
        self.layer.cornerRadius = 5
        
        self.backgroundColor = UIColor(red:197/255.0, green:197/255.0, blue:197/255.0, alpha:1/1.0)
    }
    
    func setupImage() {
        contentView.addSubview(imageInGallery)
        
        imageInGallery.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.bottom.equalTo(contentView.snp.bottom)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
        }
        
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
