import UIKit
import MixinServices

class ClockSkewViewController: UIViewController {

    @IBOutlet weak var continueButton: RoundedButton!
    @IBOutlet weak var tipsLabel: UILabel!
    

    class func instance() -> ClockSkewViewController {
        return R.storyboard.home.clock()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Logger.general.error(category: "ClockSkewViewController", message: "View did load")
    }


    @IBAction func continueAction(_ sender: Any) {
        guard !continueButton.isBusy else {
            return
        }
        continueButton.isBusy = true

        AccountAPI.me { [weak self](result) in

            switch result {
            case .success:
                AppGroupUserDefaults.Account.isClockSkewed = false
                AppDelegate.current.mainWindow.rootViewController = makeInitialViewController()
            case .failure(.clockSkewDetected):
                self?.continueButton.isBusy = false
            case let .failure(error):
                showAutoHiddenHud(style: .error, text: error.localizedDescription)
                self?.continueButton.isBusy = false
            }
        }
    }

    func checkFailed() {
        guard continueButton != nil else {
            return
        }
        continueButton.isBusy = false
        tipsLabel.shake()
    }

}

fileprivate extension UIView {
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

