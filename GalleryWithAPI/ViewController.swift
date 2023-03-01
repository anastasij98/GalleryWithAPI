//
//  ViewController.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 16.02.23.
//

import UIKit

class ViewController: UIViewController {
    
    var galleryCollection: UICollectionView = {
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: UICollectionViewFlowLayout())
        return view
    }()
    
    var requestData: JSONDataModel?
    var items: [ItemModel] {
        get {
            requestData?.data ?? []
        }
    }
    
    var requestImages: [ItemModel] = []
    
    var myUrl: URL?
    
    var isLoadingRightNow = false
    
    var currentPage = 1
    var imagesPerPage = 15
    
    lazy var refreshDataInCoolection: UIRefreshControl = {
        let view = UIRefreshControl()
        view.attributedTitle = NSAttributedString(string: "Loading new images")
        view.tintColor = .systemMint
        view.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return view
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupLargeTitle()
        setupGallery()
        getData()
        
    }
    
    private func setupLargeTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Popular"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor : UIColor(red: 47/255.0, green: 23/255.0, blue: 103/255.0, alpha: 1/1.0),
            .font : UIFont(name: "SFCompactDisplay-Semibold", size: 20) ?? .systemFont(ofSize: 20)
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor : UIColor(red: 47/255.0, green: 23/255.0, blue: 103/255.0, alpha: 1/1.0),
            .font : UIFont(name: "SFCompactDisplay-Semibold", size: 30) ?? .systemFont(ofSize: 20)
        ]
    }
    
    private func setupGallery() {
        galleryCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        galleryCollection.register(GalleryCell.self, forCellWithReuseIdentifier: "gallery")
        galleryCollection.delegate = self
        galleryCollection.dataSource = self
        
        view.addSubviews( galleryCollection)
        
        galleryCollection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            galleryCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            galleryCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            galleryCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            galleryCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        galleryCollection.refreshControl = refreshDataInCoolection
    }
    
    
    func getAnswerFromRequest(completion: @escaping(Result<JSONDataModel, Error>) -> ()) {
        //        guard let url = URL(string: "https://gallery.prod1.webant.ru/api/photos") else { return }
        guard let url = URL(string: "https://gallery.prod1.webant.ru/api/photos?page=\(currentPage)&limit=\(imagesPerPage)") else { return }
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                //
                do {
                    let result = try JSONDecoder().decode(JSONDataModel.self, from: data)
                    completion(.success(result))
                    //
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "Get nothing", code: 0, userInfo: [ : ])))
            }
        }
        task.resume()
        refreshDataInCoolection.endRefreshing()
    }

    @objc
    func getData() {
        getAnswerFromRequest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.requestData = success
                    self.requestImages.append(contentsOf: self.items)
                    self.galleryCollection.reloadData()
 
                case .failure(let failure):
                    print(failure)
                }
                self.isLoadingRightNow = false
            }
        }
    }
    
    @objc
    func refreshData(sender: UIRefreshControl) {
        currentPage = 1
        requestImages.removeAll()
        galleryCollection.reloadData()
        getData()
    }
    
    func loadMore() {
        currentPage += 1
        isLoadingRightNow = true
        getData()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let lastItem = requestImages.count
            if indexPath.row == lastItem - 1 && isLoadingRightNow == false {
                loadMore()
            }
       
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        requestImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gallery", for: indexPath) as? GalleryCell else { return UICollectionViewCell() }

        let urlSting = "https://gallery.prod1.webant.ru/media/" + requestImages[indexPath.item].image.name
        let model = GalleryCellModel(imageUrl: URL(string: urlSting))
        cell.setupCollectionItem(model: model)
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsInRow: CGFloat = 2
        let paddingInRow: CGFloat = (itemsInRow + 1) * 20
        let allowedWidth = view.frame.width - paddingInRow
        let widthOfItem = allowedWidth / itemsInRow
        return CGSize(width: widthOfItem, height: widthOfItem * 0.7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 17
    }

}



