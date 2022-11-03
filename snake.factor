! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions furnace.json http http.server
http.server.dispatchers io io.servers json.reader kernel logging
namespaces parser snake.move-handler threads
;
IN: snake

TUPLE: battlesnake < dispatcher ;

t development? set

: snake-info ( -- json )
    H{ { "apiversion" 1 }
        { "author" "joenash" }
        { "color" "#00ff00" }
        { "head" "lantern-fish" }
        { "tail" "default" }
        { "version" "0.0.1" }
    } ;

: <info-action> ( -- action )
    <page-action>
        [
            snake-info <json-content>
        ] >>display ;

: <move-action> ( -- action )
    <page-action>
    [
        "coding-badly"
        [
            request get post-data>> data>> dup \ <move-action> NOTICE log-message
            json> handle-move <json-content>
           ! sample-move  <json-content>
        ] with-logging
    ] >>submit ;

: <battlesnake> ( -- dispatcher )
    battlesnake new-dispatcher
        <info-action> "" add-responder
        <move-action> "move" add-responder ;
        ! responders
        ! <responder-action> "/route" add-responder

: run-battlesnake ( -- httpserver )
    "coding-badly"
    [
    <battlesnake> main-responder set-global
    8080 httpd ] with-logging 
    ;

: start-server ( -- ) 
    <battlesnake> main-responder set-global
    8080 httpd wait-for-server
    ;

MAIN: start-server