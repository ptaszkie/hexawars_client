<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="css/game.css" rel="stylesheet">
    <title>Laravel</title>
</head>
<body>
<!-- LOADING SCREEN -->
<div id="lScreen" class="view">
    <div class="logo"></div>
    <div class="spacer"></div>
    <div class="info_text"></div>
    <div class="loadbar">
        <div class="bar"></div>
    </div>
</div>

<!-- LOBBY -->
<div id="lobby" class="view">
    <div class="top-panel"></div>
    <div class="core-panel"></div>
    <div class="chat-panel"></div>
</div>

<!-- BATTLE -->
<div id="battle" class="view">
    <p> Juz za chwilę skopie Ci ktos  dupęęęęę!</p>
</div>
<noscript>Twoja przeglądarka nie wspiera javascript, wymaganego do działania gry Hexawars.</noscript>
</body>

<script src="js/lib/little-loader.js"></script>

<script>
    var ll = "../games/hexawars/js/";
    /* wczytanie skryptow, nie wyglada to ladnie, ale to wina ograniczen biblioteki :/ */
    window._lload("js/lib/js-state-machine.js", function(){
        window._lload("js/lib/jquerry-3.0.0.js", function() {

            //TODO: obsluga innych jezykow
            window._lload("js/lang/pl.js", function () {
                window._lload("js/main.js", function () {
                    HWARS.init();
                });
            });
        });
    });
</script>