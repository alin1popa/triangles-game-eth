pragma solidity ^0.4.25;

import "game.sol";
import "gameWithBidQueue.sol";
import "gameWithInvitations.sol";

contract TriangleGame is Game, GameWithBidQueue, GameWithInvitations {
	struct BoardState {
		mapping(uint8 => mapping(uint8 => bool)) boardPlayerOne;
		mapping(uint8 => mapping(uint8 => bool)) boardPlayerTwo;
	}
	
	mapping(address => mapping(address => BoardState)) private boardStates;
	
	function checkPlayerOneIsMoveValid(address player2, uint8 point1, uint8 point2) internal view {
		require(point1 < point2);
		require(boardStates[msg.sender][player2].boardPlayerOne[point1][point2] == false);
		require(boardStates[msg.sender][player2].boardPlayerTwo[point1][point2] == false);
	}
	
	function checkPlayerTwoIsMoveValid(address player1, uint8 point1, uint8 point2) internal view {
		require(point1 < point2);
		require(boardStates[player1][msg.sender].boardPlayerOne[point1][point2] == false);
		require(boardStates[player1][msg.sender].boardPlayerTwo[point1][point2] == false);
	}
	
	function playerOneMakeMove(address player2, uint8 point1, uint8 point2) public {
		checkPlayerOneIsMoveAllowed(player2);
		checkPlayerOneIsMoveValid(player2, point1, point2);
		
		boardStates[msg.sender][player2].boardPlayerOne[point1][point2] = true;
		toggleMoveState(msg.sender, player2);
	}
	
	// TODO replace these params everywhere with "opponent" sometime
	function playerTwoMakeMove(address player1, uint8 point1, uint8 point2) public {
		checkPlayerTwoIsMoveAllowed(player1);
		checkPlayerTwoIsMoveValid(player1, point1, point2);
		
		boardStates[player1][msg.sender].boardPlayerTwo[point1][point2] = true;
		toggleMoveState(player1, msg.sender);
	}
	
	function startGame(address player1, address player2, uint256 bid) internal {
		boardStates[player1][player2] = BoardState();
		moveStates[player1][player2] = MoveState(true, block.number);
	}
	
	
}