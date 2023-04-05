// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ExampleToken.sol";
import {ContractAllowList} from "../src/mock/ContractAllowListMock.sol";
import {IContractAllowList} from "../src/mock/IContractAllowList.sol";

// OpenSea mumbai 0x1E0049783F008A0085193E00003D00cd54003c71

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address CAL_ADDRESS = 0xf45ADc76c04894Ed968000715FD5882A84c7FD86;
        vm.startBroadcast(deployerPrivateKey);
        /*        address[] memory gov = new address[](1);
        gov[0] = vm.addr(deployerPrivateKey);
        IContractAllowList cal = new ContractAllowList(gov);*/
        ExampleToken nft = new ExampleToken(CAL_ADDRESS);
        nft.mint(vm.addr(deployerPrivateKey), 1);
        vm.stopBroadcast();
    }
}
