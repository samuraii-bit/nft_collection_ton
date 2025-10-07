import "@stdlib/ownable";
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
contract NftItem with OwnableTransferable {
    owner: Address;
    collection_address: Address;
    item_index: Int as uint256;
    individual_content: String;

    init(owner: Address, collection_address: Address, item_index: Int, individual_content: String) {
        self.item_index = item_index;
        self.collection_address = collection_address;
        self.owner = owner;
        self.individual_content = individual_content;
    }

    receive(msg: Transfer) {
        self.requireOwner();
        self.owner = msg.new_owner;
    }

    get fun itemData(): ItemData {
        return ItemData {
            owner: self.owner,
            collection_address: self.collection_address,
            item_index: self.item_index,
            individual_content: self.individual_content.asSlice().asCell()
        };
    }
}
