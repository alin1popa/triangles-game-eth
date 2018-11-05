pragma solidity ^0.4.25;

contract GameWithInvitations is Game {
	mapping(address => mapping(address => bool)) private invitations;
	mapping(address => mapping(address => uint256)) private invitationBids;

	/**
	 *	@dev Invite specified opponent or start game if already invited
	 */
	function invite(address opponent) public payable {
		/* cannot invite yourself */
		require(opponent != msg.sender);
	
		if (invitations[opponent][msg.sender]) {
			/* if opponent already invited sender */
			
			/* check that game is not already running */
			require(gameIsNotRunning(opponent, msg.sender));
			
			/* check sender uses correct bid */
			require(invitationBids[opponent][msg.sender] == msg.value);
			
			/* reset invitation status */
			invitationBids[opponent][msg.sender] = 0;
			invitations[opponent][msg.sender] = false;
			
			/* start the game */
			startGame(opponent, msg.sender, msg.value);
		} else {
			/* if opponent hasn't already invited sender */
			
			/* setup invitation and bid */
			invitations[msg.sender][opponent] = true;
			invitationBids[msg.sender][opponent] = msg.value;
		}
	}
	
	/**
	 * 	@dev Retract an unaswered invitation 
	 */
	function retractInvite(address opponent) public {
		/* check invitation exists */
		require(invitations[msg.sender][opponent] == true);
		
		/* get bid */
		uint256 currentBid = invitationBids[msg.sender][opponent];
		
		/* reset invitation and bid */
		invitations[msg.sender][opponent] = false;
		invitationBids[msg.sender][opponent] = 0;
		
		/* return money to sender */
		if (currentBid > 0) {
			msg.sender.transfer(currentBid);
		}
	}
}