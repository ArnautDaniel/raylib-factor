! Copyright (C) 2019 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: raylib.ffi kernel sequences locals alien.enums
       namespaces math classes.struct accessors combinators ;
IN: fof-thames

: make-window ( -- )
    640 480 "Irrigation" init-window
    60 set-target-fps ;

: clear-window ( -- )
    RAYWHITE clear-background ;

SYMBOL: player

: show-player-circle ( -- )
    player get 25.0 RED draw-circle-v ;

: setup-player ( -- )
    get-screen-width 2 /
    get-screen-height 2 /
    Vector2 <struct-boa>
    player set ;

: render ( -- )
    begin-drawing
    clear-window
    show-player-circle
    end-drawing ;

: move-x ( increment -- )
    player get x>> + player get x<< ;

: move-y ( increment -- )
    player get y>> + player get y<< ;

: check-individual-action ( keypair -- )
dup first ! Get the key
enum>number is-key-down
[ second call( -- ) ] [ drop ] if ; 

: check-input ( -- )
{ 
    { KEY_W [ -2.0 move-y  ] }
    { KEY_S [ 2.0  move-y  ] }
    { KEY_A [ -2.0 move-x  ] }
    { KEY_D [ 2.0  move-x  ] }
}
! We could also put this in a symbol if we wanted.

[ check-individual-action ] each ; 

: main ( -- )
    make-window setup-player
    [ check-input render
      window-should-close not ] loop
    close-window ;

MAIN: main
