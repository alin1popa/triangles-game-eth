pragma solidity ^0.4.25;

import "libs/Ownable.sol";

contract Game is Ownable {
	uint private blocksPerRound;

	struct MoveState {
		bool player1ToMove;
		uint blockNumberOfLastMove;
	}
	
	mapping(address => mapping(address => MoveState)) private moveStates;
	
	/**
	 *	@dev Allows current owner to increase blocks per round
	 *  because if blocks start being mined too fast in the future game may become unplayable
	 */
	function inncreaseBlocksPerRound(uint newBlocksPerRound) public onlyOwner {
		require(newBlocksPerRound > blocksPerRound);
		blocksPerRound = newBlocksPerRound;
	}
	
	function checkPlayerOneIsMoveAllowed(address player2) internal {
		// TODO should this be in memory? or maybe replaced inline?
		MoveState ms = moveStates[msg.sender][player2];
		
		require(ms.blockNumberOfLastMove > 0); // game is running
		require(ms.player1ToMove == true); // player 1 is moving
		// TODO use safemaths
		require(block.number - blocksPerRound <= ms.blockNumberOfLastMove); // no round timeout yet
	}
	
	function checkPlayerTwoIsMoveAllowed(address player1) internal {
		// TODO should this be in memory? or maybe replaced inline?
		MoveState ms = moveStates[player1][msg.sender];
		
		require(ms.blockNumberOfLastMove > 0); // game is running
		require(ms.player1ToMove == false); // player 2 is moving
		// TODO use safemaths
		require(block.number - blocksPerRound <= ms.blockNumberOfLastMove); // no round timeout yet
	}
	
	function toggleMoveState(address player1, address player2) internal {
		// TODO should this etc etc same as above
		MoveState ms = moveStates[player1][player2];
		
		ms.player1ToMove = !(ms.player1ToMove);
		ms.blockNumberOfLastMove = block.number;
	}
	
	function startGame(address player1, address player2, uint256 bid) internal;
}