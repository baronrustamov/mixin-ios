import UIKit
import MixinServices

class VerificationCodeViewController: ContinueButtonViewController {
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var verificationCodeField: VerificationCodeField!
    @IBOutlet weak var resendButton: CountDownButton!
    
    let resendInterval = 60
    
    var isBusy = false {
        didSet {
            continueButton.isBusy = isBusy
            verificationCodeField.receivesInput = !isBusy
        }
    }
    
    convenience init() {
        self.init(nib: R.nib.verificationCodeView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ScreenHeight.current <= .short {
            contentStackView.spacing = 18
        }
        if let label = resendButton.titleLabel {
            label.setFont(scaledFor: .monospacedDigitSystemFont(ofSize: 14, weight: .regular),
                          adjustForContentSize: true)
            label.adjustsFontForContentSizeCategory = true
        }
        resendButton.normalTitle = R.string.localizable.resend_code()
        resendButton.pendingTitleTemplate = NSLocalizedString(R.string.localizable.resend_code_pending.key, comment: "")
        resendButton.beginCountDown(resendInterval)
        verificationCodeField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !verificationCodeField.isFirstResponder {
            verificationCodeField.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resendButton.restartTimerIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resendButton.releaseTimer()
    }
    
    @IBAction func verificationCodeFieldEditingChanged(_ sender: Any) {
        
    }
    
    @IBAction func resendAction(_ sender: Any) {
        resendButton.isBusy = true
        verificationCodeField.clear()
        requestVerificationCode(captchaToken: nil)
    }
    
    func requestVerificationCode(captchaToken token: CaptchaToken?) {
        
    }
    
    func handleVerificationCodeError(_ error: MixinAPIError) {
        isBusy = false
        switch error {
        case .invalidPhoneVerificationCode:
            verificationCodeField.clear()
            verificationCodeField.showError()
            alert(R.string.localizable.the_code_is_incorrect())
        default:
            reporter.report(error: error)
            alert(error.localizedDescription)
        }
    }
    
}
