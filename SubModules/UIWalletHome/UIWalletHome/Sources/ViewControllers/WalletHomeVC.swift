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

    // MARK: - Initializer
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

    // MARK: - View Model and UI Components
    lazy var walletHomeVM = WalletHomeVM(walletContext: walletContext, walletInfo: walletInfo, walletHomeVMDelegate: self)

    private var tableView: UITableView!
    private var balanceHeaderView: BalanceHeaderView!
    private var emptyWalletView: EmptyWalletView? = nil

    // MARK: - Load and SetupView Functions
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        walletHomeVM.refreshTransactions()
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Setup home views
    func setupViews() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        // configure table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none // we implement it inside cells, to prevent extra lines on older iOS versions
        tableView.register(WalletTransactionCell.self, forCellReuseIdentifier: "Transaction")
        tableView.estimatedRowHeight = UITableView.automaticDimension

        // empty header to be behind the balanceHeaderView
        let tableHeaderView = UIView()
        tableHeaderView.backgroundColor = .clear
        tableHeaderView.frame.size = CGSize(width: 10, height: BalanceHeaderView.defaultHeight)
        tableView.tableHeaderView = tableHeaderView

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // top space under safe area
        let underSafeAreaView = UIView()
        underSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        underSafeAreaView.backgroundColor = currentTheme.balanceHeaderView.background
        view.addSubview(underSafeAreaView)
        NSLayoutConstraint.activate([
            underSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            underSafeAreaView.leftAnchor.constraint(equalTo: view.leftAnchor),
            underSafeAreaView.rightAnchor.constraint(equalTo: view.rightAnchor),
            underSafeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        // show `loading` or `wallet created` view if needed, based on situation
        emptyWalletView = EmptyWalletView()
        view.addSubview(emptyWalletView!)
        NSLayoutConstraint.activate([
            emptyWalletView!.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            emptyWalletView!.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            emptyWalletView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // balance header view
        balanceHeaderView = BalanceHeaderView()
        view.addSubview(balanceHeaderView)
        NSLayoutConstraint.activate([
            balanceHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            balanceHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            balanceHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
            emptyWalletView!.topAnchor.constraint(equalTo: balanceHeaderView.bottomAnchor)
        ])
    }
    
    // MARK: - Update View Functions
    func updateBalance(balance: Int64) {
        balanceHeaderView.update(balance: balance)
    }
    func updateHeaderTimestamp(timestamp: Int32) {
        
    }
    func updateEmptyView() {
        if walletHomeVM.transactions?.count == 0 {
            emptyWalletView?.showWalletCreatedView(address: walletInfo.address)
        } else if walletHomeVM.transactions?.count ?? 0 > 0 {
            emptyWalletView?.hideAnimated()
            // don't need it anymore, let it dealloc!
            emptyWalletView = nil
        }
    }
}

// MARK: - UITableView DataSource and Delgate
extension WalletHomeVC: UITableViewDataSource, UITableViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        balanceHeaderView.updateHeight(scrollOffset: scrollView.contentOffset.y)
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletHomeVM.transactions?.count ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Transaction", for: indexPath) as! WalletTransactionCell
        cell.configure(with: walletHomeVM.transactions![indexPath.row])
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - WalletHome ViewModel Delegate Methods
extension WalletHomeVC: WalletHomeVMDelegate {
    // called on each state update to update views
    func updateCombinedState(combinedState: CombinedWalletState?, isUpdated: Bool) {
        tableView.reloadData()
        
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

            var updatedTransactions: [WalletTransaction] = combinedState.topTransactions
            if updatedTransactions.count > 0 {
                print("UPPPPPPPPPP")
                print(updatedTransactions)
            }
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
        
        updateEmptyView()
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
