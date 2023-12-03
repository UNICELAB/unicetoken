/*
© 2023 Unice Lab Pte. Ltd <admin@unicelab.io>
*/

// SPDX-License-Identifier: No License

pragma solidity 0.8.7;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";
import "./TokenRecover.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router01.sol";
import "./IUniswapV2Router02.sol";

contract UNICE is ERC20, ERC20Burnable, Ownable, TokenRecover {

    struct Timelock {
        uint256 amount;
        uint256 releaseTime;
    }

    uint256 public INITIAL_SUPPLY = 1e9 * (10 ** decimals());

    address SUPPLY_RECIPIENT = 0x2Fd50519d4452678AB1D652ae92Eb18DE7609E42;
    address OWNER_ADDRESS = 0x2Fd50519d4452678AB1D652ae92Eb18DE7609E42;
    address UNISWAP_ROUTER_V2 = 0x8954AfA98594b838bda56FE4C12a09D7739D179b;

    // address of stakeholders
    address public team = 0x766578Ef06260EB5f9805BE44B1E8C4a6DEE9CE2;
    address public advisor = 0xaD9379EAA0D7aA0f22e6d7921098e1E125e3675a;
    address public marketing = 0x6996d39071008ceA280202eE899D2fE107665e58;
    address public privateSale = 0x83Df24F6D3a88E1c0AeEFbc9271768ABC9E911F0;
    address public staking = 0xb6f52e2ac66337204669196A2A5C749DdaBD77c0;
    address public medicalReward = 0xB491Ad13D1835a711E0514BC791007DA19D447c3;
    address public userReward = 0xcCF10fD71210422B148Cb3E35Ab3884a56648690;

    mapping(address => uint256) public total_transfer;

    // year-wise lockup release amount for the team
    uint256[] public teamUnlockAmountEveryYear = [
        ((0 * INITIAL_SUPPLY) / 1000), // a total of 0% in the first year
        ((0 * INITIAL_SUPPLY) / 1000), // a total of 0% in the second year 
        ((3 * INITIAL_SUPPLY) / 1000), // a total of 0.3% in the third year
        ((6 * INITIAL_SUPPLY) / 1000), // a total of 0.6% in the fourth year -> 0.3 + 0.3 = 0.6
        ((9 * INITIAL_SUPPLY) / 1000), // a total of 0.9% in the fifth year
        ((12 * INITIAL_SUPPLY) / 1000), // a total of 1.2% in the sixth year
        ((15 * INITIAL_SUPPLY) / 1000), // a total of 1.5% in the seventh year
        ((20 * INITIAL_SUPPLY) / 1000), // a total of 2.0% in the eighth year
        ((25 * INITIAL_SUPPLY) / 1000), // a total of 2.5% in the ninth year
        ((30 * INITIAL_SUPPLY) / 1000) // a total of 3.0% in the tenth year
    ];

    // year-wise lockup release amount for the advisor
    uint256[] public advisorUnlockAmountEveryYear = [
        ((0 * INITIAL_SUPPLY) / 1000), 
        ((5 * INITIAL_SUPPLY) / 1000),  
        ((10 * INITIAL_SUPPLY) / 1000), 
        ((15 * INITIAL_SUPPLY) / 1000), 
        ((20 * INITIAL_SUPPLY) / 1000), 
        ((25 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000),  
        ((34 * INITIAL_SUPPLY) / 1000), 
        ((37 * INITIAL_SUPPLY) / 1000), 
        ((40 * INITIAL_SUPPLY) / 1000)
    ];

    // year-wise lockup release amount for marketing
    uint256[] public marketingUnlockAmountEveryYear = [
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000),  
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000),  
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000)
    ];

    // year-wise lockup release amount for private sale
    uint256[] public privateSaleUnlockAmountEveryYear = [
        ((30 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000),  
        ((30 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000),  
        ((30 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000)
    ];

    // year-wise lockup release amount for staking
    uint256[] public stakingUnlockAmountEveryYear = [
        ((20 * INITIAL_SUPPLY) / 1000), 
        ((30 * INITIAL_SUPPLY) / 1000),  
        ((40 * INITIAL_SUPPLY) / 1000), 
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((60 * INITIAL_SUPPLY) / 1000), 
        ((70 * INITIAL_SUPPLY) / 1000), 
        ((80 * INITIAL_SUPPLY) / 1000),  
        ((90 * INITIAL_SUPPLY) / 1000), 
        ((95 * INITIAL_SUPPLY) / 1000), 
        ((100 * INITIAL_SUPPLY) / 1000)
    ];

    // year-wise lockup release amount for medical reward
    uint256[] public medicalRewardUnlockAmountEveryYear = [
        ((50 * INITIAL_SUPPLY) / 1000), 
        ((100 * INITIAL_SUPPLY) / 1000),  
        ((125 * INITIAL_SUPPLY) / 1000), 
        ((150 * INITIAL_SUPPLY) / 1000), 
        ((175 * INITIAL_SUPPLY) / 1000), 
        ((200 * INITIAL_SUPPLY) / 1000), 
        ((212 * INITIAL_SUPPLY) / 1000),  
        ((224 * INITIAL_SUPPLY) / 1000), 
        ((236 * INITIAL_SUPPLY) / 1000), 
        ((250 * INITIAL_SUPPLY) / 1000)
    ];

    // year-wise lockup release amount for user reward
    uint256[] public userRewardUnlockAmountEveryYear = [
        ((100 * INITIAL_SUPPLY) / 1000), 
        ((150 * INITIAL_SUPPLY) / 1000),  
        ((200 * INITIAL_SUPPLY) / 1000), 
        ((250 * INITIAL_SUPPLY) / 1000), 
        ((300 * INITIAL_SUPPLY) / 1000), 
        ((350 * INITIAL_SUPPLY) / 1000), 
        ((400 * INITIAL_SUPPLY) / 1000),  
        ((450 * INITIAL_SUPPLY) / 1000), 
        ((475 * INITIAL_SUPPLY) / 1000), 
        ((500 * INITIAL_SUPPLY) / 1000)
    ];

    // 
    mapping(address => Timelock[]) timelocks;

    IUniswapV2Router02 public routerV2;
    address public pairV2;
    mapping (address => bool) public AMMPairs;

    event RouterV2Updated(address indexed routerV2);
    event AMMPairsUpdated(address indexed AMMPair, bool isPair);

    constructor()
        ERC20(unicode"UNICE", unicode"UNICE")
    {
        _updateRouterV2(UNISWAP_ROUTER_V2);

        _mint(SUPPLY_RECIPIENT, INITIAL_SUPPLY);
        _transferOwnership(OWNER_ADDRESS);

        // initializing timelocks for the team
        initializeTokenTimelocks(team, teamUnlockAmountEveryYear);

        // initializing timelocks for the advisor
        initializeTokenTimelocks(advisor, advisorUnlockAmountEveryYear); 

        // initializing timelocks for marketing
        initializeTokenTimelocks(marketing, marketingUnlockAmountEveryYear);

        // initializing timelocks for private sale
        initializeTokenTimelocks(privateSale, privateSaleUnlockAmountEveryYear);

        // initializing timelocks for staking
        initializeTokenTimelocks(staking, stakingUnlockAmountEveryYear);

        // initializing timelocks for medical reward
        initializeTokenTimelocks(medicalReward, medicalRewardUnlockAmountEveryYear);

        // initializing timelocks for user reward
        initializeTokenTimelocks(userReward, userRewardUnlockAmountEveryYear);
    
    }

    receive() external payable {}

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function _updateRouterV2(address router) private {
        routerV2 = IUniswapV2Router02(router);
        pairV2 = IUniswapV2Factory(routerV2.factory()).createPair(address(this), routerV2.WETH());

        _setAMMPair(pairV2, true);

        emit RouterV2Updated(router);
    }

    function setAMMPair(address pair, bool isPair) public onlyOwner {
        require(pair != pairV2, "DefaultRouter: Cannot remove initial pair from list");

        _setAMMPair(pair, isPair);
    }

    function _setAMMPair(address pair, bool isPair) private {
        AMMPairs[pair] = isPair;

        if (isPair) {
        }

        emit AMMPairsUpdated(pair, isPair);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override
    {
        super._afterTokenTransfer(from, to, amount);
    }

    // Override the transfer function
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if (msg.sender == OWNER_ADDRESS) {
            require(validateLockup(recipient, amount), "Please wait for the next token release");
            total_transfer[recipient] += amount;
        }
        
        // Call the parent ERC20 transfer function
        return super.transfer(recipient, amount);

    }

    // Override the transfer function
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns(bool) {

        if (msg.sender == OWNER_ADDRESS) {
            require(validateLockup(recipient, amount), "Please wait for the next token release");
            total_transfer[recipient] += amount;
        }

        // Call the parent ERC20 transfer function
        return super.transferFrom(sender, recipient, amount);

    }

    function validateLockup(address recipient, uint256 amount) internal returns(bool) {

        Timelock[] memory locksForReicipient = timelocks[recipient];

        require(locksForReicipient.length > 0, "Address not allowed");

        for (uint256 i = 0; i < locksForReicipient.length; i++) {
            if (i != locksForReicipient.length - 1) {
                if (locksForReicipient[i].releaseTime < block.timestamp && block.timestamp < locksForReicipient[i+1].releaseTime) {
                    uint256 cumulativeBalance = total_transfer[recipient] + amount;
                    require(cumulativeBalance <= locksForReicipient[i].amount, "Cannot transfer more tokens to this address" );
                }
            }
            else {
                if (locksForReicipient[i].releaseTime < block.timestamp) {
                    uint256 cumulativeBalance = total_transfer[recipient] + amount;
                    require(cumulativeBalance <= locksForReicipient[i].amount, "Cannot transfer more tokens to this address" );
                }
            }
        }

        return true;
    }

    // Function to initialize the timelocks
    function initializeTokenTimelocks(address recipient, uint256[] memory unlockAmountsEveryYear) internal {

        uint256 releaseTime; 

        for (uint256 i = 0; i < unlockAmountsEveryYear.length; i++) {
            releaseTime = block.timestamp + (i * 365 days);
            // Create a new Timelock structure
            Timelock memory newTimelock = Timelock({
                amount: unlockAmountsEveryYear[i],
                releaseTime: releaseTime
            });

            timelocks[recipient].push(newTimelock);
        }

        total_transfer[recipient] = 0;
        
    }
}
