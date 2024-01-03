// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract YulTypeTest is Test {
    function test_get_number() public {
        (uint256 value1, uint256 value2, bytes32 value3) = getNumber();
        console2.log("value1: %s", value1);
        console2.log("value2: %s", value2);
        console2.logBytes32(value3);
    }

    function getNumber() public pure returns (uint256, uint256, bytes32) {
        uint256 x;
        uint256 y;
        bytes32 myString = "";
        assembly {
            x := 42
            y := 0xb
            myString := "hello-world-Iambaice"
        }
        return (x, y, myString);
    }

    function test_bool_cast() public {
        bool x;
        assembly {
            x := 3
        }
        console2.log("x: %s", x);
    }
}
