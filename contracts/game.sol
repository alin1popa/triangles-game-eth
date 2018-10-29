pragma solidity ^0.4.25;

import "libs/Ownable.sol";

contract Game is Ownable {
	/* timeout period in number of blocks */
	/* modifiable by owner */
	/* can only be increased, never decreased */
	uint private blocksPerRound;

	// TODO add extra bool for fair price
	/*  move state structure */
	struct MoveState {
		bool player1ToMove;
		uint blockNumberOfLastMove; // 0 value means game is not running
	}
	
	/** 
	 * 	global map of move states 
	 * 	moveStates[address1][address2] is the move state of the game where 
	 * 		address1 is player one and address2 is player two
	 */
	mapping(address => mapping(address => MoveState)) internal moveStates;
	
	/** 
	 * 	owner's cut is 10% of the eth 
	 *	The owner can withdraw the balance as soon as the players agree to start the game
	 */
	uint256 private ownerBalance;
	
	/** 
	 *	bids map
	 *	bids[address1][address2] is the amount each player payed to start the game where
	 *		address1 is player one and address2 is player two
	 */
	mapping(address => mapping(address => uint256)) private bids;
	
	// TODO resetBid function
	
	/**
	 *	@dev Sets up bids for game and reserves owner's cut
	 */
	function setupBidsForGame(address player1, address player2, uint256 bid) internal {
		/* check that we won't overwrite an existing bid */
		require(bids[player1][player2] == 0);
		
		// TODO ce se intampla daca bidul e sub whatever si nu merge impartirea
		// TODO ce se intampla daca bidul e 0
		// TODO use safemaths
		
		/* owner's part is 5% of the amount players put into contract */
		uint256 ownersPart = bid/20;
		
		/* update state vars */
		bids[player1][player2] = bid - ownersPart;
		ownerBalance = ownerBalance + ownersPart*2;
	}
	
	/**
	 *	@dev Withdraws owner's balance to owner's address
	 *	@modifier onlyOwner
	 */
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
	
	/**
	 *	@dev Checks that player one is allowed to make the next move
	 */
	// TODO check gas usage with ifs instead of requires => on false require eats up all the gas
	function checkPlayerOneIsMoveAllowed(address player2) internal {
		/* require that the game is running */
		require(moveStates[msg.sender][player2].blockNumberOfLastMove > 0);
		/* require that player 1 is to move */
		require(moveStates[msg.sender][player2].player1ToMove == true); 
		/* require that move is within timeout period */
		// TODO use safemaths
		require(block.number - blocksPerRound <= moveStates[msg.sender][player2].blockNumberOfLastMove); 
	}
	
	/**
	 *	@dev Checks that player two is allowed to make the next move
	 */
	function checkPlayerTwoIsMoveAllowed(address player1) internal view {
		/* require that the game is running */
		require(moveStates[player1][msg.sender].blockNumberOfLastMove > 0);
		/* require that player 1 is to move */
		require(moveStates[player1][msg.sender].player1ToMove == false); 
		/* require that move is within timeout period */
		// TODO use safemaths
		require(block.number - blocksPerRound <= moveStates[player1][msg.sender].blockNumberOfLastMove); 
	}
	
	/**
	 *	@dev Updates the move state's block and toggles the turn
	 */
	function toggleMoveState(address player1, address player2) internal {
		moveStates[player1][player2].player1ToMove = !(moveStates[player1][player2].player1ToMove);
		moveStates[player1][player2].blockNumberOfLastMove = block.number;
	}
	
	// TODO add payment stuff
	
	// TODO move payment stuff to GameWithPayments
	
	// TODO move prototypes only to GameAbstract or GameGeneric or smth
	
	// TODO make everything non reentrable
	
	/**
	 *	@dev Sets definitive win for player one
	 *	Resets the game and sends the prize to the winner
	 */
	function setWinForPlayerOne(address player2) internal {
		/* prize is double the bid */
		uint256 toTransfer = bids[msg.sender][player2]*2;
		
		/* reset bid and game state */
		bids[msg.sender][player2] = 0;
		moveStates[msg.sender][player2].blockNumberOfLastMove = 0;
		
		/* transfer the prize */
		msg.sender.transfer(toTransfer);
	}
	
	/**
	 *	@dev Sets definitive win for player two
	 *	Resets the game and sends the prize to the winner
	 */
	function setWinForPlayerTwo(address player1) internal {
		/* prize is double the bid */
		uint256 toTransfer = bids[player1][msg.sender];
		
		/* reset bid and game state */
		bids[player1][msg.sender] = 0;
		moveStates[player1][msg.sender].blockNumberOfLastMove = 0;
		
		/* transfer the prize */
		msg.sender.transfer(toTransfer);
	}
	
	/**
	 *	@dev Claim win by player one invoking timeout of player two
	 */
	function claimPlayerOneWinByTimeout(address player2) public {
		/* require that the game is running */
		require(moveStates[msg.sender][player2].blockNumberOfLastMove > 0);
		/* require that player two is to move */
		require(moveStates[msg.sender][player2].player1ToMove == false); 
		/* require that player two is outside the timeout period */
		require(block.number - blocksPerRound > moveStates[msg.sender][player2].blockNumberOfLastMove);

		/* if claim is successful, set win for player one */
		setWinForPlayerOne(player2);
	}
	
	/**
	 *	@dev Claim win by player one invoking timeout of player two
	 */
	function claimPlayerTwoWinByTimeout(address player1) public {
		/* require that the game is running */
		require(moveStates[player1][msg.sender].blockNumberOfLastMove > 0);
		/* require that player two is to move */
		require(moveStates[player1][msg.sender].player1ToMove == true); 
		/* require that player two is outside the timeout period */
		require(block.number - blocksPerRound > moveStates[player1][msg.sender].blockNumberOfLastMove);

		/* if claim is successful, set win for player one */
		setWinForPlayerTwo(player1);
	}
	
	function startGame(address player1, address player2, uint256 bid) internal;
}