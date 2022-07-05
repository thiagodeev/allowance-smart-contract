// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract WalletChallenge is Ownable {
    uint internal _totalBalance;

    struct User {
        uint myBalance;
        uint allMyAllowanceBalances;
        mapping (address => uint) balances;
        mapping (address => Allowances) allowances;
    }
    struct Allowances {
        uint index;
        uint timestamp;
        uint duration;
        uint value;
        address from;
    }

    mapping (address => User) internal _user;

    event AllowanceSucceed(
        uint indexed _index,
        uint indexed _timestamp,
        uint _duration,
        uint _value,
        address indexed _from
    );

    /////////////////////Modifiers
    modifier AllowanceFunction (address _to) {
        require(_to != msg.sender, "You can't give an allowance to yourself.");
        
        _;

        _user[_to].allowances[msg.sender].from = msg.sender;
        emit AllowanceSucceed(
            _user[_to].allowances[msg.sender].index,
            _user[_to].allowances[msg.sender].timestamp,
            _user[_to].allowances[msg.sender].duration,
            _user[_to].allowances[msg.sender].value,
            _user[_to].allowances[msg.sender].from
        );
        _user[_to].allowances[msg.sender].index ++;
    }
    modifier verifiesRemainingTime (address _allowner) {
        require(block.timestamp < _user[msg.sender].allowances[_allowner].timestamp + _user[msg.sender].allowances[_allowner].duration, "Your allowed time has ended.");
        _;
    }
    //////////////////////////////

    /////////////////////Only Owner
    function getTotalBalance() public onlyOwner view returns(uint totalBalance){
        return _totalBalance;
    }
    ///////////////////////////////

    /////////////////////View Functions
    function getMyBalance() public view returns(uint myBalance) {
        return _user[msg.sender].myBalance;
    }
    function getAllMyAllowanceBalances() public view returns(uint allMyAllowanceBalances){
        return _user[msg.sender].allMyAllowanceBalances;
    }
    function getMyAllowanceBalanceFrom(address _allowner) public view returns(uint getMyAllowanceBalance){
        return _user[msg.sender].balances[_allowner];
    }
    function getMyAllowanceFrom(address _allowner) public view returns(uint index, uint timestamp, uint duration, uint blockTimestamp, uint value){
        return (
            _user[msg.sender].allowances[_allowner].index - 1,
            _user[msg.sender].allowances[_allowner].timestamp,
            _user[msg.sender].allowances[_allowner].duration,
            block.timestamp,
            _user[msg.sender].allowances[_allowner].value
        );
    }
    function getMyAllowanceRemainingTime(address _allowner) public view verifiesRemainingTime(_allowner) returns(uint remainingTime){
        return (_user[msg.sender].allowances[_allowner].timestamp + _user[msg.sender].allowances[_allowner].duration) - block.timestamp;
    }
    ///////////////////////////////////

    /////////////////////Allowance Functions
    function giveAllowance(address _to, uint _duration, uint _amount) public AllowanceFunction(_to) {
        require(_user[_to].balances[msg.sender] >= _amount, "Insufficient allowed funds.");

        setAllowanceTime(_to, _duration);
        _user[_to].allowances[msg.sender].value = _amount;
        _user[_to].allMyAllowanceBalances = _user[_to].allMyAllowanceBalances + _amount;
    }

    function payAndGiveAllowance(address _to, uint _duration) public payable AllowanceFunction(_to){
        receiveMoney(_to);
        setAllowanceTime(_to, _duration);
        _user[_to].balances[msg.sender] = _user[_to].balances[msg.sender] + (_user[_to].allowances[msg.sender].value = msg.value);
        _user[_to].allMyAllowanceBalances = _user[_to].allMyAllowanceBalances + msg.value;
    }

    function transferAndGiveAllowance(address _to, uint _duration, uint _amount) public AllowanceFunction(_to){
        decreaseMoneyFromMyBalance(msg.sender, _amount);
        setAllowanceTime(_to, _duration);
        _user[_to].balances[msg.sender] = _user[_to].balances[msg.sender] + (_user[_to].allowances[msg.sender].value = _amount);
        _user[_to].allMyAllowanceBalances = _user[_to].allMyAllowanceBalances + _amount;
    }
    /////////////////////////////////////////

    /////////////////////Internal Functions
    function setAllowanceTime(address _to, uint _duration) internal {
        _user[_to].allowances[msg.sender].timestamp = block.timestamp;
        _user[_to].allowances[msg.sender].duration = _duration;
    }

    function receiveMoney(address _to) internal {
        _totalBalance = _totalBalance + msg.value;
        _user[_to].myBalance = _user[_to].myBalance + msg.value;
    }
    function decreaseMoneyFromMyBalance(address _address, uint _amount) internal {
        require(_user[_address].myBalance >= _amount, "Insufficient funds.");

        _user[_address].myBalance = _user[_address].myBalance - _amount;
    }
    function verifyRemainingTime(address _allowner) internal view{
        require(block.timestamp < _user[msg.sender].allowances[_allowner].timestamp + _user[msg.sender].allowances[_allowner].duration, "Your allowed time has ended.");
    }
    ////////////////////////////////////////

    function depositMoney() public payable {
        receiveMoney(msg.sender);
    }

    function withdrawFromMyBalance (uint _amount) public {
        decreaseMoneyFromMyBalance(msg.sender, _amount);
        _totalBalance = _totalBalance - _amount;

        payable(msg.sender).transfer(_amount);
    }

    function withdrawFromAllowance (address _allowner, uint _amount) public verifiesRemainingTime(_allowner) {
        require((_user[msg.sender].allowances[_allowner].value >= _amount) && (_user[msg.sender].balances[_allowner] >= _amount), "Insufficient allowed funds.");

        _user[msg.sender].balances[_allowner] = _user[msg.sender].balances[_allowner] - _amount;
        _user[msg.sender].allMyAllowanceBalances = _user[msg.sender].allMyAllowanceBalances - _amount;
        _totalBalance = _totalBalance - _amount;

        payable(msg.sender).transfer(_amount);
    }


    receive() external payable {
        receiveMoney(msg.sender);
    }
}