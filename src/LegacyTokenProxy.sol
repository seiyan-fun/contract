// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract LegacyTokenProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) payable BeaconProxy(beacon, data) {}
}
