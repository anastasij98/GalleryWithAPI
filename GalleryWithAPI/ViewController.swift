//
//  ViewController.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 16.02.23.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController {
    
    var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: UICollectionViewFlowLayout())
        return view
    }()

    var requestImages: [ItemModel] = []
    
    var myUrl: URL?
    
    var isLoadingRightNow = false
    var totalItems: Int {
        requestImages.count
    }
    var countOfPages: Int {
        get {
            totalItems / imagesPerPage
        }
    }
    
    var imagesPerPage = 15
    var currentPage = 0
    var pageToLoad = 0
    var hasMorePages: Bool {
        currentPage <= countOfPages
    }
    
    var screenMode = ScreenMode.new
    
    lazy var refreshControl: UIRefreshControl = {
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
        loadMore()
        
    }
    // MARK: - Setup galery and title
    private func setupLargeTitle() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = screenMode.title
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.customPurple,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0.1843137255, green: 0.09019607843, blue: 0.4039215686, alpha: 1) ,
            .font: UIFont.systemFont(ofSize: 30, weight: .semibold)
        ]
    }
    
    private func setupGallery() {
        extendedLayoutIncludesOpaqueBars = true

        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "gallery")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubviews(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top)
            $0.bottom.equalTo(view.snp.bottom)
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
        }
        
        collectionView.refreshControl = refreshControl
    }
    // MARK: - URL, Request
    func getAnswerFromRequest(completion: @escaping(Result<JSONDataModel, Error>) -> ()) {
        pageToLoad = currentPage + 1
        let newValue: Bool
        let popularValue: Bool

        switch screenMode {
            case .new:
                newValue = true
                popularValue = false
            case .popular:
                newValue = false
                popularValue = true
        }

        let request = "https://gallery.prod1.webant.ru/api/photos"
        let parametrs: Parameters = [
            "page": "\(pageToLoad)",
            "new": "\(newValue)",
            "popular": "\(popularValue)",
            "limit": "\(imagesPerPage)"
        ]
        
        AF.request(request, method: .get, parameters: parametrs).responseData { response in
            if let data = response.data {
                   do {
                       let result = try JSONDecoder().decode(JSONDataModel.self, from: data)
                       completion(.success(result))
                   } catch let decodingError {
                       completion(.failure(decodingError))
                   }
               } else if let error = response.error {
                   completion(.failure(error))
               } else {
                   completion(.failure(NSError(domain: "Get nothing", code: 0, userInfo: [ : ])))
               }
               self.isLoadingRightNow = false
           }
           isLoadingRightNow = true
    }

    @objc
    func getData() {
        getAnswerFromRequest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.requestImages.append(contentsOf: success.data)
                    self.collectionView.reloadSections([0])
                    self.currentPage = self.pageToLoad

                case .failure(let failure):
                    print(failure)
                }
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc
    func refreshData(sender: UIRefreshControl) {
        currentPage = 0
        requestImages.removeAll()
        collectionView.reloadData()
        loadMore()
    }
    
    func loadMore() {
            guard !isLoadingRightNow, hasMorePages else {
                return print("all loaded")
            }
            getData()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let lastItemIndex = requestImages.count - 1
            if indexPath.row == lastItemIndex {
                loadMore()
            }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        requestImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gallery", for: indexPath) as? GalleryCell else { return UICollectionViewCell() }

        let urlSting = "https://gallery.prod1.webant.ru/media/" + (requestImages[indexPath.item].image.name ?? "")
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
