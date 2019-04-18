Recreation of an example from the raylib page.  Using 3d!

This deploys to a size of 3.7mb...Amazing.

I figure I'll reimplement examples and try to figure out the best way to write a factor-y wrapper for these bindings.  

# Lessons from Piggy

I think two components that would be incredibly helpful would be some sort of entity system and a proper gameloop.

For the entity system I'm considering using part of my idea from 12Labors in making the world a single variable/symbol based off of the set SFG.  

    S would include the state of all game objects
    F defines functions that can used to modify those objects (would need a rudimentary  type system)
    G is supposed to be the GOAL set but I'm not sure what use I'd have for this.

Such that we could define

    : main ( -- )
      SFG decide execute ;
 
As our main loop where execute is

    : execute ( SFG -- SFG2 )
        [ren2d
        ren2d]  ! render loop
        [update
        entities
        update] ! update entities
        [input
        input]  ! handle input
    execute ;
    
A recursive function that takes in a game world and returns a new game world.  

Essentially we need a tidy concept of holding onto objects/structs that can then be passed around into meta functions that handle the looping constructs.  [ren2d | [update | [input would have to be macros that translate our game structure into the required form needed to be used by raylib functions.

