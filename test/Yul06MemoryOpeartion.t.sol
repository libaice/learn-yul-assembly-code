// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract Memory {
    struct Point {
        uint256 x;
        uint256 y;
    }

    event MemoryPointer(bytes32);
    event MemoryPointerMsize(bytes32, bytes32);

    function highAccess() external pure {
        assembly {
            // pop just throws away the return value
            pop(mload(0xffffffffffffffff))
        }
    }

    // 1 byte  = 8 bits
    function mstore8() external pure {
        assembly {
            mstore8(0x00, 7)
            mstore(0x00, 8)
        }
    }

    // 0x80   0xC0
    // 0xC0 - 0x80 = 64

    function memPointer() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);

        Point memory p = Point(1, 2);
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    // need set  optimizer=false
    // ─ emit MemoryPointerMsize(: 0x0000000000000000000000000000000000000000000000000000000000000080, : 0x0000000000000000000000000000000000000000000000000000000000000060)
    //│   ├─ emit MemoryPointerMsize(: 0x00000000000000000000000000000000000000000000000000000000000000c0, : 0x00000000000000000000000000000000000000000000000000000000000000c0)
    //│   ├─ emit MemoryPointerMsize(: 0x00000000000000000000000000000000000000000000000000000000000000c0, : 0x0000000000000000000000000000000000000000000000000000000000000120)
    function memPointerV2() external {
        bytes32 x40;
        bytes32 _msize;
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);

        Point memory p = Point(1, 2);
        assembly {
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);

        assembly {
            pop(mload(0xff))
            x40 := mload(0x40)
            _msize := msize()
        }
        emit MemoryPointerMsize(x40, _msize);
    }

    // 80 + 20 = a0
    // 80 + 40 = c0
    function fixedArray() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);

        uint256[2] memory arr = [uint256(5), uint256(6)];
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    //80 -> calculate  a0 -> 2value -> e0
    function abiEncode() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encode(uint256(5), uint256(19));
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    function abiEncode2() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encode(uint256(5), uint128(19));
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    function abiEncodePacked() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encodePacked(uint256(5), uint128(19));

        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    event Debug(bytes32, bytes32, bytes32, bytes32);

    function args(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAtIndex0;
        bytes32 valueAtIndex1;

        assembly {
            location := arr
            len := mload(arr)
            valueAtIndex0 := mload(add(arr, 0x20))
            valueAtIndex1 := mload(add(arr, 0x40))
            // ...
        }
        emit Debug(location, len, valueAtIndex0, valueAtIndex1);
    }

    function breakFreeMemoryPointer(
        uint256[1] memory foo
    ) external view returns (uint256) {
        assembly {
            mstore(0x40, 0x80)
        }
        uint256[1] memory bar = [uint256(6)];
        return foo[0];
    }

    uint8[] foo = [1, 2, 3, 4, 5, 6];

    // will not packed together
    function unpacked() external {
        uint8[] memory bar = foo;
    }
}

contract MemoryOpeartionTest is Test {
    Memory memoryContract;

    function setUp() public {
        memoryContract = new Memory();
    }

    function test_highAccess() public {
        memoryContract.highAccess();
    }

    // use foundry debugger to trace the memory
    function test_mstore8() public {
        memoryContract.mstore8();
    }

    function test_memPointer() public {
        memoryContract.memPointer();
    }

    function test_memPointerV2() public {
        memoryContract.memPointerV2();
    }

    function test_fixedArray() public {
        memoryContract.fixedArray();
    }

    function test_abiEncode() public {
        memoryContract.abiEncode();
    }

    function test_abiEncode2() public {
        memoryContract.abiEncode2();
    }

    function test_abiEncodePacked() public {
        memoryContract.abiEncodePacked();
    }

    function test_args() public {
        uint256[] memory arr = new uint256[](2);
        arr[0] = 4;
        arr[1] = 5;
        memoryContract.args(arr);
    }

    function test_breakFreeMemoryPointer() public {
        uint256[1] memory foo = [uint256(5)];
        memoryContract.breakFreeMemoryPointer(foo);
    }

    function test_unpacked() public {
        memoryContract.unpacked();
    }
}
