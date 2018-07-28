pragma solidity ^0.4.24;

contract GameWithInvitations is Game {
	mapping(address => address) invitations;
	mapping(address => mapping(address => uint256)) invitationBids;

	function invite(address opponent, uint256 bid) public {
		if (invitations[opponent] == msg.sender) {
			require(invitationBids[opponent][msg.sender] == bid);
			invitationBids[opponent][msg.sender] = 0;
			invitations[opponent] // nu merge renunt
		}
	}
}