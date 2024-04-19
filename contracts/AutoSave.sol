// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AutoSaver {
    address public owner;
    
    mapping(address => uint256) public manualBalances; 
    mapping(address => uint256) public automatedBalances; 
    mapping(address => uint256) public lastAutoWithdraw; 
    mapping(address => uint256) public lastAutoDeposit; 
    mapping(address => uint256) public totalManualDeposits; 
    mapping(address => uint256) public totalManualWithdrawals; 
    mapping(address => uint256) public totalAutoDeposits; 
    mapping(address => uint256) public totalAutoWithdrawals; 
    mapping(address => bool) public autoWithdrawEnabledFor; 
    mapping(address => bool) public autoDepositEnabledFor; 
    mapping(address => uint256) public endWithdrawDateFor; 
    mapping(address => uint256) public endDepositDateFor; 
    mapping(address => uint256) public autoWithdrawTimeFor; 
    mapping(address => uint256) public autoDepositTimeFor; 
    
    uint256 public withdrawalAmount;
    uint256 public depositAmount;
    address public tokenAddress;

    event Deposit(address indexed _from, uint256 _amount);
    event Withdrawal(address indexed _to, uint256 _amount);
    event AutoWithdrawSet(uint256 _seconds);
    event AutoDepositSet(uint256 _seconds);
    event LogInfo(string message, uint256 value);
    event TotalBalanceUpdated(address indexed _address, uint256 _totalBalance);

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
    }

    function setAutoWithdrawTime(uint256 _seconds) external {
        autoWithdrawTimeFor[msg.sender] = _seconds;
        endWithdrawDateFor[msg.sender] = block.timestamp + _seconds;
        emit LogInfo("Time Stamp", block.timestamp);
        emit AutoWithdrawSet(_seconds);
    }

    function setAutoDepositTime(uint256 _seconds) external {
        autoDepositTimeFor[msg.sender] = _seconds;
        endDepositDateFor[msg.sender] = block.timestamp + _seconds;
        emit LogInfo("Time Stamp", block.timestamp);
        emit AutoDepositSet(_seconds);
    }

    function withdraw(uint256 _amount) external {
        require(_amount <= manualBalances[msg.sender], "Insufficient manual balance");
        
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(msg.sender, _amount), "Transfer failed");
        
        manualBalances[msg.sender] -= _amount;
        
        emit Withdrawal(msg.sender, _amount);
        
        emit TotalBalanceUpdated(msg.sender, getTotalBalance(msg.sender));
    }

    function enableAutoWithdraw(uint256 _withdrawalAmount) external {
        autoWithdrawEnabledFor[msg.sender] = true;
        withdrawalAmount = _withdrawalAmount;
    }

    function disableAutoWithdraw() external {
        autoWithdrawEnabledFor[msg.sender] = false;
    }

    function enableAutoDeposit(uint256 _depositAmount) external {
        autoDepositEnabledFor[msg.sender] = true;
        depositAmount = _depositAmount;
    }

    function disableAutoDeposit() external {
        autoDepositEnabledFor[msg.sender] = false;
    }

    function deposit(uint256 _amount) external {
        IERC20 token = IERC20(tokenAddress);
        
     
        if (autoDepositEnabledFor[msg.sender] && block.timestamp >= endDepositDateFor[msg.sender]) {
            require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
            
            automatedBalances[msg.sender] += _amount;
            
            emit Deposit(msg.sender, _amount);
            
           
            autoDepositEnabledFor[msg.sender] = false;
            emit LogInfo("Auto deposit disabled", 0);
            
            emit TotalBalanceUpdated(msg.sender, getTotalBalance(msg.sender));
            
            return;
        }

      
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        manualBalances[msg.sender] += _amount;
        
        emit Deposit(msg.sender, _amount);
        
        emit TotalBalanceUpdated(msg.sender, getTotalBalance(msg.sender));
    }

    function checkAutoActions() external {
        if (autoWithdrawEnabledFor[msg.sender] && block.timestamp >= endWithdrawDateFor[msg.sender]) {
            performAutoWithdraw();
        }
        
        if (autoDepositEnabledFor[msg.sender] && block.timestamp >= endDepositDateFor[msg.sender]) {
            performAutoDeposit();
        }
    }

    function performAutoWithdraw() internal {
    require(withdrawalAmount <= automatedBalances[msg.sender], "Insufficient automated balance");
    
    IERC20 token = IERC20(tokenAddress);
    require(token.transfer(owner, withdrawalAmount), "Transfer failed");
    
    automatedBalances[msg.sender] -= withdrawalAmount;
    
    emit Withdrawal(owner, withdrawalAmount);
    
    emit TotalBalanceUpdated(msg.sender, getTotalBalance(msg.sender));

    autoWithdrawEnabledFor[msg.sender] = false; // Disable auto withdraw after performing it
}

function performAutoDeposit() internal {
    IERC20 token = IERC20(tokenAddress);
    require(token.transferFrom(msg.sender, address(this), depositAmount), "Transfer failed");
    
    automatedBalances[msg.sender] += depositAmount;
    
    emit Deposit(msg.sender, depositAmount);
    
    emit TotalBalanceUpdated(msg.sender, getTotalBalance(msg.sender));

    autoDepositEnabledFor[msg.sender] = false; // Disable auto deposit after performing it
}

    function getTotalBalance(address _address) public view returns (uint256) {
        return manualBalances[_address] + automatedBalances[_address];
    }

    receive() external payable {
        revert("Contract does not accept Ether directly");
    }
}