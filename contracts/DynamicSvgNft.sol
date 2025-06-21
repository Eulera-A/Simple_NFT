// DynamicSvgNft.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "base64-sol/base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DynamicSvgNft is ERC721 {
    // mint
    // store our SVG info somewhere
    // some logic

    uint256 private s_tokenCounter;
    string private i_lowImageURI;
    string private i_highImageURI;
    string private constant base64EncodedSvgPrefix =
        "data:image/svg+xml;base64";
    AggregatorV3Interface internal immutable i_priceFeed;

    // mapping storage for NFT token and its value:
    // its like calling the map as s_tokenIdToHighValue, where tokenId is the key to highValue
    mapping(uint256 => int256) public s_tokenIdToHighValue;
    event createNFT(uint256 indexed token, int256 highValue);

    constructor(
        string memory lowSvg,
        string memory highSvg,
        address priceFeedAddress
    ) ERC721("Dynamic SVG NFT", "DSN") {
        s_tokenCounter = 0;
        i_lowImageURI = svgToImageURI(lowSvg);
        i_highImageURI = svgToImageURI(highSvg);
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function svgToImageURI(
        string memory svg
    ) public pure returns (string memory) {
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return
            string(abi.encodePacked(base64EncodedSvgPrefix, svgBase64Encoded));

        //youtube 22:32:38
    }

    function mintNft(uint256 highValue) public {
        // this function allows minter to mint a new nft,
        // input: value, the value set for his nft
        s_tokenIdToHighValue[s_tokenCounter] = highValue;

        // 23:13:26
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        emit createNFT(s_tokenCounter, highValue);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(
        // this function assigns NFT TokenID to the NFT token item (in this case, an image uri)
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "URI Query for nonexistent token");
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        string memory imageURI = i_lowImageURI;

        if (price >= s_tokenIdToHighValue[tokenId]) {
            // which is determined by the minter what price they want to use
            // this high-priced image
            imageURI = i_highImageURI;
        }
        //string memory imageURI = ""; // this is the uri we get from the svgToImageURI stuff
        return
            //: return all those encoded stuff in string
            //need to have a string of this whole stuff:
            string(
                // need to append the _baseURIL with the image package uri
                // using the abi.encodePacked(base,imageuri) function

                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        // give the binary code of the image (shown by image uri)

                        bytes(
                            // concatenate all those info in packed form
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '","description":"An NFT that changes based on the chainLink Feed",',
                                '"attributes":[{"trait_type":"coolness","value":100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                ) // end abi.encode for concat(base,imageuri)
            ); //end string ()
    }
} //23:08:05
