// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Encoding {
    function combineStrings() public pure returns (string memory) {
        return string(abi.encodePacked("Hi Mom!", "Miss you!"));
    }

    function encodeNumber(uint256 NUM) public pure returns (bytes memory) {
        bytes memory number = abi.encode(NUM);
        return number;
    }

    function encodeString(
        string memory STR
    ) public pure returns (bytes memory) {
        bytes memory number = abi.encode(STR);
        return number;
    }

    function decodeString() public pure returns (string memory) {
        string memory someString = abi.decode(
            encodeString("hi MOM!"),
            (string)
        );
        return someString;
    }

    function multiEncode() public pure returns (bytes memory) {
        bytes memory someString = abi.encode("some String", "it's bigger!!");

        return someString;
    }

    function multiDecode() public pure returns (string memory, string memory) {
        (string memory someString, string memory otherString) = abi.decode(
            multiEncode(),
            (string, string)
        );
        return (someString, otherString);
    }
}
