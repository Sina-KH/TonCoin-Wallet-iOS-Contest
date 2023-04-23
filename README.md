# TON Wallet Contest

The `Toncoin Wallet` application re-written from the scratch, while 
re-using the best of the exiting, original codebase.

## :boom: Features

:white_check_mark: **Backward-compatible:** All the `wallet storage logic` 
is backward compatible and almost reused. Only a few changes applied to support new flows.

:white_check_mark: **Updated tonlib:** The application is now using the latest version of the [
ADNL TonLib Repository](https://github.com/ton-blockchain/ton) (2023.03).

:white_check_mark: `iOS 12.2+` support.

:white_check_mark: Supports all the iOS-devices starting from `iPhone 5s` and `4" display size`.

## :beers: How to Build

1. Install xcode on your mac. The latest version of xcode (14.3) is highly 
recommended.

1. Install xcode command-line tools

1. Make sure you have `homebrew` installed and then install libmicrohttpd 
using `brew install libmicrohttpd`

1. Clone the repository with submodules with
`git clone https://github.com/Sina-KH/TonCoin-Wallet-iOS-Contest --recursive`

1. Run the Prepare.sh script with `sh Prepare/prepare.sh`, ***This command 
should run successfully with no errors.*** This script ***automatically*** 
builds `OpenSSL` and `Tonlib`, create the universal `.a` lib files and put 
them inside the `TonBinding` project. (The final output will only contain 
required parts of the libs, btw.)

1. Run `ToncoinWallet.xcworkspace` using xcode and the project should 
build successfully both on simulator and real devices.

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

:large_blue_circle: **UIKit to design Application UI:**

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

### :popcorn: UICreateWallet:

The UI implementation of the create wallet flow, including `Intro`, 
`WalletCreated`, `WordDisplay`, `WordCheck` and `Completed` pages.

### :key: UIPasscode

The UI implementation of the set passcode flow.

### :house: UIWalletHome

The UI implementation of the home (main) page of the wallet.

### :rocket: UIWalletSend

The UI implementation of the send TON screen pages.

### :jack_o_lantern: UIComponents

All the UIKit implementation of the components provided inside Figma and 
used to build the app.
This module also contains util functions for view classes and elements.

### :books: WalletContext

Shared class/struct files that are being used by `UI X` modules are 
developed here. Including `WStrings`, `WTheme`, `KeychainHelper`, 
`WalletPresentationData` and so on.

### :gear: WalletCore

This module is a wrapper around `TonBinding` and provides the wallet 
functionalities for the `UI Layer`.

### :thread: WalletUrl

Parses wallet deeplink urls and returns the addres, amount and comment 
from the `ton://transfer` urls.

### :yarn: TonBinding

The binding between the wallet project and the `tonlib` library.

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

### :1st_place_medal: NumberPluralizationForm

This logic module is used by WalletContext module.
