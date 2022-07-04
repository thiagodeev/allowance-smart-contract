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

    /////////////////////View Functions
    function getTotalBalance() public onlyOwner view returns(uint totalBalance){
        return _totalBalance;
    }
    function getMyBalance() public view returns(uint myBalance) {
        return _user[msg.sender].myBalance;
    }
    function getAllMyAllowanceBalances() public view returns(uint allMyAllowanceBalances){
        return _user[msg.sender].allMyAllowanceBalances;
    }
    function getMyAllowanceBalanceIn(address _allowner) public view returns(uint getMyAllowanceBalance){
        return _user[msg.sender].balances[_allowner];
    }
    ///////////////////////////////////

    function giveAllowance(address _to, uint _duration, uint _amount) public {
        require(_to != msg.sender, "You can't give an allowance to yourself.");
        require(_user[_to].balances[msg.sender] >= _amount, "Insufficient funds.");

        setAllowanceTime(_to, _duration);
        _user[_to].allowances[msg.sender].value = _amount;
        commonBodyToAllowanceFunctions(_to, _amount);
    }

    function payAndGiveAllowance(address _to, uint _duration) public payable {
        require(_to != msg.sender, "You can't give an allowance to yourself.");

        receiveMoney(_to);
        setAllowanceTime(_to, _duration);
        _user[_to].balances[msg.sender] = _user[_to].balances[msg.sender] + (_user[_to].allowances[msg.sender].value = msg.value);
        commonBodyToAllowanceFunctions(_to, msg.value);
    }

    function transferAndGiveAllowance(address _to, uint _duration, uint _amount) public {
        require(_to != msg.sender, "You can't give an allowance to yourself.");

        decreaseMoney(msg.sender, _amount);
        setAllowanceTime(_to, _duration);
        _user[_to].balances[msg.sender] = _user[_to].balances[msg.sender] + (_user[_to].allowances[msg.sender].value = _amount);
        commonBodyToAllowanceFunctions(_to, _amount);
    }

    function commonBodyToAllowanceFunctions(address _to, uint _amount) internal {
        _user[msg.sender].allMyAllowanceBalances = _user[msg.sender].allMyAllowanceBalances + _amount;

        emit AllowanceSucceed(
            _user[_to].allowances[msg.sender].index,
            _user[_to].allowances[msg.sender].timestamp,
            _user[_to].allowances[msg.sender].duration,
            _user[_to].allowances[msg.sender].value,
            _user[_to].allowances[msg.sender].from
        );

        _user[_to].allowances[msg.sender].index ++;
    }

    function setAllowanceTime(address _to, uint _duration) internal {
        _user[_to].allowances[msg.sender].timestamp = block.timestamp;
        _user[_to].allowances[msg.sender].duration = _duration;
    }

    function depositMoney() public payable {
        receiveMoney(msg.sender);
    }

    function receiveMoney(address _to) internal {
        _totalBalance = _totalBalance + msg.value;
        _user[_to].balances[_to] = _user[_to].balances[_to] + msg.value;
    }

    function decreaseMoney(address _address, uint _amount) public payable {
        require(_user[_address].myBalance >= _amount, "Insufficient funds.");

        _user[_address].myBalance = _user[_address].myBalance - _amount;
        _totalBalance = _totalBalance - _amount;
    }

    function withdraw (uint _amount) public {
        decreaseMoney(msg.sender, _amount);

        payable(msg.sender).transfer(_amount);
    }


    receive() external payable {
        receiveMoney(msg.sender);
    }
}