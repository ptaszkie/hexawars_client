var Hexawars = function () {
    "use strict";

    // enum events
    var EVENT = {
            CHAT_MSG:       0,
            CHAT_SEND:      1,
            JOIN_BATTLE:    2
        },

        MSG  = {
            PLAYER_DATA_REQ:    0,
            PLAYER_DATA:        1,
            JOIN_BATTLE:        10,
            MSG_GLOBAL:         20
        },

        cfg = {
            // finite state machine settings
            state: {
                initial: "boot",
                events: [
                    {name: 'init',              from: 'boot',           to: 'initialize'},      // init a game
                    {name: 'connectToServer',   from: 'initialize',     to: 'connecting'},      // connect to a server
                    {name: 'loadAssets',        from: 'connecting',     to: 'loading'},         // load assets
                    {name: 'assetsLoaded',      from: 'loading',        to: 'lobby'},           // go to a lobby
                    {name: 'findBattle',        from: 'lobby',          to: 'waitingBattle'},   // looking for a battle
                    {name: 'abortFindBattle',   from: 'waitingBattle',  to: 'lobby'},           // abort waiting for the battle
                    {name: 'startBattle',       from: 'waitingBattle',  to: 'battle'},          // return to the lobby
                    {name: 'win',               from: 'battle',         to: 'lobby'},           // return to the lobby
                    {name: 'lose',              from: 'battle',         to: 'lobby'}            // return to the lobby
                ]
            },

            // game events list handlers
            events_list: [
                {event: EVENT.CHAT_MSG,         action: function (from, channel, msg)   {}},
                {event: EVENT.CHAT_SEND,        action: function (channel, msg)         {}},
                {event: EVENT.JOIN_BATTLE,      action: function ()                     {}}
            ],

            // images to load
            images: [],

            // models to load
            models: [],

            // sounds to load
            sounds: [],

            // key settings
            keys: [
//            { key: Game.Key.ONE,    mode: 'up',   state: 'menu',    action: function()    { this.start(PLAYER.WARRIOR);      } },
//            { key: Game.Key.ESC,    mode: 'up',   state: 'playing', action: function()    { this.quit();                     } }
            ]

        }; // end cfg

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // UTILS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // check support of WebGL
    function isSupported_WebGL() {
        if (!window.WebGLRenderingContext)
            return false;

        var cv = document.createElement('canvas');
        return !!cv.getContext('webgl');
    }

    // check support of WebSocket
    function isSupported_WebSocket() {
        return ('WebSocket' in window && (typeof WebSocket === 'function' || typeof WebSocket === 'object'));
    }

    // add event observer to obj
    function addEventObserver(obj, config) {
        obj.addEvent = function (event, callback) {
            this.events = this.events || {};
            this.events[event] = this.events[event] || [];
            this.events[event].push(callback);
        };

        obj.launchEvent = function (event) {
            if (this.events && this.events[event]) {
                var hdls = this.events[event],
                    args = [].slice.call(arguments, 1);

                for (var n = hdls.length - 1; n >= 0; --n)
                    hdls[n].apply(obj, args);
            }
        };

        if (config) {
            var hdl;
            for (var n = config.length - 1; n >= 0; --n) {
                hdl = config[n];
                obj.addEvent(hdl.event, hdl.action);
            }
        }
    }

    var showMSG = function(msg) {
        var args = [].slice.call(arguments, 1),
            len = args.length;

        if(len){
            for(var i = 0; i<len; i++ ){
                //console.log("replace: ${"+(i+1)+"} --> zz" );
                msg = msg.replace("${"+(i+1)+"}", args[i]);
            }
        }

        if(game.current === "lobby" || game.current === "battle")
            console.log(msg);
        else
            $("#lScreen .info_text").html('<span>' + msg + '</span>');
    },
    showError = function(err) {
        $("#lScreen .info_text").html('<span style="color:red;">' + err + '</span>');
    },

    createMessage = function(type, data, to) {
        var mesg = {};
        mesg.type = type;

        if(type === MSG.MSG_GLOBAL)
        {
            mesg.data = data;
        }

        return mesg;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Game object
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    var game = function (){
        var that = this,
            network;

        StateMachine.create(cfg.state, this);
        addEventObserver(this, cfg.state);

        network = new Network("ws://127.0.0.1:9002/?" + location.pathname.substr(1), that, 5);

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // State machine transitions
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        this.onenterconnecting = function(){
            console.log("onenterconnecting()");
            showMSG(lang.WebSocket.connect);
            network.connect();
        };

        this.onloadAssets = function(){
            showMSG(lang.assets.load);

            // todo: pobieranie plikow

            that.assetsLoaded();

        };

        this.onassetsLoaded = function(){
            $("#lScreen").fadeOut("slow", function () {
                $("#lobby").fadeIn("slow")
            });
        };

        this.oninit = function() {
            console.log("oninit()");
            showMSG(lang.initialize); // initialize

            $("#lScreen").fadeIn("slow", function () {
                if(!isSupported_WebSocket()) {
                    showError(lang.WebSocket.unsuported);
                    return false;
                }

                if(!isSupported_WebGL()) {
                    showError(lang.WebGL.unsuported);
                    return false;
                }

                that.connectToServer();
            });
        };


        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Event observer handlers
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Modules
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    var Network = function(uri, obj, max_reconnects) {

        var that = this,
            ws,
            reconnects = 0,
            max_reconnects = max_reconnects || 5;

        this.connect = function () {
            console.log("uri: " + uri + " | rec: " + reconnects);

            if(reconnects)
                showMSG(lang.WebSocket.reconnect, reconnects, max_reconnects);

            else
                showMSG(lang.WebSocket.connect);

            ws = new WebSocket(uri);

            ws.onclose = function (e) {
                console.log("Network.close()[code: " + e.code + "]");
            };

            ws.onerror = function (e) {
                if (reconnects++ < max_reconnects)
                    setTimeout(that.connect, 1000);
                else
                    showError(lang.WebSocket.error);
            };

            ws.onopen = function (e) {
                showMSG(lang.WebSocket.connected);

                that.send(createMessage(MSG.PLAYER_DATA_REQ));
            };

            ws.onmessage = function(e)
            {

                console.log(e);
            }
        };

        this.send = function(msg){
            console.log("sending msg: " + JSON.stringify(msg));
            ws.send(JSON.stringify(msg));
        }
    };


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // return
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    return game;


}();

// todo: wrzucic to do klasy wyzej ;) po przerobce of course...
/*
Game.Key = {
    BACKSPACE: 8,
    TAB: 9,
    RETURN: 13,
    ESC: 27,
    SPACE: 32,
    END: 35,
    HOME: 36,
    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40,
    PAGEUP: 33,
    PAGEDOWN: 34,
    INSERT: 45,
    DELETE: 46,
    ZERO: 48,
    ONE: 49,
    TWO: 50,
    THREE: 51,
    FOUR: 52,
    FIVE: 53,
    SIX: 54,
    SEVEN: 55,
    EIGHT: 56,
    NINE: 57,
    A: 65,
    B: 66,
    C: 67,
    D: 68,
    E: 69,
    F: 70,
    G: 71,
    H: 72,
    I: 73,
    J: 74,
    K: 75,
    L: 76,
    M: 77,
    N: 78,
    O: 79,
    P: 80,
    Q: 81,
    R: 82,
    S: 83,
    T: 84,
    U: 85,
    V: 86,
    W: 87,
    X: 88,
    Y: 89,
    Z: 90,
    TILDA: 192,

    map: function (map, context, cfg) {
        cfg = cfg || {};
        var ele = $(cfg.ele || document);
        var onkey = function (ev, keyCode, mode) {
            var n, k, i;
            if ((ele === document) || ele.visible()) {
                for (n = 0; n < map.length; ++n) {
                    k = map[n];
                    k.mode = k.mode || 'up';
                    if (Game.Key.match(k, keyCode, mode, context)) {
                        k.action.call(context, keyCode, ev.shiftKey);
                        return Game.Event.stop(ev);
                    }
                }
            }
        };
        ele.on('keydown', function (ev) {
            return onkey(ev, ev.keyCode, 'down');
        });
        ele.on('keyup', function (ev) {
            return onkey(ev, ev.keyCode, 'up');
        });
    },

    match: function (map, keyCode, mode, context) {
        if (map.mode === mode) {
            if (!map.state || !context || (map.state === context.current) || (is.array(map.state) && map.state.indexOf(context.current) >= 0)) {
                if ((map.key === keyCode) || (map.keys && (map.keys.indexOf(keyCode) >= 0))) {
                    return true;
                }
            }
        }
        return false;
    }

};

    */