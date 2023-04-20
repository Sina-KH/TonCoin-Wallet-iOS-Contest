import UIKit

//#if TARGET_IPHONE_SIMULATOR
//UIKIT_EXTERN float UIAnimationDragCoefficient();
//#endif

var animationDurationFactorImpl: Double {
    get {
//        #if TARGET_IPHONE_SIMULATOR
//        return (double)UIAnimationDragCoefficient()
//        #endif
        return 1.0
    }
}

func makeSpringAnimationImpl(_ keyPath: String) -> CABasicAnimation {
    let springAnimation = CASpringAnimation(keyPath: keyPath)
    springAnimation.mass = 3.0
    springAnimation.stiffness = 1000.0
    springAnimation.damping = 500.0
    springAnimation.duration = 0.5
    springAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
    return springAnimation
}
