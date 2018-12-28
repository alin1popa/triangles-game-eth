pragma solidity ^0.5.0;

import "game.sol";
import "gameWithBidQueue.sol";
import "gameWithInvitations.sol";

contract TriangleGame is Game, GameWithBidQueue, GameWithInvitations {

	/* board state structure */
	/* each player's lines are stored in two separate mappings as bools */
	struct BoardState {
		mapping(uint8 => mapping(uint8 => bool)) boardPlayerOne;
		mapping(uint8 => mapping(uint8 => bool)) boardPlayerTwo;
	}
	
    /* globala board states */
	mapping(address => mapping(address => BoardState)) private boardStates;
	
    /**
	 *	@dev Checks player one's proposed move is valid
	 */
	function checkPlayerOneIsMoveValid(address player2, uint8 point1, uint8 point2) internal view {
        /* we require lines to go from lower numbered point to higher numbered point */
		require(point1 < point2);
        /* and we require the line is not already drawn by either of players */
		require(boardStates[msg.sender][player2].boardPlayerOne[point1][point2] == false);
		require(boardStates[msg.sender][player2].boardPlayerTwo[point1][point2] == false);
	}
	
    /**
	 *	@dev Checks player one's proposed move is valid
	 */
	function checkPlayerTwoIsMoveValid(address player1, uint8 point1, uint8 point2) internal view {
        /* we require lines to go from lower numbered point to higher numbered point */
		require(point1 < point2);
		/* and we require the line is not already drawn by either of players */
        require(boardStates[player1][msg.sender].boardPlayerOne[point1][point2] == false);
		require(boardStates[player1][msg.sender].boardPlayerTwo[point1][point2] == false);
	}
	
    /**
	 *	@dev Makes player one's move
	 */
	function playerOneMakeMove(address player2, uint8 point1, uint8 point2) public {
        /* it must be player one's turn */
		checkPlayerOneIsMoveAllowed(player2);
        /* proposed move by player one must be valid */
		checkPlayerOneIsMoveValid(player2, point1, point2);
		
        /* update move into board states */
		boardStates[msg.sender][player2].boardPlayerOne[point1][point2] = true;
        /* change turn */
		toggleMoveState(msg.sender, player2);
	}

    /**
	 *	@dev Makes player two's move
	 */
	function playerTwoMakeMove(address player1, uint8 point1, uint8 point2) public {
        /* it must be player two's turn */
		checkPlayerTwoIsMoveAllowed(player1);
		/* proposed move by player two must be valid */
        checkPlayerTwoIsMoveValid(player1, point1, point2);
		
        /* update move into board states */
		boardStates[player1][msg.sender].boardPlayerTwo[point1][point2] = true;
        /* change turn */
		toggleMoveState(player1, msg.sender);
	}
	
    /**
     *  @dev Starts the game with required initial parameters
     */
	function startGame(address player1, address player2, uint256 bid) internal {
        /* resets the board */
		boardStates[player1][player2] = BoardState();
        /* sets game's move state */
		initializeMoveState(player1, player2);
	}
	
    /**
     *  @dev Claims player one win by rules
     */
	function claimPlayerOneWinByRules(address player2, uint8 point1, uint8 point2, uint8 point3) public {
        /* require that points are in correct order */
		require(point1 < point2);
		require(point2 < point3);
		
        /* require that the triangle is formed */
		require(boardStates[msg.sender][player2].boardPlayerOne[point1][point2] == true);
		require(boardStates[msg.sender][player2].boardPlayerOne[point2][point3] == true);
		require(boardStates[msg.sender][player2].boardPlayerOne[point1][point3] == true);
		
		/* if claim is successful, set win for player one */
		setWinForPlayerOne(player2);
	}
	
	/**
     *  @dev Claims player two win by rules
     */
	function claimPlayerTwoWinByRules(address player1, uint8 point1, uint8 point2, uint8 point3) public {
        /* require that points are in correct order */
		require(point1 < point2);
		require(point2 < point3);
		
        /* require that the triangle is formed */
		require(boardStates[player1][msg.sender].boardPlayerTwo[point1][point2] == true);
		require(boardStates[player1][msg.sender].boardPlayerTwo[point2][point3] == true);
		require(boardStates[player1][msg.sender].boardPlayerTwo[point1][point3] == true);
		
		/* if claim is successful, set win for player two */
		setWinForPlayerTwo(player1);
	}
}