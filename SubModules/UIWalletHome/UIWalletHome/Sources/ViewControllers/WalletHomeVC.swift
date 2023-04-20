//
//  WalletHomeVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore

public class WalletHomeVC: WViewController {

    let walletContext: WalletContext
    let walletInfo: WalletInfo
    public init(walletContext: WalletContext, walletInfo: WalletInfo) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var walletHomeVM = WalletHomeVM(walletContext: walletContext, walletInfo: walletInfo, walletHomeVMDelegate: self)

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        walletHomeVM.refreshTransactions()
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    // MARK: - Setup home views
    func setupViews() {
        let balanceHeaderView = BalanceHeaderView()
        view.addSubview(balanceHeaderView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: balanceHeaderView.topAnchor),
            view.leftAnchor.constraint(equalTo: balanceHeaderView.leftAnchor),
            view.rightAnchor.constraint(equalTo: balanceHeaderView.rightAnchor)
        ])

        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self

        let tableHeaderView = UIView()
        tableHeaderView.backgroundColor = .clear
        tableHeaderView.frame.size = CGSize(width: 10, height: 300)
        tableView.tableHeaderView = tableHeaderView

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            view.rightAnchor.constraint(equalTo: tableView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
        
        tableView.backgroundColor = .blue
    }
    
    // MARK: - Update View Functions
    func updateBalance(balance: Int64) {
        
    }
    func updateHeaderTimestamp(timestamp: Int32) {
        
    }
}

// MARK: - UITableView DataSource and Delgate
extension WalletHomeVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

// MARK: - WalletHome ViewModel Delegate Methods
extension WalletHomeVC: WalletHomeVMDelegate {
    // called on each state update to update views
    func updateCombinedState(combinedState: CombinedWalletState?, isUpdated: Bool) {
        if let combinedState = combinedState {
            updateBalance(balance: combinedState.walletState.effectiveAvailableBalance)
//            self.headerNode.balanceNode.balance = (formatBalanceText(max(0, combinedState.walletState.effectiveAvailableBalance), decimalSeparator: self.presentationData.dateTimeFormat.decimalSeparator), .white)
//            if let unlockedBalance = combinedState.walletState.unlockedBalance {
//                let lockedBalance = combinedState.walletState.totalBalance - unlockedBalance
//
//                if lockedBalance <= 0 {
//                    let balanceLabel: String
//                    switch self.blockchainNetwork {
//                    /*case .mainNet:
//                        balanceLabel = self.presentationData.strings.Wallet_Info_YourBalance*/
//                    case .testNet:
//                        balanceLabel = "Your balance"
//                    }
//                    self.headerNode.balanceSubtitleNode.attributedText = NSAttributedString(string: balanceLabel, font: Font.regular(13), textColor: UIColor(white: 1.0, alpha: 0.6))
//                    self.headerNode.balanceSubtitleIconNode.isHidden = true
//                } else {
//                    let balanceText = formatBalanceText(max(0, lockedBalance), decimalSeparator: self.presentationData.dateTimeFormat.decimalSeparator)
//
//                    let string = NSMutableAttributedString()
//                    string.append(NSAttributedString(string: "\(balanceText)", font: Font.semibold(13), textColor: .white))
//                    string.append(NSAttributedString(string: " locked", font: Font.regular(13), textColor: .white))
//
//                    self.headerNode.balanceSubtitleNode.attributedText = string
//                    self.headerNode.balanceSubtitleIconNode.isHidden = false
//                }
//            } else {
//                let balanceLabel: String
//                switch self.blockchainNetwork {
//                /*case .mainNet:
//                    balanceLabel = self.presentationData.strings.Wallet_Info_YourBalance*/
//                case .testNet:
//                    balanceLabel = "Your balance"
//                }
//                self.headerNode.balanceSubtitleNode.attributedText = NSAttributedString(string: balanceLabel, font: Font.regular(13), textColor: UIColor(white: 1.0, alpha: 0.6))
//                self.headerNode.balanceSubtitleIconNode.isHidden = true
//            }
//            self.headerNode.balance = max(0, combinedState.walletState.effectiveAvailableBalance)
//
//            if self.isReady, let (layout, navigationHeight) = self.validLayout {
//                self.containerLayoutUpdated(layout: layout, navigationHeight: navigationHeight, transition: .immediate)
//            }

//            if isUpdated {
//                self.reloadingState = false
//            }
            
            updateHeaderTimestamp(timestamp: Int32(clamping: combinedState.timestamp))

//            if self.isReady, let (_, navigationHeight) = self.validLayout {
//                self.headerNode.update(size: self.headerNode.bounds.size, navigationHeight: navigationHeight, offset: self.listOffset ?? 0.0, transition: .immediate, isScrolling: false)
//            }

//            var updatedTransactions: [WalletTransaction] = combinedState.topTransactions
//            if let currentEntries = self.currentEntries {
//                var existingIds = Set<WalletInfoListEntryId>()
//                for transaction in updatedTransactions {
//                    existingIds.insert(.transaction(transaction.transactionId))
//                }
//                for entry in currentEntries {
//                    switch entry {
//                    case let .transaction(_, transaction):
//                    switch transaction {
//                    case let .completed(transaction):
//                        if !existingIds.contains(.transaction(transaction.transactionId)) {
//                            existingIds.insert(.transaction(transaction.transactionId))
//                            updatedTransactions.append(transaction)
//                        }
//                    case .pending:
//                        break
//                    }
//                    default:
//                        break
//                    }
//                }
//            }

//            self.transactionsLoaded(isReload: true, isEmpty: false, transactions: updatedTransactions, pendingTransactions: combinedState.pendingTransactions)

//            if isUpdated {
//                self.headerNode.isRefreshing = false
//            }

//            if self.isReady, let (_, navigationHeight) = self.validLayout {
//                self.headerNode.update(size: self.headerNode.bounds.size, navigationHeight: navigationHeight, offset: self.listOffset ?? 0.0, transition: .animated(duration: 0.2, curve: .easeInOut), isScrolling: false)
//            }
        } else {
//            self.transactionsLoaded(isReload: true, isEmpty: true, transactions: [], pendingTransactions: [])
        }
//
//        let wasReady = self.isReady
//        self.isReady = true
//
//        if self.isReady && !wasReady {
//            if let (layout, navigationHeight) = self.validLayout {
//                self.headerNode.update(size: self.headerNode.bounds.size, navigationHeight: navigationHeight, offset: layout.size.height, transition: .immediate, isScrolling: false)
//            }
//
//            self.becameReady(animated: self.didSetContentReady)
//        }
        
//        if !self.didSetContentReady {
//            self.didSetContentReady = true
//            self.contentReady.set(.single(true))
//        }
    }
    
    // called when refresh failed with an error
    func refreshErrorOccured(error: GetCombinedWalletStateError) {
        let text: String
        switch error {
            case .generic:
                text = WStrings.Wallet_Home_RefreshErrorText.localized
                break
            case .network:
                text = WStrings.Wallet_Home_RefreshErrorNetworkText.localized
                break
        }

        showAlert(title: WStrings.Wallet_Home_RefreshErrorTitle.localized,
                  text: text,
                  button: WStrings.Wallet_Alert_OK.localized)
    }
}
