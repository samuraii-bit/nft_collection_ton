import { toNano } from '@ton/core';
import { NftItem } from '../build/NftItem/NftItem_NftItem';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const nftItem = provider.open(await NftItem.fromInit());

    await nftItem.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        null,
    );

    await provider.waitForDeploy(nftItem.address);

    // run methods on `nftItem`
}
