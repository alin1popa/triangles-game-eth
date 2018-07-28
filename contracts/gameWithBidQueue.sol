pragma solidity ^0.4.24;

contract GameWithBidQueue is Game {
	mapping(uint256 => address) queue;

	function putInQueue(uint256 bid) public {
		address currentBidder = queue[bid];
		// TODO accept bid payment
		if (currentBidder == 0) {
			queue[bid] = msg.sender;
		} else {
			queue[bid] = 0;
			startGame(player1, player2, bid);
		}
	}
	
	function retractFromQueue(uint256 bid) public {
		require(queue[bid] == msg.sender);
		// TODO pay sender bid back
		queue[bid] = 0;
	}
}