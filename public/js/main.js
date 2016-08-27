/**
 * HexaWars Game Client
 *
 * Version v.0.01
 * Created by Paweł Ptaszkiewicz
 *
 */

var HWARS = (function() {
        "use strict";
    var _views, _assets, _ws;

    /**
     * Widoki w grze obsługiwane przez maszynę stanową. Zawiera całą logikę związaną z przełączaniem między widokami.
     *
     * _views.current() - zwraca aktualny stan
     */
    _views = StateMachine.create({
            initial: "init",
            events: [
                {name: "loaded", from: "init", to: "lobby"},
                {name: "toBattle", from: "lobby", to: "battle"},
                {name: "toLobby", from: "battle", to: "lobby"}
            ],
            callbacks: {
                /* po inicjalizacji gry */
                onleaveinit: function(event, from, to){
                    $("#lScreen").fadeOut("slow", function () {
                        _views.transition(); /* wymagane do poczekania do konca animacji */
                    });
                    return StateMachine.ASYNC;
                },

                /* przy wchodzeniu do lobby */
                onenterlobby: function (event, from, to) {
                    $("#lobby").fadeIn("slow");
                },

                /* przy wychodzeniu z bitwy */
                onleavebattle: function(event, from, to){
                    $("#battle").fadeOut("fast", function () {
                        _views.transition();
                    });
                    return StateMachine.ASYNC;
                },

                /* przy wchodzeniu do bitwy */
                onenterbattle: function (event, from, to) {
                    $("#battle").fadeIn("fast");
                }
            }
        });

    /**
     * Sprawdzenie obsługi WebSocketów przez przeglądarkę
     *
     * @returns {boolean} true - jeśli wpierane, inaczej false
     * @private
     */
        var _WS_support = function(){
            if('WebSocket' in window &&
                (typeof WebSocket === 'function' || typeof WebSocket === 'object')){

                return true;
            }

            return false;
        };

    /**
     * Sprawdzenie wsparcia WebGL przez przeglądarkę.
     *
     * @returns {boolean} true - jeśli wspierane, inaczej false
     * @private
     */
        var _WebGL_support = function(){
            if(!window.WebGLRenderingContext){
                return false;
            }
            else {
                // i ewentualne problemy
                var cv = document.createElement('canvas'),
                    ctx = cv.getContext('webgl');

                if(!ctx){
                    return false;
                }
            }

            return true;
        };

        /* zwrot funkcji publicznych, tylko funkcja inicjalizujaca init */
        return {
            init: function () {
                /* pokazanie loading screena */
                $("#lScreen").fadeIn(1200, function(){
                    var msgDiv = $("#lScreen .info_text"); /* wypisywanie komunikatow podczas ladowania */

                    // funckja pomocnicza do wypisywania co aktualnie jest robione - dziala tylko podczas inicjalizacji
                    var msg = function(what, err = 0) {
                        var msg = '<span';
                        if(err){
                            msg += ' style="color:red;"';
                        }

                        msg += `>${what}</span>`;
                        msgDiv.html(msg);
                    };

                    // wypisanie komunikatu o ilicjalizacji klienta
                    msg(lang.init);

                    /* sprawdzenie wsparcia dla websocket i webgl */
                    if(!_WS_support()){
                        msg(lang.errors.ws, 1);
                        return;
                    }
                    if(!_WebGL_support()){
                        msg(lang.errors.webgl, 1);
                        return;
                    }

                    msg(lang.ws.initConn);

                    {
                        var tmp = window.location.href;
                        tmp = tmp.slice(tmp.indexOf('=') + 1, tmp.length);
                        _ws = new WebSocket("ws://localhost:9002?id=" + tmp);
                    }

                    _ws.onopen = function(){
                        console.log("polaczony!");
                    };


                    msg(lang.loaded);

                    /* wczytanie lobby */
                    _views.loaded();
                });

            }
        }
})();