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
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        return view
    }()
    
    var requestData: JSONDataModel?
    var items: [ItemModel] {
        get {
            requestData?.data ?? []
        }
    }
//    var requestArray: JSONDataModel = JSONDataModel(date: ItemModel(id: 2,
//                                                                       name: "",
//                                                                       date: "",
//                                                                       new: true,
//                                                                       popular: true,
//                                                                       image: ImageModel(id: 2,
//                                                                                         name: "cat1"))),
//        JSONDataModel(date: ItemModel(id: 2, name: "", date: "", new: true, popular: true, image: ImageModel(id: 2, name: "cat2")))
    
    
    var myUrl: URL?

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
        
        view.addSubviews(imageView, galleryCollection)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        galleryCollection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            galleryCollection.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            galleryCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            galleryCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            galleryCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    
    func getAnswerFromRequest(completion: @escaping(Result<JSONDataModel, Error>) -> ()) {
        guard let url = URL(string: "https://gallery.prod1.webant.ru/api/photos") else { return }
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
    }

    @objc
    func getData() {
        getAnswerFromRequest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
//                    let items = success.data
//                    self.requestData = items
//                    print(self.requestData)
//                    self.myUrl = URL(string: "https://gallery.prod1.webant.ru/media/" + self.requestData.data[0].image.name)
//
//                    print(self.myUrl)
                    
                    self.requestData = success
                    self.galleryCollection.reloadData()
                    // print(success)
                    
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gallery", for: indexPath) as? GalleryCell else { return UICollectionViewCell() }
        cell.backgroundColor = .blue
        
        let urlSting = "https://gallery.prod1.webant.ru/media/" + items[indexPath.item].image.name
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



