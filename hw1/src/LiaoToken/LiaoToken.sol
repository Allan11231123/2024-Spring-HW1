// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract LiaoToken is IERC20 {
    // TODO: you might need to declare several state variable here
    mapping(address account => uint256) private _balances;
    mapping(address account => bool) isClaim;

    mapping(address account => uint256) private _allowanceOut; // value to allowance for someone
    mapping(address account => uint256) private _allowance; // value of allowance from someone
    mapping(address account => address) private _spender; // who own your approval and can use your allowance

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    error transfer_notEnoughBalance();
    error transfer_notEnoughAllowance();
    error approve_notEnoughBalance();

    event Claim(address indexed user, uint256 indexed amount);

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function claim() external returns (bool) {
        if (isClaim[msg.sender]) revert();
        _balances[msg.sender] += 1 ether;
        _totalSupply += 1 ether;
        emit Claim(msg.sender, 1 ether);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        // TODO: please add your implementaiton here
        if(amount > _balances[msg.sender]){
            revert transfer_notEnoughBalance();
        }
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        // TODO: please add your implementaiton here
        if(value > (_balances[from]-_allowanceOut[from])){
            revert transfer_notEnoughAllowance();
        }else if(value > _balances[from]){
            revert transfer_notEnoughBalance();
        }
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        // TODO: please add your implementaiton here
        if(amount > _balances[spender]){
            revert approve_notEnoughBalance();
        }
        _allowanceOut[spender] = amount;
        _spender[msg.sender] = spender;
        _allowance[msg.sender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        // TODO: please add your implementaiton here
        assert(spender == _spender[owner]);
        return _allowance[owner];
    }
}
