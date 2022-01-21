// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./Ownable.sol";

contract LMSDistro is Ownable {
    using SafeMath for uint256;
    
    address public LMSWallet;
    address public ADAToken;
    
    uint256 public numberEligible;
    uint256 public amountToSend;
    uint256 public iterationsProcessed;

    mapping (address => uint256) public numberOfDistros;

    mapping (address => uint256) public totalPaid;
    
    constructor() {
        
    }
    
    function setAdaToken(address _token) external onlyOwner {
        ADAToken = _token;
    }
    
    function setLMSWallet(address _wallet) external onlyOwner {
        LMSWallet = _wallet;
    }
    
    function setEligible(uint256 _numberEligible) external onlyOwner {
        uint256 totalAmount = IERC20(ADAToken).balanceOf(LMSWallet);
        numberEligible = _numberEligible;
        amountToSend = totalAmount.div(numberEligible);
        iterationsProcessed = 0;
    }
    
    function distributeLMS(address[] calldata _eligible) external onlyOwner {
        require(iterationsProcessed.add(_eligible.length) <= numberEligible, "ATTEMPTING TO SEND TOO MANY");
        
        for(uint256 i = 0; i < _eligible.length; i++) {
            iterationsProcessed = iterationsProcessed + 1;
            numberOfDistros[_eligible[i]] = numberOfDistros[_eligible[i]] + 1;
            totalPaid[_eligible[i]] = totalPaid[_eligible[i]] + amountToSend;
            IERC20(ADAToken).transferFrom(LMSWallet, _eligible[i], amountToSend);
        }
        
        if(iterationsProcessed == numberEligible) {
            iterationsProcessed = 0;
            numberEligible = 0;
            amountToSend = 0;
        }
        
    }
    
    
}
