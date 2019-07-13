! Copyright (C) 2019 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: raylib.ffi kernel sequences locals alien.enums namespaces math classes.struct accessors combinators math.ranges sequences.deep continuations assocs classes.tuple math.functions random math.parser io.directories.hierarchy io.pathnames io.directories splitting unicode make fry ;
IN: fof-clever

! Basic Grid for background textures
TUPLE: square posx posy size container ;
SYMBOL: grid-size
SYMBOL: grid

: game-height ( -- height )
    get-screen-height grid-size get - ;

: game-width ( -- width )
    get-screen-width grid-size get - ;

: make-grid-line ( x range -- list )
    [ length ] keep 
    [ swap <repetition> ] dip
    zip
    [ [ grid-size get H{ } clone square boa ] with-datastack ] map ;

: setup-grid-squares ( -- )
    0 game-width grid-size get <range>
    [ 0 game-height grid-size get <range> make-grid-line ]
    map flatten grid set ;

: center-square ( -- x )
    grid-size get 2 / ;

: offset ( vector2 -- vector2' )
    [ x>> center-square + ] keep
    y>> center-square +
    Vector2 <struct-boa> ;

: find-square-by-coordinate ( n -- squares )
    grid get swap filter ; inline

! Find all squares that have a certain x or y
: find-square-by-y ( y -- squares )
    [ swap posy>> = ] curry
    find-square-by-coordinate ;

: find-square-by-x ( x -- squares )
    [ swap posx>> = ] curry
    find-square-by-coordinate ;

! Extract the square coordinates
: with-square-coordinates ( square -- x y square )
    [ posx>> ] keep
    [ posy>> ] keep ;

: square-coordinates ( square -- x y )
    with-square-coordinates drop ;

: draw-square ( grid-square -- )
    tuple-slots
    [ drop dup BLACK draw-rectangle-lines ]
    with-datastack drop ;

: draw-grid ( -- )
    grid get [ draw-square ] each ;

: setup-grid ( -- )
    40 grid-size set ;

: coordinates=? ( square x y -- bool )
    [ square-coordinates ] 2dip
    swap [ = ] dip
    swap [ = ] dip and ;

: find-square ( x y -- square )
    [ coordinates=? ] 2curry grid get
    swap
    filter ;

: set-square-key ( square val key -- )
    pick container>> set-at drop ;

: remove-square-key ( square key -- )
    swap container>> delete-at ;

: get-square-key ( square key -- val )
    swap container>> at* drop ;

: container=? ( square name -- bool )
    swap container>> at* nip ;

: find-square-by-container ( name -- square )
    [ container=? ] curry
    grid get swap
    filter ;

! Windowing

: make-window ( -- )
    800 400 "Clever Bean" init-window
    30 set-target-fps ;

: clear-window ( -- )
    RAYWHITE clear-background ;

! Texture bank

: texture-names ( name -- name' )
    "/" split last
    "." split first
    >lower ;

SYMBOL: textures

: clever-load-image ( image -- texture )
    load-image dup grid-size get dup
    image-resize load-texture-from-image ;

: setup-textures ( -- )
    current-directory get directory-tree-files
    [ absolute-path ] map
    [ dup clever-load-image
      [ { } swap texture-names suffix ] dip suffix ] 
    map
    textures set ;

: get-textures ( key -- texture )
    textures get at ;

! Environment

:: draw-generic ( seq texture -- )
    seq
    [ square-coordinates [ texture get-textures ] 2dip
      RAYWHITE draw-texture ] each ;

SYMBOL: background 
: draw-background ( -- )
    background get
    0 0 RAYWHITE draw-texture ;

: load-background ( -- )
    "kitchen.png" load-texture
    background set ;

! Player
SYMBOL: player-sym
TUPLE: player posx posy speed direction item ;
SYMBOL: player-texture
DEFER: player-grab

: load-player-textures ( -- )
    { } "player.png" load-texture suffix
    "player.png" load-image dup
    image-flip-horizontal load-texture-from-image suffix
    { "left" "right" } swap zip
    player-texture set ;

: load-player ( -- )
    load-player-textures
    get-screen-width 2 / 
    get-screen-height "right"
    player-texture get at height>> -
    15 "right" f player boa
    player-sym set ;

: get-player-texture ( -- texture )
    player-sym get direction>>
    player-texture get at ;

: draw-player ( -- )
    get-player-texture
    player-sym get square-coordinates
    RAYWHITE draw-texture ;

: player-right ( -- )
    player-sym get
    [ speed>> ] keep
    [ posx>> ] keep
    [ + ] dip
    [ posx<< ] keep
    "right" swap direction<< ;

: player-left ( -- )
    player-sym get
    [ speed>> ] keep
    [ posx>> ] keep
    [ swap - ] dip
    [ posx<< ] keep
    "left" swap direction<< ;

: player-below-bounds ( x -- )
    neg? [ player-right  ] when ;

: player-above-bounds ( x -- )
    get-screen-width grid-size get - > [ player-left  ] when ;

: player-within-bounds ( -- )
    player-sym get
    posx>> dup
    player-below-bounds
    player-above-bounds ;

: attempt-to-move ( direction -- )
    player-within-bounds
        {
        { "left"  [  player-left  ] }
        { "right" [  player-right ] }
        { "use"   [  "use" player-grab ] }
        { "lowuse" [ "lowuse" player-grab ] }
        } case ;


: process-input ( keypair -- result/bool )
    dup first ! Get the key
    enum>number is-key-down
    [ second ] [ drop "" ] if ; 

: player-inputs ( -- inputs )
    { 
        { KEY_A "left"  }
        { KEY_D "right"  }
    } ;

: player-actions ( -- inputs )
    { { KEY_S "use" }
      { KEY_W "lowuse" } } ;

: process-actions ( keypair -- result/bool )
    dup first
    enum>number is-key-pressed
    [ second ] [ drop "" ] if ;

: player-action ( -- )
    player-actions
    [ process-actions dup
      "" equal?
      [ drop ]
      [ attempt-to-move ] if ] each ;

: player-input ( -- )
    player-action
    player-inputs
    [ process-input dup
      "" equal?
      [ drop ]
      [ attempt-to-move ] if ] each ;

:: adjacent ( x y ex ex2 -- quot )
    [ x grid-size get ex execute ,
      y grid-size get ex2 execute , ] { } make ; inline

! Player grabbing
: upper-left ( x y -- seq )
    \ - \ drop adjacent
    [ first ] keep second 
    \ - \ - adjacent ;

: upper-right ( x y -- seq )
    \ + \ drop adjacent
    [ first ] keep second 
    \ + \ - adjacent ;

: bottom-left ( x y -- seq )
    \ - \ + adjacent
    [ first ] keep second
    \ - \ + adjacent ;

: bottom-right ( x y -- seq )
    \ + \ + adjacent
    [ first ] keep second
    \ + \ + adjacent ;

: player-direction-squares ( -- squares )
    player-sym get direction>>
    {
        { "left"  [ { bottom-left upper-left } ]  }
        { "right" [ { bottom-right upper-right } ] }
    } case ;

: adjacent-squares ( square -- list )
    square-coordinates [ rot execute( x y -- seq ) ] 2curry
    player-direction-squares
    swap map ; inline 

: adjacent-map ( seq -- seq )
    [ [ find-square ] with-datastack ] map ;

: player-middle-coordinates ( -- x y )
    player-sym get square-coordinates
    get-player-texture
    [ width>> 2 / ] keep height>> 2 /
    [ swap ] dip +
    [ + ] dip
    [ dup get-screen-width >
      [ drop 800 ]
      [ ] if ] dip ;

: generate-grid-rectangles ( -- seq )
    grid get
    [ square-coordinates
      grid-size get dup
       Rectangle <struct-boa> ]
    map ;

: within-rectangle ( x y -- seq )
    Vector2 <struct-boa>
    [ swap check-collision-point-rec ] curry
    generate-grid-rectangles
    swap filter ;

: player-center-square ( -- square )
    player-middle-coordinates
    within-rectangle first
    [ x>> >integer ] keep
    y>> >integer find-square first ;

: draw-adjacent ( -- )
    player-center-square
    adjacent-squares
    adjacent-map flatten
    [ dup square? [ square-coordinates grid-size get dup
                    GREEN draw-rectangle ] [ drop ] if ] each ;

: counter-items ( -- items )
    { "apple" "knife" "spatula" "wine" "wheat" } ;

: get-counter-sequence ( n -- seq )
    200 find-square-by-y
    [ posx>> 159 > ] filter
    [ 0 ] 2dip  subseq ;

: add-counter-items-to-grid ( -- )
    counter-items dup length
    get-counter-sequence
    [ swap "item" set-square-key ] 2each ;

: draw-items ( -- )
    "item" find-square-by-container
    [ dup [ "item" get-square-key get-textures ] dip
      [ posx>> ] keep
      posy>> RAYWHITE draw-texture ] each ;

: player-swap ( square -- )
    dup "item" get-square-key
    [ player-sym get item>> "item" set-square-key ] dip
    player-sym get item<< ;

: player-remove ( square -- )
    dup "item" get-square-key
    [ "item" remove-square-key ] dip
    player-sym get item<< ;

: player-grab ( vert -- )
    player-center-square adjacent-squares
    adjacent-map flatten
    swap
    { { "use" [ first ] }
      { "lowuse" [ second ] } }
    case
    player-sym get item>>
    [ player-swap ]
    [ player-remove ] if ;

: draw-hands ( -- )
    player-sym get item>> get-textures
    player-center-square square-coordinates RAYWHITE
    draw-texture ;
    
SYMBOL: hack
: setup ( -- )
    make-window
    setup-grid
    setup-grid-squares
    current-directory get hack set
    "~/assets" set-current-directory
    setup-textures
    hack get set-current-directory
    load-background
    load-player
    add-counter-items-to-grid
    ;

: render ( -- )
    begin-drawing
    clear-window
    draw-background
    draw-grid
    draw-player
    draw-adjacent
    draw-items
    end-drawing ;

: game-loop ( -- )
    [ render player-input window-should-close not ] loop ;

: main ( -- )
    setup
    game-loop
    close-window ;
