# :gem: TON Wallet Contest :gem:

The `Toncoin Wallet` application re-written from the scratch, while 
re-using the best of the exiting, original codebase.

- Build instructions are available in this readme file, below features and notices sections.

## :boom: Features

:white_check_mark: **Backward-compatible:** All the `wallet storage logic` 
is backward compatible and almost reused. Only a few changes applied to support new flows.

:white_check_mark: **Support Ton Wallet v3R1, v3R2 and v4R2**: The application is now using the latest version of the [
ADNL TonLib Repository](https://github.com/ton-blockchain/ton) (2023.03, because 2023.04 was leading to crash on parsing list of transactions). To support switching between wallet versions, the new address is created based on selected wallet version and all the tonlib function calls use the new address.

:white_check_mark: **TON Connect 2 Support** as documented in [Ton-Connect Repository](https://github.com/ton-blockchain/ton-connect). `Bridge` and `Session Protocol` are implemented. `tc://` is available as unified deeplink of the ton connect. `Universal Link` is also support and can be set after deploying the `Bridge instance`. **To test this feature, it's possible to use in-app qr scanner [here](https://ton-connect.github.io/demo-dapp/). It's using `TonKeeper Bridge` for development tests**

:white_check_mark: **Wallet Balance (in USD, EUR and RUB)** is also shown for the `selected currency` when home screen's header is scrolled and collapsed, like the design. (using [tonapi.io](https://tonapi.io))

:white_check_mark: **Only ADNL is being used:** All the communications to the TON Blockchain are through ADNL and `tonlib`. The main wrapper that connects the app to the network, is `TonBinding` module, just like the original app, plus some modifications to make it support new features.

Other modules like `SwiftyTON` `TON3` and `SwiftyJS` in the project are customized for this repository and responsible for local logics like providing wallet initial state and creating BOC, and can be ported into our main codebase. GlossyTON is removed from these modules and they has nothing to do with the network. *We probably can NOT consider migrating to SwiftyTON in the future, It is not complete and perfect, specially in error handling. And unfortunately, its repository is archived by the contributer at May 22, 2023. (Unless we fork and develop it, ourselves. It seems very modern and clean, btw.) So, For now, I prefer to stay with least changes and original implementation of tonlib.*

:white_check_mark: **DNS and raw addresses:** Both `DNS` and `Raw` addresses are supported.

:white_check_mark: **Deeplinks:** `ton` and `tc` app schemas are implemented.

:white_check_mark: `iOS 13+` support. (If we remove async/await and actor codes used in SwiftyTON, TON3 and SwiftyJS modules, or even remove these modules from the porject, We can even support iOS 12.2+ with the same app size. Almost no other os dependent features limited to iOS 13+ is used in the application, even for theming.)

:white_check_mark: **App size** (the final download size for `.ipa file`) is **around 6.5 megabytes**. And the app install size on the test flight is around 22 megabytes.

:white_check_mark: **Dark mode** on iOS 13+

:white_check_mark: **AppLock** Feature to let user lock the app using passcode and FaceID/TouchID.

## :exclamation:  Notices

- [ ] **PushNotifications:** Push Notification implementation should be done by developing a back-end server for the application.
- [ ] **Bridge's exclusive instance:** Wallet's bridge instance should be deployed on the back-end, for now it uses ton keeper's wallet url.
- [ ] **Wallet listings:** Wallet should be listed in the toncoin wallet listings.
- [ ] **Lock:** I've implemented lock screen and app-lock, but the app uses keychain hardware encryption (same as the original version), so for lower-level actions (accessing private key), like showing the recovery phrase or sending TON, the app still depends on the iOS unlock mechanism. *We can store the keys another way to let it unlock using our custom `UnlockVC` instead of iOS unlock, or even force migrate the storage data on application update, But It will NOT be as safe as it is now!*
- [ ] **Check TODOs:** Some small details of the application needs to be double-checked. For example if the DApp requests more than 1 message in sendTransaction request, how should the app present the ton transfer popup? These details are flaged using TODO:: comments in code.
- [x] **Fixed:** If you change/remove passcode of the device, because of the keychain hardware encryption, the app forces you to re-import or create a new wallet, but after that, on restarts, the app still shows the same error. This issue exists from the original application wallet record checks.
**Solution:** Fixed by using latest records from the storage to check wallet status! We can consider removing old records, also.

## :beers: How to Build

1. Install xcode on your mac. The latest version of xcode (14.3) is highly 
recommended.

1. Install xcode command-line tools

1. Make sure you have `homebrew` installed and then install cmake, ccache, pkg-config and libmicrohttpd 
using `brew install cmake ccache pkg-config libmicrohttpd`

1. Clone the repository with submodules with
`git clone https://github.com/Sina-KH/TonCoin-Wallet-iOS-Contest --recursive`

1. Install `openssl` on your system, and set it's path inside `Prepare/scripts/build-ton.sh` file like:
```export OPENSSL_ROOT_DIR=/usr/local/opt/openssl@3/```
This is the default path, already set in this file, so you don't need to change it if your openssl is installed in this path. *If you've installed openssl through homebrew, you may need to change it.*

1. Run the Prepare.sh script with `cd Prepare && sh prepare.sh`, ***This command 
should run successfully with no errors.*** This script ***automatically*** 
builds `OpenSSL` and `Tonlib`, create the universal `.a` lib files and put 
them inside the `TonBinding` project. (The final output will only contain 
required parts of the libs, btw.)
*If you encountered any errors, Please make sure to install any required/missing libraries mentioned in the error message.*

1. Run `ToncoinWallet.xcworkspace` using Xcode, Select `Toncoin Wallet` target and the project should 
build successfully both on simulator and real devices. If you've faced any build issues, it can be due to xcode's internal issues on first build, related to build race-conditions(!), just try again. :) I've tested both mainnet and testnet on both M1 and Intel processors, on simulator and real-device, so It should just work. :)

## :cat:  Technical Considerations

:large_blue_circle: **Xcode modular build-system:**

While the original version of the wallet codebase was using bazel as the 
build-system, I've decided to use Xcode because of it's easier usage, at 
least for me :)

It's **super-easy** to work with, and **super-fast** in development and 
building of this application.

I've also added sub-modules as separate `.xcodeproj` project files, so They are 
easier to maintain and we can change their build-system, easier, if 
required.

:large_blue_circle: **UIKit to develop Application UI:**

The trade-off between performance and development speed, led me to choose 
`UIKit` + `Programtically UI Programming`. The original app was using 
`Texture` as the core of UI Display Module, inspired from Telegram source 
code, but It was harder to develop the new version with this library, and 
after [opening an issue on contest 
repository](https://github.com/ton-community/wallet-contest/issues/4), 
I've finally decided to use UIKit over Texture or SwiftUI.

:large_blue_circle: **Git-Submodule and a prepared script to build the 
dependencies:**

To attach `Tonlib` and `OpenSSL` libraries to the project, [the new tonlib 
repository](https://github.com/ton-blockchain/ton) has beed added to the 
project as a submodule.

A bash file (`Prepare/prepare.sh`) will now **automatically** build the 
dependencies for both `arm64` and `x86_64` architectures and link them to 
the `TonBinding` module, so everything can work just fine without any 
other configurations or manual installations.

xcode will automatically remove unnecessary parts from `universal .a` 
files, on final `.ipa` files. So we don't need to worry about the size of 
the application after linking universal libs.

:large_blue_circle: **Update tonlib in the future:**

**The tonlib is now on the latest version**, BTW, to update it in the 
future, We just have to update the submodule to the latest release tag, 
and then re-run the `prepare.sh` script. **Note that** if the lib headers 
are changed in the new version, the `header files` should be updated 
manually. (and also .a files defined inside xcodeproj file only if the 
file names are changed/updated.) **We can automate this flow using 
xcodegen or other options, in the future.**

## :jigsaw: Modules

These modules are defined inside the project:

### :fire: ToncoinWallet:

The main module containing `AppDelegate`, `Strings`, `Animations` and the 
app `startup codes`.

The `deeplinks logic` is also handled in this module, inside `SplashVC`

### :popcorn: UICreateWallet:

The UI implementation of the create wallet flow, including `Intro`, 
`WalletCreated`, `WordDisplay`, `WordCheck` and `Completed` pages.

### :key: UIPasscode

The UI implementation of the set passcode flow.

### :house: UIWalletHome

The UI implementation of the home (main) page of the wallet.

### :rocket: UIWalletSend

The UI implementation of the send TON screen pages.

### :movie_camera:  UIQRScan

QRScanner to scan `ton`, `tc` and also `tonkeeper`'s bridge url. (last one is for test purposes on debug mode, only.)

### :rocket:  UITonConnect

`TonConnect 2` connection and transfer features. Welcome DApps! :fist_right: :fist_left: 

### :jack_o_lantern: UIComponents

All the UIKit implementation of the components provided inside Figma and 
used to build the app.
This module also contains util functions for view classes and elements.

### :link: Bridge

The bridge framework is developed to support Ton Connect feature using the [bridge api documentation](https://github.com/ton-blockchain/ton-connect/blob/main/bridge.md).

### :books: WalletContext

Shared class/struct files that are being used by `UI X` modules are 
developed here. Including `WStrings`, `WTheme`, `KeychainHelper`, 
`WalletPresentationData` and so on.

### :gear: WalletCore

This module is a wrapper around `TonBinding` and provides the wallet 
functionalities for the `UI Layer`.

### :thread: WalletUrl

Parses wallet `ton` deeplink urls and returns the addres, amount and comment 
from the `ton://transfer` urls.

### :yarn: TonBinding

The binding between the wallet project and the `tonlib` library.

### :ambulance:  SwiftyTON, TON3, SwiftyJS, BigInt, CryptoSwift

All these modules are used to process wallet related logics (InitStates, diferrent wallet version addresses, and more...)

### :lock:  Sodium

Sodium is used to implement encryption algorithms in `Bridge API`.
It includes Clibsodium (.xcframework) that can be rebuilt and used from [libsodium repository](https://github.com/jedisct1/libsodium). I've built the latest commit and added it into the project.

To build latest commit (Clibsodium .xcframework file), you can clone the source code and run `sh autogen.sh -f -s && sh dist-build/apple-xcframework.sh`.

For latest release version (that generates .a file), you can clone it and run `sh autogen.sh && sh dist-build/ios.sh`

### :hammer: BuildConfig

Configurations is used by `ToncoinWallet`.

### :mount_fuji: RLottieBinding

The library is used to play `.tgs` animation files.

### :dark_sunglasses: GZip

GZip library is used inside the animation player logic.

### :person_fencing: SSignalKit

Used for reactive programming inside the existing modules/codes from the 
original wallet repository.

### :bouncing_ball_man: SwiftSignalKit

Used for reactive programming inside the existing modules/codes from the 
original wallet repository.

### :city_sunset: YuvConversion

YuvConversion library is used inside the animation player logic.

---

:technologist: Feel free to contact me:

**mr.sina.khalili@gmail.com**

:gem: And finally, I'm glad I could join this contest, be a part of the Toncoin community, and learn more about encryption and crypto wallets, especially **Toncoin**. :gem:
