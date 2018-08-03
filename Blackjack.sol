pragma solidity ^0.4.17;

contract Blackjack {
  // Parameters of the game.
  address public owner;
  address public dealer;
  address public player;

  uint public dealerFund;
  uint public playerFund;

  // Set to true at the end, disallows any change
  bool ended;

  // Events that will be fired on changes.
  /*
  event GameState(string winner, uint amount);
  event GameEnded(address winner, uint amount);
  */
  event GameState(uint winner, uint amount);
  event GameEnded(uint winner, uint amount);
  event TestEvent(string msg);
  event CardDealt(string suit, string value, uint numval);

  // for MetaCoin
  mapping (address => uint) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

  // define cards & deck
  struct Card {
	   string suit;
	   string value;
	   uint numval;
  }

  struct Deck {
    Card [52] cards;
	  uint currentCard;
  }

  // Not sure how to dynamically size in solidity so use fixed hand size
  struct Hand{
    Card [5] hand;
    uint numCards;
    uint cardTotal;
  }

  Hand playerHand;
  Hand dealerHand;

  uint playerTurn = 0;
  uint dealerTurn = 1;
  uint evalTurn = 2;

  uint gameResult;

  uint turn;

  Deck myDeck;

  string [4] Suits = ["C", "D", "H", "S"];
  string [13] Vals =  ["A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"];

  function DeckInit() public {
    turn = playerTurn;
    gameResult = 0;
    playerHand.cardTotal = 0;
    dealerHand.cardTotal = 0;
    playerHand.numCards = 0;
    dealerHand.numCards = 0;

		myDeck.currentCard = 0;
		uint counter = 0;
		for (uint i = 0; i< 4; i++){
			for (uint j = 0; j< 13; j++){
				myDeck.cards[counter].suit = Suits[i];
				myDeck.cards[counter].value = Vals[j];
				if (j<10) {
					myDeck.cards[counter].numval = j+1;
				}
				else{
					myDeck.cards[counter].numval = 10;
				}
				counter++;
			}
		}
	}

	function deal() public returns (string suit, string val, uint numval){
		if (myDeck.currentCard >= myDeck.cards.length){
      revert();
      // Getting an error on null return. Fix later
			//return null;
    }
		// Pick Random number between (myDeck.currentCard and cards.length)
		uint range = myDeck.cards.length - myDeck.currentCard;
		// https://www.reddit.com/r/ethereum/comments/442z66/how_to_generate_a_number_between_110_in_solidity/
		uint cardNum = uint(blockhash(block.number-1)) % range;

		// Say we selected card (5) out of array on first try
		// Now the range will be 1 unit shorter
		// swap used card with card currently at end of range so it does not get reused and so other card is not cut out

		uint replaceCardNum = myDeck.cards.length - myDeck.currentCard - 1;
		Card storage temp = myDeck.cards[cardNum];
    Card memory temp1;
    temp1.suit = temp.suit; temp1.value = temp.value; temp1.numval = temp.numval;
		myDeck.cards[cardNum] = myDeck.cards [replaceCardNum];
		myDeck.cards[replaceCardNum] = temp1;

		myDeck.currentCard++;

    emit CardDealt(temp.suit, temp.value, temp.numval);
    emit TestEvent(temp.value);
    emit TestEvent(temp.suit);
		return (temp1.suit, temp1.value, temp1.numval);
    ///return temp.value;

	}
	//}
  // REMOVE firstDeal --> Stack too deep. Remove variables
  // Replace with 2 player hits and 1 dealer Hit
  /*
  function firstDeal() public returns(string Psuit1, string Pval1, uint Pnumval1, string Psuit2, string Pval2, uint Pnumval2, string Dsuit1, string Dval1, uint Dnumval1){
    turn = playerTurn;
    playerHand.cardTotal = 0;
    dealerHand.cardTotal = 0;
    playerHand.numCards = 0;
    dealerHand.numCards = 0;
    for (uint i = 0; i < 1; i++){
      (playerHand.hand[i].suit, playerHand.hand[i].value, playerHand.hand[i].numval) = deal();
      playerHand.cardTotal += playerHand.hand[i].numval;
      playerHand.numCards++;
    }
    i = 0;
    (dealerHand.hand[i].suit, dealerHand.hand[i].value, dealerHand.hand[i].numval) = deal();
    dealerHand.cardTotal += dealerHand.hand[i].numval;
    dealerHand.numCards++;
    // I know this is horrible form, but i ran out of time and just copy / pasted. sorry :(
    return (playerHand.hand[0].suit, playerHand.hand[0].value, playerHand.hand[0].numval,
            playerHand.hand[1].suit, playerHand.hand[1].value, playerHand.hand[1].numval,
            dealerHand.hand[0].suit, dealerHand.hand[0].value, dealerHand.hand[0].numval);
  }
  */

  function PlayerHit() public /*returns(string Psuit1, string Pval1, uint Pnumval1)*/{
    if (turn != playerTurn){
      revert();
    }

    uint i = playerHand.numCards;
    (playerHand.hand[i].suit, playerHand.hand[i].value, playerHand.hand[i].numval) = deal();
    playerHand.cardTotal += playerHand.hand[i].numval;
    playerHand.numCards++;
    if (playerHand.cardTotal > 21){
      //Bust
      turn = dealerTurn;
    }
    /*return (playerHand.hand[i].suit, playerHand.hand[i].value, playerHand.hand[i].numval);*/
  }

  function DealerHit() public /*returns(string, string, uint256)*/{

   uint i = dealerHand.numCards;
    (dealerHand.hand[i].suit, dealerHand.hand[i].value, dealerHand.hand[i].numval) = deal();
    dealerHand.cardTotal += dealerHand.hand[i].numval;
    dealerHand.numCards++;
    if (dealerHand.cardTotal > 16){
      //Bust
      turn = evalTurn;
    }
    //return (dealerHand.hand[dealerHand.numCards-1].suit, dealerHand.hand[dealerHand.numCards-1].value, dealerHand.hand[dealerHand.numCards-1].numval);
    //For testing do manually
    //return(Suits[3], "6", 6);
  }

  function getLastDealer() public constant returns (string, string, uint256){
    if (dealerHand.numCards > 0){
      return (dealerHand.hand[dealerHand.numCards-1].suit, dealerHand.hand[dealerHand.numCards-1].value, dealerHand.hand[dealerHand.numCards-1].numval);
      //return("C", Vals[4], dealerHand.cardTotal);
    }
    return("X", "X", 2); //Works
  }
  function getLastPlayer() public constant returns (string, string, uint256){
    if (playerHand.numCards > 0){
      return (playerHand.hand[playerHand.numCards-1].suit, playerHand.hand[playerHand.numCards-1].value, playerHand.hand[playerHand.numCards-1].numval);
      //return("C", Vals[4], dealerHand.cardTotal);
    }
    return("X", "X", 2); //Works
  }

  //function checkDealer17(/*uint bettingAmount*/) public constant returns (uint256){
  function checkDealer17(uint bettingAmount) public returns (uint256){
    bool isPlayerWinner = false;
    uint256 results;
    if (dealerHand.cardTotal < 17){
      results =  1; // Keep Hitting
    }
    else if (dealerHand.cardTotal > 16 && dealerHand.cardTotal < 22){
      if (dealerHand.cardTotal < playerHand.cardTotal){
        results = 2; // Dealer over 17. Dealer not bust. Player hand higher. Player win
        isPlayerWinner = true;
      }
      if (dealerHand.cardTotal > playerHand.cardTotal){
        results =  3; // Dealer over 17. Dealer not bust. Dealer hand higher. Dealer win
      }
      if (dealerHand.cardTotal == playerHand.cardTotal){
      results =  4; // Same hand. Push
    }
    }
    else{
      results =  2; // Dealer > 21. Dealer Bust. Player win.
      isPlayerWinner = true;
    }

    if (results > 1){
      if (isPlayerWinner) {
        if(sendCoin(dealer, player, bettingAmount)) {
        } else {
            ended = true;
            results = 3; // Player
            emit GameEnded(results, getBalanceInEth(player));
        }
      } else {
            if (sendCoin(player, dealer, bettingAmount)) {
              } else {
                ended = true;
                results = 2; // Dealer
                emit GameEnded(results, getBalanceInEth(dealer));
              }
      }
    }

    emit GameState(results, bettingAmount);

    gameResult = results;
    return results;
  }

  function getHandResults() public constant returns (uint256){
    uint results = gameResult;
    //gameResult = 0;
    return results;
  }


  function PlayerStand()public{
    /*
    // Initially in place for security. Had to remove for Javascript recursion
    if (turn != playerTurn){
      revert();
    }*/
    turn = dealerTurn;
  }

  function DealerTurn() public {
    if (turn != dealerTurn){
      revert();
    }
    uint i;
    while (dealerHand.cardTotal < 17){
      i = dealerHand.numCards;
      (dealerHand.hand[i].suit, dealerHand.hand[i].value, dealerHand.hand[i].numval) = deal();
      dealerHand.cardTotal += dealerHand.hand[i].numval;
      dealerHand.numCards++;
    }
    turn = evalTurn;
  }

  // Shuffle;


  /// Create a Blackjack game
  /// You can assign owner to do some admin stuff.
  // previously  > function Blackjack > but compilor gives warning
  constructor () public {
    owner = msg.sender;
  }

  function setDealer(address _dealer, uint _fund) public returns (bool success) {
    dealer = _dealer;
    balances[dealer] = _fund;
    return true;
  }

  function setPlayer(address _player, uint _fund) public returns (bool success) {
    player = _player;
    balances[player] = _fund;
    return true;
  }

  /// compare actions to determine winner
  ///
  function compare(uint dealerSum, uint playerSum, uint bettingAmount, uint premium) public returns (uint results){

    if (turn != evalTurn){
      revert();
    }
    // Return if the hand is a push. No money transfer
	if ((dealerSum == playerSum)||(dealerSum > 21 && playerSum > 21)) {
      results = 1; // tied
      emit GameState(results, bettingAmount);
      return results;
    }


    // determine who is winner.
    bool isPlayerWinner = false;
	bool isBlackjack = false;

	// Dealer Win
	if (dealerSum > playerSum && dealerSum < 22){
		results = 2; // dealer
	}
	// Player Win
	else if (playerSum > dealerSum && playerSum < 22){
		results = 3; // player
		isPlayerWinner = true;
		if (playerSum == 21){
			isBlackjack = true;
			// Premium is BettingAmount/2 --> passed in from front end because cant divide in solidity
			bettingAmount = (bettingAmount + premium);
		}
	}
	// Dealer Bust
	else if (dealerSum > 21 && playerSum < 22){
		results = 3; //player
		isPlayerWinner = true;
	}
	// Player Bust
	else if (playerSum > 21 && dealerSum < 22){
		results = 2; //dealer
	}
	// Default
	else{
		revert();
	}

    emit GameState(results, bettingAmount);

    // send betting amount
    if (isPlayerWinner) {
      if(sendCoin(dealer, player, bettingAmount)) {
        // continue game
      } else {
        // end of game
        ended = true;
        results = 3; // Player
        emit GameEnded(results, getBalanceInEth(player));
      }
    } else {
      if (sendCoin(player, dealer, bettingAmount)) {
        // continue game
      } else {
        // end of game
        ended = true;
        results = 2; // Dealer

        emit GameEnded(results, getBalanceInEth(dealer));
      }
    }

    return results;
  }

  // send or receive game coin via smart contract
  function sendCoin(address sender, address receiver, uint amount) public returns(bool sufficient) {
    if (balances[sender] < amount) return false;
    balances[sender] -= amount;
    balances[receiver] += amount;
    emit Transfer(sender, receiver, amount);
    return true;
  }

  function getBalanceInEth(address addr) public view returns(uint){
    return convert(getBalance(addr), 1);
  }

  function convert(uint amount,uint conversionRate) public pure returns (uint convertedAmount) {
        return amount * conversionRate;
    }

  function getBalance(address addr) public view returns(uint) {
    return balances[addr];
  }
}
