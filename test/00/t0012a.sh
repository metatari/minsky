#! /bin/sh

here=`pwd`
if test $? -ne 0; then exit 2; fi
tmp=/tmp/$$
mkdir $tmp
if test $? -ne 0; then exit 2; fi
cd $tmp
if test $? -ne 0; then exit 2; fi

fail()
{
    echo "FAILED" 1>&2
    cd $here
    chmod -R u+w $tmp
    rm -rf $tmp
    exit 1
}

pass()
{
    echo "PASSED" 1>&2
    cd $here
    chmod -R u+w $tmp
    rm -rf $tmp
    exit 0
}

trap "fail" 1 2 3 15

# basic godley table tests

# insert ecolab script code here
# use \$ in place of $ to refer to variable contents
# exit 0 to indicate pass, and exit 1 to indicate failure
cat >input.tcl <<EOF
source $here/test/assert.tcl
set godley [minsky.addGodleyTable 0 0]
minsky.godley.get \$godley
minsky.godley.table.clear
assert {[minsky.godley.table.rows]==0} ""
assert {[minsky.godley.table.cols]==0} ""

# check insertRow/insertCol
minsky.godley.table.insertRow 0
minsky.godley.table.insertCol 0
assert {[minsky.godley.table.rows]==1} ""
assert {[minsky.godley.table.cols]==1} ""
minsky.godley.setCell 0 0 f11
assert {[minsky.godley.table.getCell 0 0]=="f11"} ""
minsky.godley.table.insertRow 0
minsky.godley.table.insertCol 0
assert {[minsky.godley.table.rows]==2} ""
assert {[minsky.godley.table.cols]==2} ""
assert {[minsky.godley.table.getCell 1 1]=="f11"} ""
minsky.godley.table.insertRow 2
minsky.godley.table.insertCol 2
assert {[minsky.godley.table.rows]==3} ""
assert {[minsky.godley.table.cols]==3} ""
assert {[minsky.godley.table.getCell 1 1]=="f11"} ""
for {set r 0} {\$r<3} {incr r} {
  for {set c 0} {\$c<3} {incr c} {
     minsky.godley.setCell \$r \$c f\$r\$c
  }
}
# test column variables
assert {"[minsky.godley.table.getColumnVariables]"=="f01 f02"} ""
# interior variables
assert {"[minsky.godley.table.getVariables]"=="f11 f12 f21 f22"} ""

# test delete column
minsky.godley.table.deleteCol 2
assert {"[minsky.godley.table.getColumnVariables]"=="f02"} ""
assert {"[minsky.godley.table.getVariables]"=="f12 f22"} ""
assert {[minsky.godley.table.getCell 1 1]=="f12"} ""
minsky.godley.deleteRow 2
assert {"[minsky.godley.table.getColumnVariables]"=="f02"} ""
assert {"[minsky.godley.table.getVariables]"=="f22"} ""
assert {[minsky.godley.table.getCell 1 1]=="f22"} ""
assert {[minsky.godley.table.rows]==2} ""
assert {[minsky.godley.table.cols]==2} ""

assert {"[minsky.godley.table.getVariables]"=="f22"} ""

# test rowsum, and stricter test of get variables
minsky.godley.table.clear
minsky.godley.table.resize 4 4
assert {[minsky.godley.table.rows]==4} ""
assert {[minsky.godley.table.cols]==4} ""
minsky.godley.setCell 1 0 "Initial Conditions"
minsky.godley.setCell 1 1 10
minsky.godley.setCell 1 3 -10
minsky.godley.setCell 2 1 a
minsky.godley.setCell 2 2 b
minsky.godley.setCell 2 3 -a
assert {[minsky.godley.table.rowSum 1]==0} ""
assert {[minsky.godley.table.rowSum 2]=="b"} ""
assert {"[minsky.godley.table.getVariables]"=="a b"} ""

minsky.deleteItem \$godley
assert {[minsky.items.size]==0} ""
tcl_exit
EOF

$here/gui-tk/minsky input.tcl
if test $? -ne 0; then fail; fi

pass
