// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract StorageBasics {
    uint256 public x;
    uint256 public y;
    uint256 public z;

    uint128 public a;
    uint128 public b;

    function setValue() public {
        a = 1;
        b = 2;
    }

    function getValueBySlot(uint256 slot) public view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }

    function setValueBySlot(uint256 slot, uint256 value) public {
        assembly {
            sstore(slot, value)
        }
    }

    function getXSlot() public pure returns (uint256 slot) {
        assembly {
            slot := x.slot
        }
    }

    function getXValue() public view returns (uint256 value) {
        assembly {
            value := sload(x.slot)
        }
    }
}

contract Yul03StorageBasic is Test {
    StorageBasics storageBasics;

    function setUp() public {
        storageBasics = new StorageBasics();
    }

    // function test_Get_X() public {
    //     console2.log("x value is: ", storageBasics.x());
    //     uint256 slot = storageBasics.getXSlot();
    //     console2.log("x slot is: ", slot);
    //     storageBasics.setX();
    //     console2.log("x value is: ", storageBasics.x());
    //     slot = storageBasics.getXSlot();
    //     console2.log("x slot is: ", slot);

    //     uint256 value = storageBasics.getXValue();
    //     console2.log("x value is: ", value);
    // }

    // function testSetSlotValue() public {
    //     uint256 slot0 = storageBasics.getValueBySlot(0);
    //     console2.log("slot0 value is: ", slot0);

    //     uint256 slot1 = storageBasics.getValueBySlot(1);
    //     console2.log("slot1 value is: ", slot1);

    //     uint256 slot2 = storageBasics.getValueBySlot(2);
    //     console2.log("slot2 value is: ", slot2);

    //     storageBasics.setValueBySlot(0, 100);
    //     slot0 = storageBasics.getValueBySlot(0);
    //     console2.log("slot0 value is: ", slot0);

    //     storageBasics.setValueBySlot(1, 200);
    //     slot1 = storageBasics.getValueBySlot(1);
    //     console2.log("slot1 value is: ", slot1);

    //     storageBasics.setValueBySlot(2, 300);
    //     slot2 = storageBasics.getValueBySlot(2);
    //     console2.log("slot2 value is: ", slot2);

    //     storageBasics.setValueBySlot(33, 123);
    //     uint256 slot33 = storageBasics.getValueBySlot(33);
    //     console2.log("slot33 value is: ", slot33);
    // }

    function testSameSlot()public {
        storageBasics.setValue();
        bytes32 slot3 = storageBasics.getValueBySlot(3);

        console2.logBytes32( slot3);
    }
}
