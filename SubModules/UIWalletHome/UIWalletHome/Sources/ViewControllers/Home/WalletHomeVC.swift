//
//  WalletHomeVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIWalletSend
import UIComponents
import WalletContext
import WalletCore
import Bridge

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

        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.backgroundColor = WTheme.balanceHeaderView.background

        // connect the application to the wallet applications
//        BridgeToApp.connect()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.open(URL(string: "tc://?v=2&id=7200057313a31397feb70171404b1935d2ed771c8951f9acd3d07bb8d7e9f269&r=%7B%22manifestUrl%22%3A%22https%3A%2F%2Fgist.githubusercontent.com%2Fsiandreev%2F75f1a2ccf2f3b4e2771f6089aeb06d7f%2Fraw%2Fd4986344010ec7a2d1cc8a2a9baa57de37aaccb8%2Fgistfile1.txt%22%2C%22items%22%3A%5B%7B%22name%22%3A%22ton_addr%22%7D%5D%7D")!)
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
        underSafeAreaView.backgroundColor = WTheme.balanceHeaderView.background
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
        balanceHeaderView = BalanceHeaderView(walletInfo: walletInfo, delegate: self)
        view.addSubview(balanceHeaderView)
        NSLayoutConstraint.activate([
            balanceHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            balanceHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            balanceHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        // reversed bottom corner radius for balance header view!
        let bottomCornersView = ReversedCornerRadiusView()
        bottomCornersView.translatesAutoresizingMaskIntoConstraints = false
        bottomCornersView.backgroundColor = WTheme.balanceHeaderView.background
        view.addSubview(bottomCornersView)
        NSLayoutConstraint.activate([
            bottomCornersView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            bottomCornersView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            bottomCornersView.topAnchor.constraint(equalTo: balanceHeaderView.bottomAnchor),
            bottomCornersView.heightAnchor.constraint(equalToConstant: 16),
            emptyWalletView!.topAnchor.constraint(equalTo: balanceHeaderView.bottomAnchor)
        ])

    }
    
    // MARK: - Update View Functions
    func updateBalance(balance: Int64) {
        balanceHeaderView.update(balance: balance)
    }
    func updateHeaderTimestamp(timestamp: Int32) {
        let diff = Date().timeIntervalSince1970 - Double(timestamp)
        if diff < 60 {
            balanceHeaderView.update(status: .updated)
        } else {
            // TODO:: show diff like the original app ?
        }
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
        let transactionVC = TransactionVC(transaction: walletHomeVM.transactions![indexPath.row])
        present(bottomSheet: transactionVC)
    }
}

// MARK: - WalletHome ViewModel Delegate Methods
extension WalletHomeVC: WalletHomeVMDelegate {
    // called on each state update to update views
    func updateCombinedState(combinedState: CombinedWalletState?, isUpdated: Bool) {
        tableView.reloadData()
        
        if let combinedState = combinedState {
            // TODO:: Show locked balance in a separate label?
            updateBalance(balance: combinedState.walletState.effectiveAvailableBalance)

            updateHeaderTimestamp(timestamp: Int32(clamping: combinedState.timestamp))

            var updatedTransactions: [WalletTransaction] = combinedState.topTransactions
            if updatedTransactions.count > 0 {
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
    
    func updateUpdateProgress(to progress: Int) {
        if walletHomeVM.isRefreshing || balanceHeaderView.updateStatusView.state != .updated {
            balanceHeaderView.update(status: .updating(progress: progress))
        }
        // TODO:: Pull to refresh?
//                    if strongSelf.headerNode.isRefreshing, strongSelf.isReady, let (_, _) = strongSelf.validLayout {
//                        strongSelf.headerNode.refreshNode.update(state: .refreshing)
//                    }
    }
    
    // called when refresh failed with an error
    func refreshErrorOccured(error: GetCombinedWalletStateError) {
        //let text: String
        switch error {
            case .generic:
                //text = WStrings.Wallet_Home_RefreshErrorText.localized
                balanceHeaderView.update(status: .connecting)
                break
            case .network:
                //text = WStrings.Wallet_Home_RefreshErrorNetworkText.localized
                balanceHeaderView.update(status: .waitingForNetwork)
                break
        }

        /*showAlert(title: WStrings.Wallet_Home_RefreshErrorTitle.localized,
                  text: text,
                  button: WStrings.Wallet_Alert_OK.localized)*/
    }
}

// MARK: - `BalanceHeaderView` Delegate Functions
extension WalletHomeVC: BalanceHeaderViewDelegate {
    public func scanPressed() {
        // TODO::
    }
    public func settingsPressed() {
        let settingsVC = SettingsVC(walletContext: walletContext,
                                    walletInfo: walletInfo,
                                    onCurrencyChanged: { [weak self] currencyID in
            self?.balanceHeaderView?.selectedCurrencyID = currencyID
        })
        present(UINavigationController(rootViewController: settingsVC), animated: true)
    }
    public func receivePressed() {
        let receiveVC = ReceiveVC(walletContext: walletContext, walletInfo: walletInfo)
        present(UINavigationController(rootViewController: receiveVC), animated: true)
    }
    public func sendPressed() {
        guard let balance = walletHomeVM.combinedState?.walletState.effectiveAvailableBalance else {
            return
        }
        let sendVC = SendVC(walletContext: walletContext, walletInfo: walletInfo, balance: balance)
        present(UINavigationController(rootViewController: sendVC), animated: true)
    }
}
