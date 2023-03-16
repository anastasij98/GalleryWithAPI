//
//  DetailedImageScreen.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 15.03.23.
//

import Foundation
import SnapKit
import Kingfisher

class DetailedImageScreen: UIViewController {
    
    var dataTask: URLSessionDataTask?
    
    var scrollView: UIScrollView = {
       var view = UIScrollView()
        view = UIScrollView(frame: .zero)
        view.isScrollEnabled = true
       return view
    }()
    
    var selectedImage: UIImageView = {
       var view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    var imageTitle: UILabel = {
        let view = UILabel()
        view.textColor = .customPurple
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        return view
    }()
    
    var model: ItemModel?
    
    var imageDescription: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12, weight: .regular)
        view.numberOfLines = 0
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupScrollView()
        screenContent()
    }
    
    func screenContent() {
        
        imageTitle.text = model?.name
        imageDescription.text = model?.description
        
        if let name = model?.image.name {
            let urlString = URLConfiguration.url + URLConfiguration.media + name
            guard let url = URL(string: urlString) else {
                return
            }
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.selectedImage.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
            dataTask = task
        }
    }
 
    func setupScrollView() {
        scrollView.delegate = self
        
        scrollView.addSubviews(selectedImage, imageTitle, imageDescription)
        view.addSubview(scrollView)
        
        selectedImage.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(300)
            $0.width.equalTo(300)
            $0.centerX.equalTo(scrollView.snp.centerX)
        }
        
        imageTitle.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.top.equalTo(selectedImage.snp.bottom).offset(20)
        }
        
        imageDescription.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20)
            $0.top.equalTo(imageTitle.snp.bottom).offset(20)
            $0.bottom.equalTo(scrollView.snp.bottom)
        }
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.setZoomScale(1, animated: true)
        
        scrollView.bouncesZoom = false
        scrollView.scrollsToTop = false
    
    }
    
    deinit {
        dataTask?.cancel()
    }
}

extension DetailedImageScreen: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return selectedImage
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.zoomScale = 1
    }
}

