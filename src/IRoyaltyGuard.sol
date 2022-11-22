// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IRoyaltyGuard {
    enum ListType {
        ALLOW,
        DENY,
        OFF
    }

    error Unauthorized();
    error CantAddToOFFList();
    error DeadmanTriggerStillActive();

    
}
