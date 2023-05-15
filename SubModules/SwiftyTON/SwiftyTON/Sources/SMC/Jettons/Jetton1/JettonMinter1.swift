//
//  Created by Anton Spivak
//

import Foundation

import TON3

//public struct JettonMinter1: JettonMinter {
//
//    public var contract: Contract
//
//    public let supply: Currency
//    public let administrator: Address?
//
//    public init(
//        contract: Contract
//    ) async throws {
//        let types = (
//            GTExecutionResultDecimal.self,
//            GTExecutionResultDecimal.self,
//            GTExecutionResultCell.self,
//            GTExecutionResultCell.self,
//            GTExecutionResultCell.self
//        )
//
//        let stack = try await contract.execute(methodNamed: "get_jetton_data")
//        guard let stack = stack.map(to: types),
//              let supply = Int64(stack.0.value)
//        else {
//            throw ContractError.unknownContractType
//        }
//
//        if let rawAddress = try? await TON3.address(boc: stack.2.hex.bytes) {
//            self.administrator = Address(rawValue: rawAddress)
//        } else {
//            self.administrator = nil
//        }
//
//        self.supply = Currency(supply)
//        self.contract = contract
//    }
//
//    public func jettonWallet(
//        for address: Address
//    ) async throws -> JettonWallet {
//        let types = (
//            GTExecutionResultCell.self
//        )
//
//        let builder = try await TON3.Builder()
//        await builder.store(address: address.hash, workchain: address.workchain)
//
//        let stack = try await contract.execute(
//            methodNamed: "get_wallet_address",
//            arguments: [
//                GTExecutionResultSlice(
//                    hex: Data(
//                        hex: try await builder.boc()
//                    )
//                )
//            ]
//        )
//
//        guard let stack = stack.map(to: types),
//              let rawAddress = try? await TON3.address(boc: stack.hex.bytes),
//              let address = Address(rawValue: rawAddress)
//        else {
//            throw ContractError.unknownContractType
//        }
//
//        return try await JettonWallet1(
//            address: address
//        )
//    }
//}
