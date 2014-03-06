#!/bin/tcsh -xfv

foreach mine ( *.m )
    set updated = ` find ../../../mtoolbox/brainstorm3 -name $mine:t `
    echo "Files: "
    echo "                                                              :"
    echo "                                                              :"
    echo $updated   ":" $mine
    echo "                                                              :"
    echo "                                                              :"
    diff -dby --suppress-common-lines $updated $mine
    echo " [c]ompare / [s]kip / [q]uit ?"

    set action=$<
    if ($action == "q" ) then
	exit(1);
    endif
    if ($action == "c" ) then
	kdiff3 $updated $mine -m -o $mine
    endif 
    echo " "
end
