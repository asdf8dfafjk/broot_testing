# Testing framework

This repo holds captures of broot instances in text format for comparison. 
To run the test, execute `./test_screen_captures.sh`. 
These tests have been only tested on one machine. 
But the tests themselves are robust as long as the testing infrastructure stays the same. 
(Testing infra staying same is no longer a requirement since the bug 
referred here https://unix.stackexchange.com/a/698013 has been fixed in the latest version)
If the instrastructure changes, one glance at the diffs might be enough


## To familiarize 

Checkout and `cat` `master/initial.md` and other files inside `master. 


# After every code modification, do the following:

* Do a `diff -side-by-side` on the capture and master corresponding to the failed case.
* If everything looks alright, use vi to diff. `vi -d <PID>.BROOT.CAPTURES/<CASE>.capture master/<CASE>`.
Install AnsiEsc from https://github.com/powerman/vim-plugin-AnsiEsc. And issue `:AnsiEsc`
* Estimate if this is a regression or expected.
* If expected, copy the `.capture` file to become the new `.master`.

# Some bulk operations which may come in handy

* Rename (run in powershell)

`(Get-Item *.capture).name |% { Rename-Item $_ $_.replace( "capture", "master" ) }`

* Manual diff

```
for i in ls master/*                                                                                             
do
f=$(basename $i)
diff /tmp/<PID OF TEST>.BROOT.CAPTURES/$f.capture $i
done
```
