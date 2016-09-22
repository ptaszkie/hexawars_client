/**
 *
 * Plik z tekstami.
 *
 * Jezyk: Polski
 * Wersja: 0.1
 *
 */

var lang = {
    lang: 'pl_pl',

    initialize: 'Inicjalizacja...',
    loaded: 'Załadowane.',

    WebSocket: {
        connect:            'Nawiązywanie połączenia z serwerem...',
        connected:          'Połączono z serwerem.',
        getPlayerData:      'Pobieranie danych gracza...',
        unsuported:         'Twoja przeglądarka nie obsługuje WebSocket. Zaktualizuj przeglądarkę albo zainstaluj <a href="https://www.google.pl/chrome">Chrome<\a>',
        reconnect:          'Próba ponownego połączenia z serwerem (${1}/${2})',
        error:              'Nie udało się połączyć z serwerem. Spróbój ponownie później.'
    },
    WebGL:{
        unsuported:         'Twoja przeglądarka nie wspiera WebGL. Zaktualizuj przeglądarkę albo zainstaluj <a href="https://www.google.pl/chrome">Chrome<\a>'
    },
    assets:{
        load:               'Rozpoczynam pobieranie zasobów',
        loadFile:           'Pobieram ${1}'
    }

};