pragma solidity ^0.4.25;

contract GameWithBidQueue is Game {
	mapping(uint256 => address) private queue;

	function putInQueue() public payable {
		address currentBidder = queue[msg.value];
		require(currentBidder != msg.sender);
		
		if (currentBidder == 0) {
			queue[msg.value] = msg.sender;
		} else {
			address player1 = queue[msg.value];
			queue[msg.value] = 0;
			
			startGame(player1, msg.sender, msg.value);
		}
	}
	
	function retractFromQueue(uint256 bid) public {
		require(queue[bid] == msg.sender);
		queue[bid] = 0;
		
		msg.sender.transfer(bid);
	}
}
