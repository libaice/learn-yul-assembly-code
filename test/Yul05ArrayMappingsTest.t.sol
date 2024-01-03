// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

// reference  https://medium.com/@0xZorz/how-to-read-dynamic-arrays-directly-from-storage-using-foundry-bdf5a104b8f6

contract StorageComplex {
    uint256[3] public fixedArray;
    uint256[] public bigArray;
    // 0x0000000000000000000000000000000000000000000000000000000005030201
    uint8[] public smallArray;

    mapping(uint256 => uint256) myMapping;
    mapping(uint256 => mapping(uint256 => uint256)) public nestedMapping;
    mapping(address => uint256[]) public addressToList;

    constructor() {
        fixedArray = [99, 999, 999];
        bigArray = [10, 20, 30];
        //
        smallArray = [1, 2, 3, 5];

        myMapping[10] = 5;
        myMapping[11] = 6;
        nestedMapping[2][4] = 7;

        addressToList[0x88c6C46EBf353A52Bdbab708c23D0c81dAA8134A] = [
            42,
            1337,
            777
        ];
    }

    function fixedArrayView(uint256 index) external view returns (uint256 ret) {
        assembly {
            ret := sload(add(fixedArray.slot, index))
        }
    }

    function bigArrayLength() external view returns (uint256 ret) {
        assembly {
            ret := sload(bigArray.slot)
        }
    }

    function readBigArrayLocation(
        uint256 index
    ) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := bigArray.slot
        }

        bytes32 location = keccak256(abi.encode(slot));
        assembly {
            ret := sload(add(location, index))
        }
    }

    function readSmallArray() external view returns (uint256 ret) {
        assembly {
            ret := sload(smallArray.slot)
        }
    }

    function readSmallArrayLocation(
        uint256 index
    ) external view returns (bytes32 ret) {
        uint256 slot;
        assembly {
            slot := smallArray.slot
        }

        bytes32 location = keccak256(abi.encode(slot));
        assembly {
            ret := sload(add(location, index))
        }
    }

    function getMapping(uint256 key) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := myMapping.slot
        }
        bytes32 location = keccak256(abi.encode(key, uint256(slot)));
        assembly {
            ret := sload(location)
        }
    }

    function getNestedMapping(
        uint256 key1,
        uint256 key2
    ) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := nestedMapping.slot
        }
        bytes32 location = keccak256(
            abi.encode(
                uint256(key2),
                keccak256(abi.encode(uint256(key1), uint256(slot)))
            )
        );
        assembly {
            ret := sload(location)
        }
    }

    function getLengthOfNestedList() external view returns (uint256 ret) {
        uint256 addressToListSlot;
        assembly {
            addressToListSlot := addressToList.slot
        }
        bytes32 location = keccak256(
            abi.encode(
                address(0x88c6C46EBf353A52Bdbab708c23D0c81dAA8134A),
                uint256(addressToListSlot)
            )
        );
        assembly {
            ret := sload(location)
        }
    }

    function getAddressToList(
        uint256 index
    ) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := addressToList.slot
        }
        bytes32 location = keccak256(
            abi.encode(
                keccak256(
                    abi.encode(
                        address(0x88c6C46EBf353A52Bdbab708c23D0c81dAA8134A),
                        uint256(slot)
                    )
                )
            )
        );
        assembly {
            ret := sload(add(location, index))
        }
    }
}

contract YulArrayMappingTest is Test {
    StorageComplex storageComplex;

    function setUp() public {
        storageComplex = new StorageComplex();
    }

    function test_get_fixed_array() public {
        uint256 ret = storageComplex.fixedArrayView(2);
        console2.log("ret", ret);
    }

    function test_get_big_array() public {
        uint256 ret = storageComplex.bigArrayLength();
        console2.log("ret", ret);
    }

    function test_get_big_array_location() public {
        uint256 ret = storageComplex.readBigArrayLocation(2);
        console2.log("ret", ret);
    }

    function test_get_small_array() public {
        uint256 ret = storageComplex.readSmallArray();
        console2.log("ret", ret);
    }

    function test_get_small_array_location() public {
        bytes32 ret = storageComplex.readSmallArrayLocation(0);
        console2.logBytes32(ret);
    }

    function test_get_mapping() public {
        uint256 ret = storageComplex.getMapping(11);
        console2.log("ret", ret);
    }

    function test_get_nested_mapping() public {
        uint256 ret = storageComplex.getNestedMapping(2, 4);
        console2.log("ret", ret);
    }

    function test_get_length_of_nested_list() public {
        uint256 ret = storageComplex.getLengthOfNestedList();
        console2.log("ret", ret);
    }

    function test_get_address_to_list() public {
        uint256 ret = storageComplex.getAddressToList(0);
        console2.log("ret", ret);
    }
}
