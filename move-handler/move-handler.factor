USING: arrays assocs combinators combinators.short-circuit
hashtables io.encodings.utf8 io.files json.reader json.writer
kernel logging math random sequences sequences.deep ;
IN: snake.move-handler



: snake-head ( gamestate -- x y ) 
   "you" of "head" of [ "x" of ] [ "y" of ] 
   bi ! Applies 2 quotes to 1 stack item
   ! "you" swap at "head" swap at dup
   ;

:: make-coord ( x y -- coord ) 
    H{ { "x" x } { "y" y } }
    ;

:: label-coord ( label coord -- coord )
    H{ { label coord } }
    ;

: head-coords ( gamestate -- coord )
    snake-head make-coord 
    ! Jank way without variables
    ! "y" 2 <hashtable> [ set-at ] keep "x" swap [ set-at ] keep
    ;

! Take current head position, build an array of surrounding squares, filter on safe square

: get-surroundings ( gamestate -- coords )
    snake-head 
    { 
        [ [ -1 + ] dip make-coord ]
        [ [ +1 + ] dip make-coord  ]
        [ 1 + make-coord ]
        [ -1 + make-coord ]
    }
    2cleave
    4array
    { "left" "right" "up" "down" }
    swap
    H{ } zip-as
 ;

! Checks for body segments

: get-snakes ( gamestate -- snakes )  "board" of "snakes" of ;

: get-body-segments ( gamestate -- coords ) get-snakes [ "body" of ] map flatten ;

: body-at-coord? ( coord segment -- bool ) 
    {
     [ "x" of swap "x" of = ]
     [ "y" of swap "y" of = ]
    }
    2|| ;

: coord-empty? ( coord segment -- bool )
    body-at-coord? not ;

! Checks for bounds

: board-width ( gamestate -- x ) 
    "board" of "width" of ;

: board-height ( gamestate -- y ) 
    "board" of "height" of ;

: coord-at-bounds? ( coord width height -- safe? )
    {
        [ 2drop "x" of 0 < ] ! Check x < 0
        [ 2drop "y" of 0 < ] ! Check y < 0
        [ drop 1 - swap "x" of < ] ! Check x > board-width
        [ nip 1 - swap "y" of < ] ! Check y > board-height
    }
    3|| ;

: coord-in-bounds? ( coord width height -- safe? )
    coord-at-bounds? not
    ;

: check-surroundings ( gamestate -- moves )
    dup
    get-surroundings
    [ pick get-body-segments index not nip ]
    assoc-filter
      [
        pick
        [ board-width ] keep
        board-height
        coord-in-bounds?
        nip
     ]
    assoc-filter
    nip
    ;

: handle-move ( gamestate -- json )
    check-surroundings random
    0 swap nth
    "move" H{ } [ set-at ] keep
    ;

\ handle-move NOTICE add-output-logging
