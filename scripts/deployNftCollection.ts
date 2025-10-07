import { toNano } from '@ton/core';
import { NftCollection } from '../build/NftCollection/NftCollection_NftCollection';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const nftCollection = provider.open(await NftCollection.fromInit());

    await nftCollection.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        null,
    );

    await provider.waitForDeploy(nftCollection.address);

    // run methods on `nftCollection`
}
