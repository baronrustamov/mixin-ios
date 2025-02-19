import UIKit
import MixinServices

final class PrivacySettingViewController: SettingsTableViewController {
    
    private let dataSource = SettingsDataSource(sections: [
        SettingsSection(footer: R.string.localizable.setting_privacy_tip(), rows: [
            SettingsRow(title: R.string.localizable.blocked_users(), accessory: .disclosure),
            SettingsRow(title: R.string.localizable.conversation(), accessory: .disclosure)
        ]),
        SettingsSection(rows: [
            SettingsRow(title: R.string.localizable.phone_number(), accessory: .disclosure),
            SettingsRow(title: R.string.localizable.phone_contacts(), accessory: .disclosure)
        ])
    ])
    
    private lazy var screenLockSection = SettingsSection(rows: [
        SettingsRow(title: R.string.localizable.screen_lock(), subtitle: screenLockTimeoutInterval, accessory: .disclosure)
    ])
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    class func instance() -> UIViewController {
        let vc = PrivacySettingViewController()
        return ContainerViewController.instance(viewController: vc, title: R.string.localizable.privacy())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if biometryType != .none {
            dataSource.insertSection(screenLockSection, at: 2, animation: .none)
        }
        dataSource.tableViewDelegate = self
        dataSource.tableView = tableView
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateBlockedUserCell),
                                               name: UserDAO.usersDidChangeNotification,
                                               object: nil)
        updateBlockedUserCell()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateScreenLockRow),
                                               name: ScreenLockSettingViewController.screenLockTimeoutDidUpdateNotification,
                                               object: nil)
    }
    
}

extension PrivacySettingViewController {
    
    @objc func updateBlockedUserCell() {
        DispatchQueue.global().async {
            let blocked = UserDAO.shared.getBlockUsers()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                let indexPath = IndexPath(row: 0, section: 0)
                let row = self.dataSource.row(at: indexPath)
                if blocked.count == 0 {
                    row.subtitle = R.string.localizable.none()
                } else if blocked.count == 1 {
                    row.subtitle = R.string.localizable.contact_count(1)
                } else {
                    row.subtitle = R.string.localizable.contact_count_count(blocked.count)
                }
            }
        }
    }
    
    @objc private func updateScreenLockRow() {
        let indexPath = IndexPath(row: 0, section: 2)
        let row = dataSource.row(at: indexPath)
        row.subtitle = screenLockTimeoutInterval
    }
    
    private var screenLockTimeoutInterval: String {
        if AppGroupUserDefaults.User.lockScreenWithBiometricAuthentication {
            let timeInterval = AppGroupUserDefaults.User.lockScreenTimeoutInterval
            return ScreenLockTimeFormatter.string(from: timeInterval)
        } else {
            return R.string.localizable.off();
        }
    }
    
}

extension PrivacySettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc: UIViewController
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                vc = BlockedUsersViewController.instance()
            } else {
                vc = ConversationSettingViewController.instance()
            }
        case 1:
            if indexPath.row == 0 {
                vc = PhoneNumberSettingViewController.instance()
            } else {
                vc = PhoneContactsSettingViewController.instance()
            }
        default:
            switch TIP.status {
            case .ready, .needsMigrate:
                vc = ScreenLockSettingViewController.instance()
            case .needsInitialize:
                let tip = TIPNavigationViewController(intent: .create, destination: nil)
                present(tip, animated: true)
                return
            case .unknown:
                return
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
