//
//  WalletHomeVC.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import UIKit
import UIWalletSend
import UIQRScan
import UIComponents
import WalletContext
import WalletCore
import Bridge
import UITonConnect
import SwiftSignalKit

public class WalletHomeVC: WViewController {

    // MARK: - Initializer
    let walletContext: WalletContext
    let walletInfo: WalletInfo
    var animateHeaderOnLoad: Bool
    public init(walletContext: WalletContext, walletInfo: WalletInfo, animateHeaderOnLoad: Bool) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.animateHeaderOnLoad = animateHeaderOnLoad
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Model and UI Components
    lazy var walletHomeVM = WalletHomeVM(walletContext: walletContext, walletInfo: walletInfo, walletHomeVMDelegate: self)

    private var popRecognizer: InteractivePopRecognizer?
    private var belowSafeAreaViewBottomConstraint: NSLayoutConstraint!
    private var tableView: UITableView!
    private var tableHeaderView: UIView!
    private var refreshControl: UIRefreshControl!
    private var headerContainerView: UIView!
    private var headerContainerViewHeightConstraint: NSLayoutConstraint? = nil
    private var balanceHeaderView: BalanceHeaderView!
    private var bottomCornersView: ReversedCornerRadiusView!
    private var emptyWalletView: EmptyWalletView? = nil

    // previous update progress to handle ui changes based on previous value
    private var prevUpdateProgres: Int? = nil

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
        view.backgroundColor = WTheme.background

        navigationController?.setNavigationBarHidden(true, animated: false)

        // View under table view to cover under safe area,
        //  and make black bounce background possible. (we can't use views above table view, because they will block refresh control.
        let belowSafeAreaView = UIView()
        belowSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        belowSafeAreaView.backgroundColor = WTheme.balanceHeaderView.background
        view.addSubview(belowSafeAreaView)
        belowSafeAreaViewBottomConstraint = belowSafeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            belowSafeAreaView.leftAnchor.constraint(equalTo: view.leftAnchor),
            belowSafeAreaView.rightAnchor.constraint(equalTo: view.rightAnchor),
            belowSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            belowSafeAreaViewBottomConstraint
        ])

        // configure table view
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none // we implement it inside cells, to prevent extra lines on older iOS versions
        tableView.register(WalletTransactionCell.self, forCellReuseIdentifier: "Transaction")
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .clear
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = WTheme.balanceHeaderView.balance
        refreshControl.addTarget(self, action: #selector(refreshTransactions), for: .valueChanged)
        tableView.refreshControl = refreshControl

        // empty header to be behind the balanceHeaderView
        tableHeaderView = UIView()
        tableHeaderView.backgroundColor = WTheme.balanceHeaderView.background
        tableHeaderView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: BalanceHeaderView.defaultHeight)
        tableHeaderView.alpha = animateHeaderOnLoad ? 0 : 1 // when animating, header view should not have a color, so animation appears as desired.
        tableView.tableHeaderView = tableHeaderView

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // show `loading` or `wallet created` view if needed, based on situation
        emptyWalletView = EmptyWalletView()
        view.addSubview(emptyWalletView!)
        NSLayoutConstraint.activate([
            emptyWalletView!.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            emptyWalletView!.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            emptyWalletView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // header container view (used to make animating views on start, possible)
        headerContainerView = UIView()
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        // Should be black only on collapsed header view to make tableview go under it.
        //  Also, it should be black during the first animation to make black background animation possible.
        //  If we set it to be black all the time, the refesh control will not be visible.
        headerContainerView.backgroundColor = animateHeaderOnLoad ? WTheme.balanceHeaderView.background : .clear
        headerContainerView.layer.masksToBounds = true
        view.addSubview(headerContainerView)
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerContainerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        // balance header view
        balanceHeaderView = BalanceHeaderView(walletInfo: walletInfo, delegate: self)
        headerContainerView.addSubview(balanceHeaderView)
        let balanceHeaderViewBottomConstraint = balanceHeaderView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor)
        // this priotity should be `.defaultHigh` because it should break and respect `headerContainerViewHeightConstraint` on startup animation.
        balanceHeaderViewBottomConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            balanceHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            balanceHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            balanceHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
            balanceHeaderViewBottomConstraint
        ])

        // reversed bottom corner radius for balance header view!
        bottomCornersView = ReversedCornerRadiusView()
        bottomCornersView.translatesAutoresizingMaskIntoConstraints = false
        bottomCornersView.backgroundColor = WTheme.balanceHeaderView.background
        view.addSubview(bottomCornersView)
        NSLayoutConstraint.activate([
            bottomCornersView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            bottomCornersView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            bottomCornersView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            bottomCornersView.heightAnchor.constraint(equalToConstant: ReversedCornerRadiusView.radius),
            emptyWalletView!.topAnchor.constraint(equalTo: bottomCornersView.topAnchor)
        ])

        if animateHeaderOnLoad {
            headerContainerViewHeightConstraint = headerContainerView.heightAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([
                headerContainerViewHeightConstraint!
            ])
        }
        
        // activate swipe back for presenting views on navigation controller (with hidden navigation bar)
        setInteractiveRecognizer()
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if animateHeaderOnLoad {
            animateHeaderOnLoad = false
            // hide everything before first render!
            emptyWalletView?.alpha = 0
            balanceHeaderView.alpha = 0
            balanceHeaderView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            view.layoutIfNeeded()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, delay: 0.1, animations: {
                    self.headerContainerViewHeightConstraint?.constant = BalanceHeaderView.defaultHeight + self.view.safeAreaInsets.top
                    self.balanceHeaderView.alpha = 1
                    self.emptyWalletView?.alpha = 1
                    self.balanceHeaderView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.view.layoutIfNeeded()
                }) { _ in
                    self.headerContainerViewHeightConstraint?.isActive = false
                    // should use table header view as black background provider to let refresh control appear.
                    self.tableHeaderView.alpha = 1
                    self.headerContainerView.backgroundColor = .clear
                }
            }
        }
    }
    
    var firstAppear = true
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.backgroundColor = WTheme.balanceHeaderView.background
        
        if firstAppear {
            walletContext.setReadyWalletInfo(walletInfo: walletInfo)
            firstAppear = false
        }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.backgroundColor = WTheme.background
    }
    
    @objc func refreshTransactions() {
        walletHomeVM.refreshTransactions()
    }
    
    func moveRefreshControlTo(y: CGFloat) {
        refreshControl.bounds = CGRect(x: refreshControl.bounds.origin.x,
                                       y: y,
                                       width: refreshControl.bounds.size.width,
                                       height: refreshControl.bounds.size.height)
    }

}

// MARK: - UITableView DataSource and Delgate
extension WalletHomeVC: UITableViewDataSource, UITableViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // on start, set backgrond to clear to let refresh control appear
        balanceHeaderView.backgroundColor = .clear
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newHeight = balanceHeaderView.updateHeight(scrollOffset: scrollView.contentOffset.y)
        if newHeight <= BalanceHeaderView.minHeight {
            // make table view go under top bar
            headerContainerView.backgroundColor = WTheme.balanceHeaderView.background
        } else {
            // top bar should clear to show refresh control, if required
            headerContainerView.backgroundColor = .clear
        }
        if scrollView.contentOffset.y < 0 {
            belowSafeAreaViewBottomConstraint.constant = -scrollView.contentOffset.y
        } else {
            belowSafeAreaViewBottomConstraint.constant = 0
        }
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletHomeVM.transactions?.count ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Transaction", for: indexPath) as! WalletTransactionCell
        cell.configure(with: walletHomeVM.transactions![indexPath.row],
                       prevItem: indexPath.row > 0 ? walletHomeVM.transactions![indexPath.row - 1] : nil)
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let transactionVC = TransactionVC(walletContext: walletContext,
                                          walletInfo: walletInfo,
                                          transaction: walletHomeVM.transactions![indexPath.row],
                                          homeVC: self)
        present(bottomSheet: transactionVC)
    }
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= (walletHomeVM.transactions?.count ?? 0) - 3 {
            walletHomeVM.loadMoreTransactions()
        }
    }
}

// MARK: - WalletHome ViewModel Delegate Methods
extension WalletHomeVC: WalletHomeVMDelegate {
    func updateBalance(balance: Int64) {
        balanceHeaderView.update(balance: balance)
    }
    func updateHeaderTimestamp(timestamp: Int32) {
        let diff = Date().timeIntervalSince1970 - Double(timestamp)
        if diff < 60 {
            balanceHeaderView.update(status: .updated)
            moveRefreshControlTo(y: 0)
        } else {
            // We can show diff like the original app, but it's not in the designs.
        }
    }

    func updateEmptyView() {
        if walletHomeVM.transactions?.count == 0 {
            // switch from loading view to wallet created view
            emptyWalletView?.showWalletCreatedView(address: walletInfo.address)
        } else if walletHomeVM.transactions?.count ?? 0 > 0 {
            emptyWalletView?.hideAnimated()
            // don't need it anymore, let it dealloc!
            emptyWalletView = nil
        }
    }
    
    func reloadTableView(deleteIndices: [HomeDeleteItem], insertIndicesAndItems: [HomeInsertItem], updateIndicesAndItems: [HomeUpdateItem]) {
        tableView.beginUpdates()
        tableView.deleteRows(at: deleteIndices.map({ it in
            IndexPath(row: it.index, section: 0)
        }), with: .automatic)
        tableView.insertRows(at: insertIndicesAndItems.map({ it in
            IndexPath(row: it.index, section: 0)
        }), with: .automatic)
        tableView.reloadRows(at: updateIndicesAndItems.filter({ it in
            return !deleteIndices.contains { alreadyDeleted in
                return it.index == alreadyDeleted.index
            } && !insertIndicesAndItems.contains { alreadyInserted in
                return it.index == alreadyInserted.index
            }
        }).map({ it in
            IndexPath(row: it.index, section: 0)
        }), with: .automatic)
        tableView.endUpdates()
    }

    func hideRefreshing() {
        refreshControl.endRefreshing()
        // set background color of the header view to prevent unwanted main view background color appearance on table view jumps
        balanceHeaderView.backgroundColor = WTheme.balanceHeaderView.background
    }

    func updateUpdateProgress(to progress: Int?) {
        if progress == 0 || (prevUpdateProgres == nil && progress == 100) {
            // we ignore progress 0 because it's handled using refresh logic and progress == nil will be called one time
            // also, we ignore progress == 100 to prevent jumping from nothing to 100% in UI!
            return
        }
        prevUpdateProgres = progress
        if walletHomeVM.isRefreshing || balanceHeaderView.updateStatusView.state != .updated {
            balanceHeaderView.update(status: .updating(progress: progress), handleAnimation: refreshControl.isRefreshing && progress == nil)
        }
        // handle animation of the status view customized, on pull to refresh!
        if refreshControl.isRefreshing, progress == nil {
            balanceHeaderView.updateStatusView.alpha = 0
            UIView.animate(withDuration: 0.15, animations: { [weak self] in
                guard let self else { return }
                self.refreshControl.alpha = 0
            }, completion: { [weak self] _ in
                guard let self else { return }
                hideRefreshing()
                if balanceHeaderView.updateStatusView.state != .updated { // check if still updating
                    moveRefreshControlTo(y: -60)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.refreshControl.alpha = 1
                }
            })
            UIView.animate(withDuration: 0.15, delay: 0.15) {
                self.balanceHeaderView.updateStatusView.alpha = 1
            }
        }
    }
    
    // called when refresh failed with an error
    func refreshErrorOccured(error: GetCombinedWalletStateError) {
        moveRefreshControlTo(y: -60)
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
        navigationController?.pushViewController(QRScanVC(walletContext: walletContext, walletInfo: walletInfo, callback: { url in
            #if DEBUG
            if url.absoluteString.hasPrefix("https://app.tonkeeper.com/ton-connect?") {
                UIApplication.shared.open(URL(string: "tc://?" + url.absoluteString.components(separatedBy: "?")[1])!)
                return
            }
            #endif
            UIApplication.shared.open(url)
        }), animated: true)
    }
    public func settingsPressed() {
        let settingsVC = SettingsVC(walletContext: walletContext,
                                    walletInfo: walletInfo,
                                    disposeAllDisposables: { [weak self] in
            self?.walletHomeVM.disposeAll()
        }, onCurrencyChanged: { [weak self] currencyID in
            self?.balanceHeaderView?.selectedCurrencyID = currencyID
        })
        present(UINavigationController(rootViewController: settingsVC), animated: true)
    }
    public func receivePressed() {
        let receiveVC = ReceiveVC(walletContext: walletContext, walletInfo: walletInfo)
        present(UINavigationController(rootViewController: receiveVC), animated: true)
    }
    public func sendPressed() {
        if walletHomeVM.reloadingState {
            showAlert(title: nil, text: WStrings.Wallet_Send_SyncInProgress.localized, button: WStrings.Wallet_Alert_OK.localized)
            return
        }
        if !(walletHomeVM.combinedState?.pendingTransactions.isEmpty ?? true) {
            showAlert(title: nil, text: WStrings.Wallet_Send_TransactionInProgress.localized, button: WStrings.Wallet_Alert_OK.localized)
            return
        }

        guard let balance = walletHomeVM.combinedState?.walletState.effectiveAvailableBalance else {
            return
        }
        let sendVC = SendVC(walletContext: walletContext, walletInfo: walletInfo, balance: balance)
        present(UINavigationController(rootViewController: sendVC), animated: true)
    }
}
