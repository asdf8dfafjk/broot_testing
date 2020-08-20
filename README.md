# Testing framework

This repo holds captures of broot instances in text format for comparison. 
To run the test, execute `./test_screen_captures.sh`. 
Some or tests might fail based on your terminal config 
but the tests themselves are robust as long as the testing infrastructure stays the same. 


## To familiarize 

Checkout and `cat` `master/initial.md` and other files inside `master. 


# After every code modification, do the following:

* Do a `cat` on the capture corresponding to the failed test. 
* If everything looks alright, use vi to diff. vi -d <CAPTURE> <MASTER>. 
Install AnsiEsc from https://github.com/powerman/vim-plugin-AnsiEsc. And issue `:AnsiEsc`
* Estimate if this is a regression or expected.
* If good, copy the `.capture` file to become the new `.master`.
