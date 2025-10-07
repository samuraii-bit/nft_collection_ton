import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { NftCollection } from '../build/NftCollection/NftCollection_NftCollection';
import '@ton/test-utils';
import { NftItem } from '../build/NftCollection/NftCollection_NftItem';

describe('NftCollection', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let nftCollection: SandboxContract<NftCollection>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        nftCollection = blockchain.openContract(await NftCollection.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await nftCollection.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            null,
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: nftCollection.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and nftCollection are ready to use
    });
    
    it('should mint NFT', async () => {
        await nftCollection.send(
            deployer.getSender(), 
            {
                value: toNano("0.3")
            },
            "Mint"
        );

        const nftItemAddress = await nftCollection.getNftAddress(deployer.address, 0n);
        const nftItem: SandboxContract<NftItem> = blockchain.openContract(NftItem.fromAddress(nftItemAddress));

        const itemData = await nftItem.getItemData();
        expect(itemData.individual_content.beginParse().loadStringTail()).toEqual("Item # - 0");

        const collectionData = await nftCollection.getCollectionData();
        expect(collectionData.collection_content.beginParse().loadStringTail()).toEqual("MuzraevTA First NFT Collection");
    });

    it('should transfer NFT', async () => {
        await nftCollection.send(
            deployer.getSender(), 
            {
                value: toNano("0.3")
            },
            "Mint"
        );

        const nftItemAddress = await nftCollection.getNftAddress(deployer.address, 0n);
        const nftItem: SandboxContract<NftItem> = blockchain.openContract(NftItem.fromAddress(nftItemAddress));
        let currentItemOwner = await nftItem.getOwner();
        expect(currentItemOwner.toString()).toEqual(deployer.address.toString());

        const user = await blockchain.treasury("user");

        await nftItem.send(
            deployer.getSender(),
            {
                value: toNano("0.3")
            },
            {
                $$type: "Transfer",
                new_owner: user.address,
                queryId: 0n
            }
        );

        currentItemOwner = await nftItem.getOwner();
        expect(currentItemOwner.toString()).toEqual(user.address.toString());
        expect(deployer.address.toString()).not.toEqual(user.address.toString());
    });
});
