! Copyright (C) 2019 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: raylib.ffi kernel math.ranges sequences locals random combinators.random  math threads calendar namespaces accessors alien.c-types classes.struct combinators alien.enums ;
IN: piggy

: make-window ( -- )
    800 450 "Hello, Piggy!" init-window
    60 set-target-fps ;

: clear-window ( -- )
    RAYWHITE clear-background ;

SYMBOL: camera
DEFER: draw-enemies
DEFER: draw-player
: draw-moveable ( moveable -- )
    dup [ position>> ] dip
    dup [ size>> ] dip
    color>>
    draw-cube-v ;
    
: render-loop ( -- )
    begin-drawing
    clear-window
    camera get
    begin-mode-3d
    draw-enemies
    draw-player
    10 1.0 draw-grid
    end-mode-3d
    end-drawing ; inline

: make-vector3 ( x y z -- vector3 )
    Vector3 <struct-boa> ;

: setup-camera ( -- )
    0.0 10.0 10.0  make-vector3
    0.0 0.0 0.0 make-vector3
    0.0 1.0 0.0  make-vector3
    45.0 CAMERA_PERSPECTIVE enum>number
    Camera3D <struct-boa>
    camera set ;

TUPLE: player-t position size color ;

SYMBOL: player

: draw-player ( -- )
    player get draw-moveable ;

SYMBOL: collision

: setup-moveable ( position size color -- moveable )
    player-t boa ;


: change-player-position ( -- )
    {
        { [ KEY_RIGHT enum>number is-key-down ]
          [ player get position>> x>> 0.2 + player get position>> x<<  ] }
        { [ KEY_LEFT enum>number is-key-down ]
          [ player get position>> x>> -0.2 + player get position>> x<< ] }
        { [ KEY_DOWN enum>number is-key-down ]
          [ player get position>> z>> 0.2 + player get position>> z<< ] }
        { [ KEY_UP   enum>number is-key-down ]
          [ player get position>> z>> -0.2 + player get position>> z<< ] }
        [  ] } cond ;

:: make-bounding-box ( position size -- item )
    position x>> size x>> 2 / -
    position y>> size y>> 2 / -
    position z>> size z>> 2 / - make-vector3
    position x>> size x>> 2 / +
    position y>> size y>> 2 / +
    position z>> size y>> 2 / + make-vector3
    BoundingBox <struct-boa> ;

: player-bounding-box ( -- box )
    player get position>> player get size>> make-bounding-box ;

DEFER: get-enemies
: check-collisions ( -- )
    get-enemies [ dup position>> swap size>> make-bounding-box ] map
    [ player-bounding-box check-collision-boxes ] filter
    empty? not [ RED player get color<< ]
    [ GREEN player get color<< ] if ;

: setup-player ( -- )
    0.0 1.0 2.0 make-vector3 
    1.0 2.0 1.0 make-vector3 
    GREEN setup-moveable player set ;

: setup-enemy ( positon size -- enemy )
    GRAY setup-moveable ;

: get-enemies ( -- enemy-list )
    { }
    -4.0 1.0 0.0 make-vector3
    2.0 2.0 2.0 make-vector3 setup-enemy suffix
    4.0 0.0 0.0 make-vector3
    2.0 2.0 2.0 make-vector3 setup-enemy suffix ;

: draw-enemies ( -- )
    get-enemies [ draw-moveable ] each ;

: main ( -- )
    make-window
    setup-camera
    setup-player
    f collision set
    [   render-loop change-player-position
        check-collisions window-should-close not ] loop
    close-window ;

MAIN: main
