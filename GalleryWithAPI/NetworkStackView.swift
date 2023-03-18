//
//  NetworkStackView.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 18.03.23.
//

import Foundation
import UIKit
import SnapKit

class NetworkStackView: UIView {
    
    var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.alignment = .center
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var imageError: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "noInternet")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    var titleError: UILabel = {
        let view = UILabel()
        view.text = "Oh shucks!"
        view.textColor = .customPurple
        view.font = .systemFont(ofSize: 20, weight: .semibold)
        return view
    }()
    
    var descriptionError: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.text = """
            Slow or no internet connection.
            Please check your internet settings.
        """
        view.textAlignment = .center
        view.textColor = .customGrey
        view.font = .systemFont(ofSize: 12, weight: .regular)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStackView() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(imageError)
        stackView.addArrangedSubview(titleError)
        stackView.addArrangedSubview(descriptionError)
        
        stackView.snp.makeConstraints {
            $0.center.equalTo(self.snp.center)
        }
    }
}
