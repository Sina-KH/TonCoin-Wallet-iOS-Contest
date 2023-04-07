//
//  WAnimatedSticker.swift
//  UIComponents
//
//  Created by Sina on 4/7/23.
//

import UIKit
import GZip
import RLottieBinding

class WAnimatedSticker: UIView {

    @IBInspectable
    var animationWidth: Int = 248
    @IBInspectable
    var animationHeight: Int = 248
    
    @IBInspectable
    var replay: Bool = false
    
    @IBInspectable
    var animationName: String = "" {
        didSet {
            setup(animationName: animationName)
        }
    }
    
    private var animatedSticker: AnimatedStickerNode? = nil

    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    // setup animation data
    func setup(animationName: String) {
        // load the animation
        guard let path = Bundle(identifier: "org.ton.wallet")?.path(forResource: animationName, ofType: "tgs") else {
            return
        }

        // add animated sticker to the view
        animatedSticker = AnimatedStickerNode()
        animatedSticker?.translatesAutoresizingMaskIntoConstraints = false
        animatedSticker?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
        addSubview(animatedSticker!)
        animatedSticker?.didLoad()

        // setup the animated sticker
        animatedSticker?.setup(source: AnimatedStickerNodeLocalFileSource(path: path),
                               width: 248, height: 248,
                               playbackMode: replay ? .loop : .once,
                               mode: .direct)
        animatedSticker?.play()
    }
    
}
