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
	
	uint256 private ownerBalance;
	mapping(address => mapping(address => uint256)) private bids;
	
	// TODO resetBid function
	
	function setupBidsForGame(address player1, address player2, uint256 bid) internal {
		require(bids[player1][player2] == 0);
		
		// TODO ce se intampla daca bidul e sub whatever si nu merge impartirea
		// TODO ce se intampla daca bidul e 0
		// TODO use safemaths
		uint256 ownersPart = bid/20;
		bids[player1][player2] = bid - ownersPart;
		ownerBalance = ownerBalance + ownersPart*2;
	}
	
	function withdrawOwnerBalance() public onlyOwner {
		uint256 toTransfer = ownerBalance;
		ownerBalance = 0;
		
		msg.sender.transfer(toTransfer);
	}
	
	/**
	 *	@dev Allows current owner to increase blocks per round
	 *  because if blocks start being mined too fast in the future, game may become unplayable
	 */
	function increaseBlocksPerRound(uint newBlocksPerRound) public onlyOwner {
		require(newBlocksPerRound > blocksPerRound);
		blocksPerRound = newBlocksPerRound;
	}
	
	// TODO check gas usage with ifs instead of requires => on false require eats up all the gas
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
	
	// TODO make everything non reentrable
	
	function setWinForPlayerOne(address player2) private {
		uint256 toTransfer = bids[msg.sender][player2];
		bids[msg.sender][player2] = 0;
		moveStates[msg.sender][player2].blockNumberOfLastMove = 0;
		
		msg.sender.transfer(toTransfer);
	}
	
	function setWinForPlayerTwo(address player1) private {
		uint256 toTransfer = bids[player1][msg.sender];
		bids[player1][msg.sender] = 0;
		moveStates[player1][msg.sender].blockNumberOfLastMove = 0;
		
		msg.sender.transfer(toTransfer);
	}
	
	function claimPlayerOneWinByTimeout(address player2) public {
		require(moveStates[msg.sender][player2].blockNumberOfLastMove > 0);
		require(moveStates[msg.sender][player2].player1ToMove == false); 
		require(block.number - blocksPerRound > moveStates[msg.sender][player2].blockNumberOfLastMove);

		setWinForPlayerOne(player2);
	}
	
	function claimPlayerTwoWinByTimeout(address player1) public {
		require(moveStates[player1][msg.sender].blockNumberOfLastMove > 0);
		require(moveStates[player1][msg.sender].player1ToMove == true); 
		require(block.number - blocksPerRound > moveStates[player1][msg.sender].blockNumberOfLastMove);

		setWinForPlayerTwo(player1);
	}
	
	function startGame(address player1, address player2, uint256 bid) internal;
}