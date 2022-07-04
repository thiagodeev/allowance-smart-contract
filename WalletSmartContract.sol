// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

contract WalletChallenge is Ownable {
    uint internal _totalBalance;

    struct User {
        uint balance;
        Allowance allowance;
    }
    struct Allowance {
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


    function getTotalBalance() public onlyOwner view returns(uint totalBalance){
        return _totalBalance;
    }

    function getMyBalance() public view returns(uint myBalance) {
        return _user[msg.sender].balance;
    }

    function giveAllowance(address _to, uint _duration, uint _amount) public {
        decreaseMoney(msg.sender, _amount);
        setAllowanceTime(_to, _duration);

        // _user[_to].balance = _user[_to].balance + (_user[_to].allowance.value = _amount);
        _user[_to].allowance.value = _amount;
        _user[_to].allowance.index ++;

        emit AllowanceSucceed(
            _user[_to].allowance.index,
            _user[_to].allowance.timestamp,
            _user[_to].allowance.duration,
            _user[_to].allowance.value,
            _user[_to].allowance.from
        );
    }

    function payAndGiveAllowanceTo(address _to, uint _duration) public payable {
        receiveMoney(_to);
        setAllowanceTime(_to, _duration);

        _user[_to].balance = _user[_to].balance + (_user[_to].allowance.value = msg.value);
        _user[_to].allowance.index ++;
        
        emit AllowanceSucceed(
            _user[_to].allowance.index,
            _user[_to].allowance.timestamp,
            _user[_to].allowance.duration,
            _user[_to].allowance.value,
            _user[_to].allowance.from
        );
    }

    function setAllowanceTime(address _to, uint _duration) internal {
        _user[_to].allowance.duration = (_user[_to].allowance.timestamp = block.timestamp) - _duration;
    }

    function depositMoney() public payable {
        receiveMoney(msg.sender);
    }

    function receiveMoney(address _to) internal {
        _totalBalance = _totalBalance + msg.value;
        _user[_to].balance = _user[_to].balance + msg.value;
    }

    function decreaseMoney(address _address, uint _amount) public payable {
        require(_user[_address].balance >= _amount, "Insufficient funds.");

        _user[_address].balance = _user[_address].balance - _amount;
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
