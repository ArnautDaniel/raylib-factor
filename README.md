![Raylib-factor Logo](https://github.com/silverbeard00/raylib-factor/blob/master/raylib-factor_256x256.png "Raylib-factor Logo")

# raylib-factor
bindings for the raylib library in
[Factor](https://factorcode.org "Factor")


# How to use it

raylib-factor has been merged into the factor source tree!  If you have Factor then you're already good to go.  

**A Raylib/Factor** book is in the works. 135 pages so far!  

[Fait Idees](https://faitidees.org/) holds draft copies.  And when I mean draft,  I mean read at your own peril right now.  It'll be done someday.

Simply **USE: raylib.ffi** and pretty soon you'll be saying...
![Hello Factor](https://github.com/silverbeard00/raylib-factor/blob/master/hello-factor.png "Hello Factor")

# What is it

This is complete (one exception) bindings for the Raylib library (2.5).  It also includes **raygui** and **rayicon** support which will load automatically if the dll/so you are using has those modules compiled in.

The exception is that android related structs are not included because Factor doesn't run on it.

# How to program it

A small demo or two is included to help you get an idea of how to use it.  In reality the next step of this project will be adding utility functions to make  the experience more "Factor-y".  

All "functions" are named according to the Factorish style.  This means something like **InitWindow** in C becomes **init-window** in factor.  Every function is renamed this way with the exception of the raygui module which is the same except you have to prepend **rl-** to the function name.


Have fun!
