message Transfer{
    new_owner: Address;
    queryId: Int as uint256;   
}

struct CollectionData {
    next_item_index: Int as uint256;
    collection_content: Cell;
    owner_address: Address;
}

struct ItemData {
    owner: Address;
    collection_address: Address;
    item_index: Int as uint256;
    individual_content: Cell;
}