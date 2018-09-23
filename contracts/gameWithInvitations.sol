pragma solidity ^0.4.25;

contract GameWithInvitations is Game {
	mapping(address => mapping(address => bool)) invitations;
	mapping(address => mapping(address => uint256)) invitationBids;

	function invite(address opponent) public payable {
		require(opponent != msg.sender);
	
		if (invitations[opponent][msg.sender]) {
			require(invitationBids[opponent][msg.sender] == msg.value);
			
			invitationBids[opponent][msg.sender] = 0;
			invitations[opponent][msg.sender] = false;
			
			startGame(opponent, msg.sender, msg.value);
		} else {
			invitations[msg.sender][opponent] = true;
			invitationBids[msg.sender][opponent] = msg.value;
		}
	}
	
	function retractInvite(address opponent) public {
		require(invitations[msg.sender][opponent] == true);
		
		uint256 currentBid = invitationBids[msg.sender][opponent];
		
		invitations[msg.sender][opponent] = false;
		invitationBids[msg.sender][opponent] = 0;
		
		if (currentBid > 0) {
			msg.sender.transfer(currentBid);
		}
	}
}