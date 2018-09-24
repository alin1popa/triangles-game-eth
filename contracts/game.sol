pragma solidity ^0.4.25;

import "libs/Ownable.sol";

contract Game is Ownable {
	uint private blocksPerRound;

	// TODO add extra bool for fair price
	struct MoveState {
		bool player1ToMove;
		uint blockNumberOfLastMove;
	}
	
	mapping(address => mapping(address => MoveState)) internal moveStates;
	
	/**
	 *	@dev Allows current owner to increase blocks per round
	 *  because if blocks start being mined too fast in the future, game may become unplayable
	 */
	function increaseBlocksPerRound(uint newBlocksPerRound) public onlyOwner {
		require(newBlocksPerRound > blocksPerRound);
		blocksPerRound = newBlocksPerRound;
	}
	
	function checkPlayerOneIsMoveAllowed(address player2) internal {
		// game is running
		require(moveStates[msg.sender][player2].blockNumberOfLastMove > 0);
		// player 1 is moving		
		require(moveStates[msg.sender][player2].player1ToMove == true); 
		// no round timeout yet
		// TODO use safemaths
		require(block.number - blocksPerRound <= moveStates[msg.sender][player2].blockNumberOfLastMove); 
	}
	
	function checkPlayerTwoIsMoveAllowed(address player1) internal view {
		// game is running
		require(moveStates[player1][msg.sender].blockNumberOfLastMove > 0);
		// player 2 is moving
		require(moveStates[player1][msg.sender].player1ToMove == false); 
		// no round timeout yet
		// TODO use safemaths
		require(block.number - blocksPerRound <= moveStates[player1][msg.sender].blockNumberOfLastMove); 
	}
	
	function toggleMoveState(address player1, address player2) internal {
		moveStates[player1][player2].player1ToMove = !(moveStates[player1][player2].player1ToMove);
		moveStates[player1][player2].blockNumberOfLastMove = block.number;
	}
	
	// TODO add payment stuff
	
	// TODO move payment stuff to GameWithPayments
	
	// TODO move prototypes only to GameAbstract or GameGeneric or smth
	
	function claimPlayerOneWinByTimeout(address player2) public {
		
	}
	
	function startGame(address player1, address player2, uint256 bid) internal;
}