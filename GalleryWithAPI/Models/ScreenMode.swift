//
//  ScreenMode.swift
//  GalleryWithAPI
//
//  Created by LUNNOPARK on 07.03.23.
//

import Foundation
import UIKit

enum ScreenMode: CaseIterable {
    case new
    case popular
    
    var title: String {
        switch self {
        case .new:
            return "New"
        case .popular:
            return "Popular"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .new:
            return UIImage(named: "TodayIcon")
        case .popular:
            return .init(named: "popular")
        }
    }
}
