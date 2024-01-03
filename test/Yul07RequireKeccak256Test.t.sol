// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract UsingMemory {
    function return2and4() external pure returns (uint256, uint256) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 4)
            return(0x00, 0x40)
        }
    }

    function requireV1() external view {
        require(msg.sender == 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    }

    function requireV2() external view {
        assembly {
            if iszero(
                eq(caller(), 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
            ) {
                revert(0, 0)
            }
        }
    }

    function hashV1() external pure returns (bytes32) {
        bytes memory toBeHashed = abi.encode(1, 2, 3);
        return keccak256(toBeHashed);
    }

    function hashV2() external pure returns (bytes32) {
        assembly {
            let freeMemoryPointer := mload(0x40)
            
            // store 1
            mstore(freeMemoryPointer, 1)
            mstore(add(freeMemoryPointer, 0x20), 2)
            mstore(add(freeMemoryPointer, 0x40), 3)

            // update memory pointer
            mstore(0x40, add(freeMemoryPointer, 0x60))
            
            mstore(0x00, keccak256(freeMemoryPointer, 0x60))
            return(0x00, 0x60)

        }
    }
}

contract UsingMemoryTest is Test {
    UsingMemory usingMemory;

    function setUp() public {
        usingMemory = new UsingMemory();
    }

    function testReturn2And4() public {
        (uint256 a, uint256 b) = usingMemory.return2and4();
        console2.log(a, b);
    }

    function testRequireV1() public {
        usingMemory.requireV1();
    }

    function testRequireV2() public {
        usingMemory.requireV2();
    }

    function testHashV1() public {
        bytes32 hash = usingMemory.hashV1();
        console2.logBytes32(hash);
    }

    function testHashV2() public {
        bytes32 hash = usingMemory.hashV2();
        console2.logBytes32(hash);
    }

}
