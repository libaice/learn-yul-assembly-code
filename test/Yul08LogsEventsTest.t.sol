// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract LogContract {
    event SomeLog(uint256 indexed a, uint256 indexed b);
    event SomeLogV2(uint256 indexed a, bool);

    function emitLog() external {
        emit SomeLog(5, 6);
    }

    function yulEmitLog() external {
        assembly {
            let
                signature
            := 0xc200138117cf199dd335a2c6079a6e1be01e6592b6a76d4b5fc31b169df819cc
            log3(0, 0, signature, 0x05, 0x06)
        }
    }

    function v2eEmitLog() external {
        emit SomeLogV2(5, true);
    }

    function v2YulEmitLog() external {
        assembly {
            let
                signature
            := 0x113cea0e4d6903d772af04edb841b17a164bff0f0d88609aedd1c4ac9b0c15c2
            mstore(0x00, 1)
            log2(0, 0x20, signature, 0x05)
        }
        
    }

    function boom() external {
        assembly{
            selfdestruct(caller())
        }
    }



}

contract LogTest is Test {
    LogContract logContract;

    function setUp() public {
        logContract = new LogContract();
    }

    function testLog() public {
        logContract.emitLog();
    }

    function testYulLog() public {
        logContract.yulEmitLog();
    }

    function testV2Log() public {
        logContract.v2eEmitLog();
    }       


    function testV2YulLog() public {
        logContract.v2YulEmitLog();
    }

    function testBoom() public {
        logContract.boom();
    }
}
