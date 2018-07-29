pragma solidity ^0.4.24;

contract GameWithBidQueue is Game {
	mapping(uint256 => address) queue;

	// TODO bid should be payment
	function putInQueue(uint256 bid) public {
		address currentBidder = queue[bid];
		
		if (currentBidder == 0) {
			queue[bid] = msg.sender;
		} else {
			queue[bid] = 0;
			
			// TODO who is player1 who is player2
			startGame(player1, player2, bid);
		}
	}
	
	function retractFromQueue(uint256 bid) public {
		require(queue[bid] == msg.sender);
		queue[bid] = 0;
		
		// TODO pay sender bid back
		// this should be at end of function
	}
}
