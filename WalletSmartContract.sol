// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract WalletChallenge is Ownable {
    uint internal _totalBalance;
    uint internal _redeemedMoneyEventIndex;

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
    }

    mapping (address => User) internal _user;

    /////////////////////Events
    event AllowanceSucceed(
        uint indexed _index,
        uint indexed _timestamp,
        uint _duration,
        uint _value,
        address _from,
        address indexed _to
    );
    event AllowanceRevoked(
        uint indexed _index,
        uint indexed _timestamp,
        address _from,
        address indexed _to,
        uint _redeemedValue
    );
    event MoneyRedeemed(
        uint indexed _index,
        uint indexed _timestamp,
        address _from,
        address indexed _to,
        uint _redeemedValue
    );
    //////////////////////////

    /////////////////////Modifiers
    modifier IsThereAnAllowance(address _from, address _to){
        require(_user[_to].allowances[_from].index > 0, "There is no allowance from this wallet.");
        _;
    }
    modifier AllowanceFunction (address _to) {
        _;

        _user[_to].allowances[msg.sender].index ++;

        emit AllowanceSucceed(
            _user[_to].allowances[msg.sender].index,
            _user[_to].allowances[msg.sender].timestamp,
            _user[_to].allowances[msg.sender].duration,
            _user[_to].allowances[msg.sender].value,
            msg.sender,
            _to
        );
    }
    modifier verifyRemainingTime (address _allowned, address _allowner) {
        require(verifiesRemainingTime(_allowned, _allowner), "Your allowed time has ended.");
        _;
    }
    modifier NotYourself (address _to){
        require(_to != msg.sender, "You can't do this with your own wallet.");
        _;
    }
    //////////////////////////////

    /////////////////////View Functions
    function getTotalBalance() public view returns(uint totalBalance){
        return _totalBalance;
    }
    function getMyBalance() public view returns(uint myBalance) {
        return _user[msg.sender].myBalance;
    }
    function getAllMyAllowanceBalances() public view returns(uint allMyAllowanceBalances){
        return _user[msg.sender].allMyAllowanceBalances;
    }
    function getMyAllowanceBalanceFrom(address _allowner) public view IsThereAnAllowance(_allowner, msg.sender) returns(uint getMyAllowanceBalance){
        return _user[msg.sender].balances[_allowner];
    }
    function getMyAllowanceFrom(address _allowner) public view IsThereAnAllowance(_allowner, msg.sender) returns(uint index, uint timestamp, uint duration, uint remainingTime, uint blockTimestamp, uint value){
        return (
            _user[msg.sender].allowances[_allowner].index,
            _user[msg.sender].allowances[_allowner].timestamp,
            _user[msg.sender].allowances[_allowner].duration,
            getMyAllowanceRemainingTime(_allowner),
            block.timestamp,
            _user[msg.sender].allowances[_allowner].value
        );
    }
    ///////////////////////////////////

    /////////////////////Allowance Functions
    function giveAllowance(address _to, uint _duration, uint _amount) public NotYourself(_to) AllowanceFunction(_to) {
        require(_user[_to].balances[msg.sender] >= _amount, "Insufficient funds.");

        setAllowanceTime(_to, _duration);

        _user[_to].allMyAllowanceBalances -= _user[_to].allowances[msg.sender].value;
        _user[_to].allMyAllowanceBalances += (_user[_to].allowances[msg.sender].value = _amount);
    }

    function payAndGiveAllowance(address _to, uint _duration) public payable NotYourself(_to) AllowanceFunction(_to){
        _totalBalance += msg.value;
        setAllowanceTime(_to, _duration);
        _user[_to].allMyAllowanceBalances += msg.value;
        _user[_to].balances[msg.sender] += (_user[_to].allowances[msg.sender].value = msg.value);
    }

    function transferAndGiveAllowance(address _to, uint _duration, uint _amount) public NotYourself(_to) AllowanceFunction(_to){
        decreaseMoneyFromMyBalance(msg.sender, _amount);
        setAllowanceTime(_to, _duration);
        _user[_to].allMyAllowanceBalances += _amount;
        _user[_to].balances[msg.sender] += (_user[_to].allowances[msg.sender].value = _amount);
    }
    
    function revokeAllowanceOf(address _wallet) public NotYourself(_wallet) IsThereAnAllowance(msg.sender, _wallet){
        uint _redeemedValue = _user[_wallet].allowances[msg.sender].value;
        redeemValueFromAllowance(_wallet, msg.sender, _redeemedValue);
        setAllowanceTime(_wallet, 0);

        _user[_wallet].allowances[msg.sender].index++;

        emit AllowanceRevoked(
            _user[_wallet].allowances[msg.sender].index,
            _user[_wallet].allowances[msg.sender].timestamp,
            msg.sender,
            _wallet,
            _redeemedValue
        );
    }
    
    function redeemFreeValueFromBalanceOf(address _wallet) public NotYourself(_wallet) {
        uint _redeemedValue = _user[_wallet].balances[msg.sender] - _user[_wallet].allowances[msg.sender].value;
        redeemValueFromBalance(_wallet, msg.sender, _redeemedValue);

        _redeemedMoneyEventIndex++;

        emit MoneyRedeemed(
            _redeemedMoneyEventIndex,
            block.timestamp,
            msg.sender,
            _wallet,
            _redeemedValue
        );
    }
    /////////////////////////////////////////

    /////////////////////Internal Functions
    function getMyAllowanceRemainingTime(address _allowner) internal view verifyRemainingTime(msg.sender,_allowner) returns(uint remainingTime){
        return (_user[msg.sender].allowances[_allowner].timestamp + _user[msg.sender].allowances[_allowner].duration) - block.timestamp;
    }
    function setAllowanceTime(address _to, uint _duration) internal {
        _user[_to].allowances[msg.sender].timestamp = block.timestamp;
        _user[_to].allowances[msg.sender].duration = _duration;
    }
    function receiveMoney(address _to) internal {
        _totalBalance += msg.value;
        _user[_to].myBalance += msg.value;
    }
    function decreaseMoneyFromMyBalance(address _address, uint _amount) internal {
        require(_user[_address].myBalance >= _amount, "Insufficient funds.");

        _user[_address].myBalance -= _amount;
    }
    function redeemValueFromAllowance(address _from, address _to, uint _amount) internal {
        require(_user[_from].allowances[_to].value >= _amount, "Insufficient funds.");

        _user[_from].allowances[_to].value -= _amount;
        _user[_from].allMyAllowanceBalances -= _amount;
        _user[_from].balances[_to] -= _amount;
        _user[_to].myBalance += _amount;
    }
    function redeemValueFromBalance(address _from, address _to, uint _amount) internal {
        require(_user[_from].balances[_to] > _user[_from].allowances[_to].value, "There is no free balance to redeem. Check your Allowances for this user.");
        require((_user[_from].balances[_to] - _user[_from].allowances[_to].value) >= _amount, "Insufficient free funds.");

        _user[_from].balances[_to] -= _amount;
        _user[_to].myBalance += _amount;
    }
    function verifiesRemainingTime(address _allowed, address _allowner) internal view returns(bool){
        return block.timestamp < _user[_allowed].allowances[_allowner].timestamp + _user[_allowed].allowances[_allowner].duration;
    }
    ////////////////////////////////////////

    function depositMoney() public payable {
        receiveMoney(msg.sender);
    }

    function withdrawFromMyBalance (uint _amount) public {
        decreaseMoneyFromMyBalance(msg.sender, _amount);
        _totalBalance -= _amount;

        payable(msg.sender).transfer(_amount);
    }

    function withdrawFromAllowance (address _allowner, uint _amount) public IsThereAnAllowance(_allowner, msg.sender) verifyRemainingTime(msg.sender,_allowner) {
        require(_user[msg.sender].allowances[_allowner].value >= _amount, "Insufficient allowed funds.");

        _user[msg.sender].allowances[_allowner].value -= _amount;
        _user[msg.sender].balances[_allowner] -= _amount;
        _user[msg.sender].allMyAllowanceBalances -= _amount;
        _totalBalance = _totalBalance - _amount;

        payable(msg.sender).transfer(_amount);
    }


    receive() external payable {
        receiveMoney(msg.sender);
    }
}