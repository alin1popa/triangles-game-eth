pragma solidity ^0.4.24;

contract GameWithInvitations is Game {
	mapping(address => mapping(address => bool) invitations;
	mapping(address => mapping(address => uint256)) invitationBids;

	function invite(address opponent, uint256 bid) public {
		if (invitations[opponent][msg.sender]) {
			require(invitationBids[opponent][msg.sender] == bid);
			
			invitationBids[opponent][msg.sender] = 0;
			invitations[opponent][msg.sender] = false;
			
			// TODO who is player1 who is player2
			startGame(player1, player2, bid);
		} else {
			
		}
	}
}