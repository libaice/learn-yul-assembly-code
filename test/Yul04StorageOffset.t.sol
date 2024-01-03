// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract StorageOffset {
    uint128 public C = 4;
    uint96 public D = 6;
    uint16 public E = 8;
    uint8 public F = 1;

    function readBySlot(uint256 slot) public view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }

    function getOffsetE() external pure returns (uint256 slot, uint256 offset) {
        assembly {
            slot := E.slot
            offset := E.offset
        }
    }

    function readE() external view returns (uint256 e) {
        assembly {
            let value := sload(E.slot) // must load in 32 byte increments
            //
            // E.offset = 28
            let shifted := shr(mul(E.offset, 8), value)
            // 0x0000000000000000000000000000000000000000000000000000000000010008
            // equivalent to
            // 0x000000000000000000000000000000000000000000000000000000000000ffff
            e := and(0xffff, shifted)
        }
    }

    function readEalt() external view returns (uint256 e) {
        assembly {
            let slot := sload(E.slot)
            let offset := sload(E.offset)
            let value := sload(E.slot)

            let shifted := div(
                value,
                0x100000000000000000000000000000000000000000000000000000000
            )
            e := and(0xffffffff, shifted)
        }
    }

    // V and 00 = 00
    // V or 00 = V
    // V and FF = V

    function writeToE(uint16 newE) external {
        assembly {
            let c := sload(E.slot) // slot 0
            // 0x0001000800000000000000000000000600000000000000000000000000000004
            let clearedE := and(
                c,
                0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            // 0x0001000000000000000000000000000600000000000000000000000000000004

            let shiftedNewE := shl(mul(E.offset, 8), newE)
            // 0x0000000a
            let newVal := or(shiftedNewE, clearedE)
            //V or 00 = V
            // 0x0001000a00000000000000000000000600000000000000000000000000000004
            sstore(C.slot, newVal)
        }
    }
}

contract Yul04StorageOffsetTest is Test {
    StorageOffset storageOffset;

    function setUp() public {
        storageOffset = new StorageOffset();
    }

    function test_GetSlotData() public {
        bytes32 slotData = storageOffset.readBySlot(0);
        console2.logBytes32(slotData);
    }

    function test_GetOffset() public {
        uint256 e = storageOffset.readE();
        // console2.logBytes32(e);
        console2.log("e ", e);

        e = storageOffset.readEalt();
        console2.log("e ", e);
    }

    function test_writeToE() public {
        uint256 e = storageOffset.readE();
        console2.log("e ", e);
        storageOffset.writeToE(24);
         e = storageOffset.readE();
        console2.log("e ", e);
      
    }

    // function testBytes32Cast() public {
    //     bytes32 data = 0x123456789abcdef0123456789abcdef0123456789abcdef02232222222bcdef0;
    //     uint64 data128 = uint64(uint256(data));
    //     bytes32 data32 = bytes32(uint256(data128));
    //     console2.logBytes32(data32);
    // }
}
