# Blackjack in Solidity

I had a lot of trouble making this so it is not very polished. 
I started off working on Blackjack with Matt Stirling (also in this class) but we branched off to take separate approaches.
Web page was made using Netbeans.
I know I should have my script in a seaparate file from my HTML, but here it is all in the index.html file.
There are some pauses while javascript works with Solidity. 
Also it took so long to make that I did not bother to make Aces 1 or 11. In this game, Aces are ALWAYS ONE; NEVER ELEVEN!!

Issues encountered:
- Had trouble returning values from Solidity. Needed to revise to make separate getter functions.
- Had trouble generating random numbers. Used the block number as a seed.
- Had trouble with my stack overflowing.
- All hands and logic are in Solidity, so this consumes insane amounts of gas!

To play.
Address [0] is Player and address [1] from the ganache generated addresses is dealer.
Click "Play as Player" and wait for the cards to load.
Hit or Stay as much as you want - the game is over if you bust.
When you stay, the dealer keeps hitting until his card total is > 16.

This is my first time working with github, so please let me know if anything is out of order.
