//
//  Meme.swift
//  MemeMe1
//
//  Created by Michelle Williamson on 9/10/21.
//

import Foundation
import UIKit

/**
 A meme is made up of 4 parts:
 - Text at the top of the image
 - Text at the bottom of the image
 - The original raw image without the text applied
 - The meme image created of the text and iamge
 */
struct Meme {
    var topText: String
    var bottomText: String
    var origImage: UIImage
    var memeImage: UIImage
}
