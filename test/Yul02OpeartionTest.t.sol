// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

contract YulOpeartionTest is Test {
    function testPrime() public {
        require(isPrime(2));
        require(isPrime(3));
        require(!isPrime(4));
        require(!isPrime(15));
        require(isPrime(23));
        require(isPrime(101));
    }

    function isPrime(uint256 x) public pure returns (bool p) {
        p = true;
        assembly {
            let halfX := add(div(x, 2), 1)
            let i := 2
            for {

            } lt(i, halfX) {

            } {
                if iszero(mod(x, i)) {
                    p := 0
                    break
                }

                i := add(i, 1)
            }
        }
    }

    function isTruthy() internal pure returns (uint256 result) {
        result = 2;
        assembly {
            if 2 {
                result := 1
            }
        }

        return result; // returns 1
    }
    function isFalsy() internal pure returns (uint256 result) {
        result = 1;
        assembly {
            if 0 {
                result := 2
            }
        }

        return result; // returns 1
    }

    function negation() internal pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(0) {
                result := 2
            }
        }

        return result; // returns 2
    }

    function unsafe1NegationPart1() internal pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(0) {
                result := 2
            }
        }

        return result; // returns 2
    }

    function bitFlip() internal pure returns (bytes32 result) {
        assembly {
            result := not(2)
        }
    }

    function unsafe2NegationPart() internal pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(2) {
                result := 2
            }
        }

        return result; // returns 2
    }

    function safeNegation() internal pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(2) {
                result := 2
            }
        }

        return result; // returns 1
    }   

    function max(uint256 x, uint256 y) internal pure returns (uint256 maximum) {
        assembly {
            if lt(x, y) {
                maximum := y
            }

            if iszero(lt(x, y)) {
                // there are no else statements
                maximum := x
            }
        }
    }




    function testIsTruthy() public {
        uint256 result = isTruthy();
        console2.log("result isTruthy : %s", result);

        result = isFalsy();
        console2.log("result isFalsy : %s", result);

        result = negation();
        console2.log("result negation : %s", result);

        result = unsafe1NegationPart1();
        console2.log("result unsafe1NegationPart1 : %s", result);

        bytes32 result2 = bitFlip();
        console2.logBytes32( result2);

        result = unsafe2NegationPart();
        console2.log("result unsafe2NegationPart : %s", result);

        result = safeNegation();
        console2.log("result safeNegation : %s", result);

        result = max(3, 2);
        console2.log("result max : %s", result);

    }


}

