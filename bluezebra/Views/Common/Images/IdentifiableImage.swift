//
//  IdentifiableImage.swift
//  bluezebra
//
//  Created by Harshel Bahl on 21/07/2023.
//

import Foundation
import SwiftUI

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let thumbnail: UIImage?
    let image: UIImage?
    let url: URL?
}
