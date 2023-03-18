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
    
    lazy var networkSV: NetworkStackView = {
        let view = NetworkStackView()
        view.isHidden = true
        return view
    }()
    
    lazy var reachibilityNetwork = NetworkReachabilityManager(host: "www.ya.ru")
    
    var completion: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLargeTitle()
        setupGallery()
        setupNetworkSV()
        loadMore()
//        doWhaiIWant( completion: { boolValue in
//            print("doWhaiIWant", boolValue)
//        })
        
        reachibilityNetwork?.startListening(onUpdatePerforming: { [weak self] status in
            guard let self = self else { return }
            switch status {
            case .unknown, .reachable:
                self.networkSV.isHidden = true
                self.collectionView.isHidden = false
                print("reachable or unknown")

                if self.requestImages.isEmpty {
                    self.loadMore()
                }
                
            case .notReachable:
                self.networkSV.isHidden = false
                self.collectionView.isHidden = true
                print("notReachable")
            }
        })
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
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .customPurple
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backArrow")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backArrow")
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
    
    private func setupNetworkSV() {
        view.addSubview(networkSV)
        networkSV.snp.makeConstraints {
            $0.center.equalTo(view.snp.center)
        }
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

        let request = URLConfiguration.url + URLConfiguration.api
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
        completion?(Bool.random())
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
    
    func doWhaiIWant(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        requestImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gallery", for: indexPath) as? GalleryCell else { return UICollectionViewCell() }

        let urlString = URLConfiguration.url + URLConfiguration.media + (requestImages[indexPath.item].image.name ?? "")
        let model = GalleryCellModel(imageUrl: URL(string: urlString))
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = DetailedImageScreen()
        nextVC.model = requestImages[indexPath.item]
        navigationController?.pushViewController(nextVC, animated: true)    
    }
}
