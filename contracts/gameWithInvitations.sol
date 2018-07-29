pragma solidity ^0.4.24;

contract GameWithInvitations is Game {
	mapping(address => mapping(address => bool) invitations;
	mapping(address => mapping(address => uint256)) invitationBids;

	// TODO bid should be payment
	function invite(address opponent, uint256 bid) public {
		if (invitations[opponent][msg.sender]) {
			require(invitationBids[opponent][msg.sender] == bid);
			
			invitationBids[opponent][msg.sender] = 0;
			invitations[opponent][msg.sender] = false;
			
			// TODO who is player1 who is player2
			startGame(player1, player2, bid);
		} else {
			invitations[msg.sender][opponent] = true;
			invitationBids[msg.sender][opponent] = bid;
		}
	}
	
	function retractInvite(address opponent) public {
		require(invitations[msg.sender][opponent] == true);
		
		uint256 currentBid = invitationBids[msg.sender][opponent];
		
		invitations[msg.sender][opponent] = false;
		invitationBids[msg.sender][opponent] = 0;
		
		if (currentBid > 0) {
			// TODO payback currentBid to sender
			// nothing should follow
		}
	}
}