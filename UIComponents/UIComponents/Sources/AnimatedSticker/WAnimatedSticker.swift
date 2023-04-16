//
//  WAnimatedSticker.swift
//  UIComponents
//
//  Created by Sina on 4/7/23.
//

import UIKit
import GZip
import RLottieBinding

public class WAnimatedSticker: UIView {

    @IBInspectable
    public var animationName: String = ""
    
    private var animatedSticker: AnimatedStickerNode? = nil

    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    // setup animation data
    public func setup(width: Int, height: Int, playbackMode: AnimatedStickerPlaybackMode) {
        // load the animation
        guard let path = Bundle.main.path(forResource: animationName, ofType: "tgs") else {
            return
        }

        // add animated sticker to the view
        animatedSticker = AnimatedStickerNode()
        animatedSticker?.translatesAutoresizingMaskIntoConstraints = false
        animatedSticker?.frame = CGRect(x: 0, y: 0, width: width, height: width)
        addSubview(animatedSticker!)
        animatedSticker?.didLoad()

        // setup the animated sticker
        animatedSticker?.setup(source: AnimatedStickerNodeLocalFileSource(path: path),
                               width: width * 2, height: height * 2,
                               playbackMode: playbackMode,
                               mode: .direct)
        animatedSticker?.play()
    }

    public func toggle(_ on: Bool) {
        switch animatedSticker!.playbackMode {
            case .toggle(let toggleMode):
                if toggleMode == on {
                    return
                }
                break
            default:
                break
        }
        animatedSticker?.playbackMode = .toggle(on)
        animatedSticker?.play()
    }
}
