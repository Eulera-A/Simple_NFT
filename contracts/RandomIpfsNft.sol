// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "hardhat/console.sol";


//errors

error RandomIpfsNft__RangeOutOfBounds;
error RandomIpfsNft__NeedMoreETHSent;
error RandomIpfsNft__TransferFailed;

contract RandomIpfsNft is ERC721URIStorage, VRFConsumerBaseV2, Ownable{

//Type Declaration
enum Breed{
    PUG,
    SHIBA_INU,
    ST_BERNARD
}


// types of nft
enum Breed {
    PUG,
    SHIBA_INU,
    ST_BERNARD
}

// Chainlink VRF Variables
// variable_type, privacy, ommutability, variable_name
VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
uint64 private immutable i_subscriptionId;
bytes32 private immutable i_gasLane;
uint32 private immutable i_callbackGasLimit;
uint16 private constant REQUEST_CONFIRMATIONS = 3;
uint32 private constant NUM_WORDS = 1;

// VRF helpers:
// mapping of requestId to the person who requested it for his dog
// the array stores (Id,address) as a pair 
mapping(uint256 => address) public s_requestIdToSender;

// NFT Variables 
uint256 private immutable i_mintFee
uint256 public s_tokenCounter
uint256 internal constant MAX_CHANCE_VALUE = 100;
string[] internal s_dogTokenUris;
bool private s_initialized;

//Events:
event NftRequested(uint256 indexed requested, address requester);
event NftMinted(Breed dogBreed, address minter)

constructor(// declare constructor,
        // input : type, variable name
    address vrfCoordinatorV2,
    uint64 subscriptionId,
    bytes32 gasLane,
    uint32 callbackGasLimit,
    string[3] memory dogTokenUris,
    uint256 mintFee 
) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT","RIN"){
    // updates contract variables i_ using the inputs from the constructor:
    i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
    i_subscriptionId = subscriptionId;
    i_gasLane = gasLane;
    i_callbackGasLimit = callbackGasLimit;
    i_mintFee = mintFee;
}

// this function is the stuff using vrf contract request random number!!!
// and we need to make it charging gas from the one who request to mint!
function requestNft() public payable returns (uint256 requestId){
    if (msg.value < i_mintFee){
        revert RandomIpfsNft__NeedMoreETHSent();
    }
    
    requestId = i_vrfCoordinator.requestRandomWords(
        i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
    )
    s_requestIdToSender[requestId] = msg.sender;
    emit NftRequested(requestId,msg.sender);
}

function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{
    address dogOwner = s_requestIdToSender[requestId];
    uint256 newTokenId = s_tokenCounter;

    uint256 moddedRng = randomWords[0]% MAX_CHANCE_VALUE;
    // mod 100 classes, 0 to 99 yushu
    // 0-10 -> pug
    // >10-30 -> shiba inu
    // >30 -> st bernard 
      Breed dogBreed = getBreedFromModdedRng(moddedRng);
      s_tokenCounter += s_tokenCounter;
      _safeMint(dogOwner,newTokenId);
      _setTokenURI(newTokenId,s_dogTokenUris[uint256(dogBreed)]);
      emit NftMinted(dogBreed,dogOwner)
} 

function withdraw() public onlyOwner{
    uint256 amount = address(this).balance;
    (bool success,) = payable(msg.sender).call{value:amount}("");
    if(!success) {revert RandomIpfsNft__TransferFailed()}
}

function getBreedFromModdedRng(uint256 moddedRng) public pure returns (Breed){
 uint256 cumulativeSum = 0;
 uint256[3] memory chanceArray = getChanceArray();
 for(uint256 i = 0; i<chanceArray.length; i++){
   if(moddedRng >= cumulativeSum && moddedRng< cumulativeSum+chanceArray[i])
   {//true: return the current ith doggie
      return Breed(i)}
   //else: go to the next interval 
   cumulativeSum += chanceArray[i];
   

 }
 revert RandomIpfsNft__RangeOutOfBounds;
}

function getChanceArray() public pure returns(uint256[3] memory)
return [10,30,MAX_CHANCE_VALUE];

function getMintFee() public view returns(uint256){
    return i_mintFee;
}

function getDogTokenUris(uint256 index) public view returns(stirng memory){
    return s_dogTokenUris[index];
}

function getTokenCounter() public view returns(uint256){
    return s_tokenCounter;
}

}