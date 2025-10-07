import "@stdlib/ownable";
import "./nft_item";
import "./messages";

// Since v1.6.0, Tact has a contract parameters syntax that can supersede
// lazy initialization by init() for all contracts that do not require specific on-chain
// deployment logic that must be run only once in the `init()` function.
//
// Note that the empty parameter list above is still a parameter list,
// meaning that the contract won't have an implicit or explicit `init(){:tact}` function
// and will enjoy storage write optimizations and use less gas overall.
//
// See: https://docs.tact-lang.org/book/contracts/#parameters
contract NftCollection with Ownable{
    const minTonForStorage: Int = ton("0.03");
    const gasConsumption: Int = ton("0.03");
    owner: Address;
    next_item_index: Int as uint256;
    collection_content: String;

    init() {
        self.owner = sender();
        self.next_item_index = 0;
        self.collection_content = "MuzraevTA First NFT Collection";
    }

    receive() {
        
    }

    receive("Mint") {
        self.requireOwner();
        self.mint(sender());
    }

    fun mint(to: Address) {
        require(self.next_item_index >= 0, "Invalid next_item_index");
        let nft_item_init: StateInit = self.nftItemInit(to, self.next_item_index);
        let msgValue: Int = context().value;
        let tonBalanceBeforeMsg: Int = myBalance() - msgValue;
        let storageFee: Int = self.minTonForStorage - min(tonBalanceBeforeMsg, self.minTonForStorage);
        msgValue = msgValue - (storageFee + self.gasConsumption);

        send(SendParameters {
            to: contractAddress(nft_item_init),
            value: msgValue,
            mode: SendIgnoreErrors,
            body: Transfer{
                queryId: 0,
                new_owner: to,
            }.toCell(),
            code: nft_item_init.code,
            data: nft_item_init.data
        });
        
        self.next_item_index += 1;
    }

    get fun nftItemInit(owner: Address, item_index: Int): StateInit {
        let individual_content: StringBuilder = beginString();
        individual_content.append("Item # - ");
        individual_content.append(item_index.toString());
        return initOf NftItem(owner, myAddress(), item_index, individual_content.toString());
    }

    get fun collectionData(): CollectionData {
        return CollectionData {
            next_item_index: self.next_item_index,
            collection_content: self.collection_content.asSlice().asCell(),
            owner_address: self.owner
        };
    }

    get fun nftAddress(owner: Address, item_index: Int): Address {
        let init: StateInit = self.nftItemInit(owner, item_index);
        return contractAddress(init);
    }
}
