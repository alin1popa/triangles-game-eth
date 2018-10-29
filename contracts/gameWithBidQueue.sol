pragma solidity ^0.4.25;

contract GameWithBidQueue is Game {
	/**
	 * global queue mapping 
	 * queue[bid1]=address1 means player who owns address1 proposed to play with bid1
	 * a player can enter the queue only by paying the bid
	 */
	mapping(uint256 => address) private queue;

	// TODO require gameIsNotStarted
	
	/**
	 *	@dev Put sender in queue or start the game if queue is not empty
	 */
	function putInQueue() public payable {
		/* current bidder is player already in queue - may be none */
		address currentBidder = queue[msg.value];
		require(currentBidder != msg.sender);
		
		if (currentBidder == 0) {
			/* if sender is the first to bid, add them to the queue */
			queue[msg.value] = msg.sender;
		} else {
			/* if queue is not empty, start the game */
			/* but clean the queue first */
			address player1 = queue[msg.value];
			queue[msg.value] = 0;
			
			startGame(player1, msg.sender, msg.value);
		}
	}
	
	/**
	 *	@dev Retract sender from queue if bid has yet to be accepted
	 */
	function retractFromQueue(uint256 bid) public {
		/* require that the sender is in queue and payed the bid */
		require(queue[bid] == msg.sender);
		
		/* reset the queue */
		queue[bid] = 0;
		
		/* return money to sender */
		msg.sender.transfer(bid);
	}
}
