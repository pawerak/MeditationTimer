# Timer medytacji — aplikacja Connect IQ dla Garmin Venu 2

Prosty, minimalistyczny timer medytacji na zegarek Garmin. Właściciel projektu (Paweł) uczy się Connect IQ — tłumacz decyzje prostym językiem, po polsku. Kod, nazwy i komentarze w kodzie po angielsku.

## Środowisko

- System: Windows, PowerShell.
- Connect IQ SDK 9.3.0 (zainstalowane przez SDK Manager), Java 25 (OpenJDK).
- VS Code z rozszerzeniem Monkey C (Garmin).
- Urządzenie docelowe: **Venu 2** (`venu2`) — okrągły ekran AMOLED 416×416 px, ekran dotykowy + 2 przyciski (górny prawy = START/STOP, dolny prawy = BACK, długie przytrzymanie dolnego = MENU).
- Ścieżkę do SDK znajdziesz w `%APPDATA%\Garmin\ConnectIQ\current-sdk.cfg`. Narzędzia: `monkeyc` (kompilator), `connectiq` (symulator), `monkeydo` (uruchomienie .prg w symulatorze).
- Klucz deweloperski: zapytaj użytkownika o ścieżkę do pliku `.der` przy pierwszej kompilacji. Nigdy nie commituj klucza.
- Kompilacja i uruchomienie (przykład):
  `monkeyc -d venu2 -f monkey.jungle -o bin\MeditationTimer.prg -y <klucz.der> -w`
  następnie uruchom symulator `connectiq` i `monkeydo bin\MeditationTimer.prg venu2`.

## Zasady pracy

1. Pracuj etapami (lista niżej). Po każdym etapie: skompiluj, napraw błędy i ostrzeżenia, uruchom w symulatorze, krótko powiedz użytkownikowi, co ma sprawdzić — i poczekaj na jego potwierdzenie przed kolejnym etapem.
2. Monkey C to niszowy język — **nie zgaduj API**. Gdy nie masz pewności co do klasy, metody, stałej albo wymaganego uprawnienia (permission), sprawdź w dokumentacji: https://developer.garmin.com/connect-iq/api-docs/ lub w dokumentacji w folderze SDK. Jeśli czegoś nie da się zrobić na Venu 2, powiedz to wprost.
3. Pamięć zegarka jest mała: unikaj zbędnych obiektów, ładuj zasoby raz, odświeżaj ekran tylko gdy trzeba (np. raz na sekundę podczas odliczania).
4. Teksty interfejsu w zasobach (`resources/strings`), nie w kodzie. Język domyślny angielski, plus polskie tłumaczenie (`resources-pol`) — aplikacja trafi do sklepu.
5. Rób małe commity w git po każdym działającym etapie.

## Wygląd (wspólny dla wszystkich ekranów)

Minimalizm: czarne tło (AMOLED), dużo pustej przestrzeni, zieleń i błękit jako jedyne akcenty.

| Rola | Kolor |
|---|---|
| Tło | `0x000000` |
| Tekst główny | `0xF2F5F3` |
| Tekst pomocniczy (etykiety) | `0x9AA5A1` |
| Linie, obramowania, nieaktywne | `0x2A3531` |
| Tło pierścienia postępu | `0x16211D` |
| Zielony — akcja, postęp, potwierdzenie | `0x3DDC97` |
| Ciemny tekst na zielonym przycisku | `0x04140D` |
| Niebieski — stres, sygnały pośrednie | `0x4DA3FF` |
| Jasnoniebieski — cyfry na tarczy wyboru | `0x6FB6FF` |
| Delikatna czerwień — ikona serca (tętno) | `0xF07C86` |

Czcionki: systemowe fonty Garmina (np. `FONT_NUMBER_*` dla dużych liczb, `FONT_XTINY`/`FONT_TINY` dla etykiet). Ikony (serce, fala stresu, ptaszek, krzyżyk) rysuj prostymi kształtami albo małymi bitmapami w zasobach.

## Ekrany i zachowanie

### 1. Wybór czasu (ekran startowy)

Wzorowany na natywnym minutniku Garmina — tarcza z cyframi:

- Cyfry 0–9 rozmieszczone na okręgu: środek ekranu (208, 208), promień ok. 152 px, cyfra `n` pod kątem `n × 36°` liczonym od góry zgodnie z ruchem wskazówek zegara (0 na górze, 5 na dole). Kolor `0x6FB6FF`, duży font.
- Na środku: wybrany czas w formacie `HH:MM:SS`, kolor tekstu głównego.
- Nad czasem (ok. y = 132): mały szary krzyżyk — usuwa ostatnią wpisaną cyfrę.
- Pod czasem (ok. y = 290): zielone kółko (ok. 56 px) z ciemnym ptaszkiem — start.
- **Wpisywanie jak w natywnym minutniku**: cyfry wchodzą od prawej. Wpisanie 1,5,0,0 daje `00:15:00`. Maksymalnie 6 cyfr. Zero jako pierwsza cyfra jest ignorowane.
- **Ostatni czas jako domyślny**: po otwarciu aplikacji na środku stoi ostatnio użyty czas (zapisany w `Application.Storage`) z małym podpisem „OSTATNIO” nad nim (`0x9AA5A1`). Ptaszek od razu startuje z tym czasem. Pierwsza wpisana cyfra zastępuje go nowym wpisem i podpis znika. Przy pierwszym uruchomieniu domyślnie 10:00.
- Krzyżyk przy pustym wpisie: przywraca ostatni czas. Przycisk BACK na tym ekranie zamyka aplikację.
- Rozpoznawanie dotknięć: tap w promieniu ok. 36 px od środka cyfry/przycisku.
- Normalizacja przy starcie: czas liczony jako `h×3600 + m×60 + s` (np. wpis 90 sekund = 1:30). Czas 0 — ptaszek nieaktywny.
- Górny przycisk START działa jak ptaszek.

### 2. Odliczanie

- Wokół krawędzi ekranu pierścień postępu: tło `0x16211D`, postęp zielony, grubość ok. 8 px, promień ok. 196 px, start od góry, rośnie zgodnie z ruchem wskazówek.
- Jeśli sygnały co 5 min są włączone: małe niebieskie kropki na pierścieniu w miejscach tych sygnałów (np. przy 15 min — na 1/3 i 2/3 obwodu).
- Środek: mały podpis „Medytacja” (szary), duży pozostały czas `MM:SS` (lub `H:MM:SS` gdy ≥ 1 h), pod nim „z 15:00” (szary).
- Niżej jeden rząd: czerwone serce + tętno + „bpm” | cienka pionowa kreska | niebieska ikona fali + poziom stresu + „stres”. Brak danych → `--`.
- Ekran odświeżany raz na sekundę.
- Sygnał co 5 minut (jeśli włączony w ustawieniach): krótka, delikatna wibracja.
- Koniec czasu: długa, wyraźna wibracja (np. 2–3 impulsy), automatyczne zapisanie aktywności i przejście do podsumowania.
- Przycisk START/STOP podczas odliczania → pauza.

### 3. Pauza

- Na górze szary podpis „Pauza · 09:00” (pozostały czas).
- Trzy opcje jedna pod drugą (szerokość ok. 280 px, wysokość ok. 64 px, zaokrąglone): **Wznów** (zielone tło, ciemny tekst, ikona ▶), **Zapisz** (czarne tło, obramowanie `0x2A3531`), **Odrzuć** (sam szary tekst).
- Zapisz → zapisuje aktywność z faktycznym czasem i pokazuje podsumowanie. Odrzuć → pyta o potwierdzenie, odrzuca sesję i wraca do ekranu wyboru czasu.

### 4. Podsumowanie

- Zielony okrąg z ptaszkiem, pod nim „Medytacja zapisana” (szary), duży czas trwania.
- Rząd dwóch statystyk w kolorze niebieskim: średnie tętno (bpm) | średni stres. Podpisy szare: „śr. tętno”, „śr. stres”.
- BACK lub dotknięcie → zamknięcie aplikacji.

### 5. Ustawienia

- Otwierane długim przytrzymaniem dolnego przycisku (MENU) na ekranie wyboru czasu.
- Opcja: **Sygnał co 5 min** (przełącznik, domyślnie wyłączony), z podpisem „krótka wibracja”.
- Informacja: **Koniec sesji — długa wibracja — zawsze** (bez możliwości wyłączenia).
- Najprościej: natywne menu Connect IQ (`Menu2` z `ToggleMenuItem`). Ustawienie zapisane w `Application.Storage`.
- Opcjonalnie później: to samo ustawienie dostępne w aplikacji Garmin Connect (`properties.xml` + `settings.xml`).

## Zapis aktywności

- Sesja zapisywana przez `ActivityRecording` jako aktywność typu **medytacja**. Sprawdź w dokumentacji, jaka stała sportu/podsportu odpowiada medytacji i czy jest dostępna w SDK 9.3 dla Venu 2; jeśli nie — wybierz najbliższy sensowny typ i powiedz użytkownikowi.
- Tętno powinno zapisywać się automatycznie z czujnika nadgarstkowego.
- Stres: sprawdź, skąd go czytać (np. `SensorHistory` lub `ActivityMonitor`) i jak często się aktualizuje — to nie jest wartość sekundowa. Jeśli nie zapisuje się automatycznie w aktywności, dodaj pole FIT dewelopera (`FitContributor`) ze stresem, żeby był widoczny w Garmin Connect.
- Dodaj wymagane uprawnienia w `manifest.xml` (np. Fitness, Sensor, SensorHistory — zweryfikuj).
- Średnie do podsumowania licz sam z odczytów podczas sesji (lub z danych sesji, jeśli API je udostępnia).

## Etapy

1. **Ekran wyboru czasu**: tarcza cyfr, wpisywanie, krzyżyk, zapamiętywanie ostatniego czasu. Bez odliczania (ptaszek tymczasowo tylko zapisuje czas).
2. **Odliczanie**: pierścień, pozostały czas, tętno, stres, wibracja na końcu.
3. **Pauza i podsumowanie**.
4. **Zapis aktywności** w Garmin Connect (test na prawdziwym zegarku).
5. **Ustawienia**: sygnał co 5 min + kropki na pierścieniu.
6. **Przygotowanie do sklepu**: ikona aplikacji (zielono-niebieska, prosta), tłumaczenia EN/PL, opis, sprawdzenie pamięci i baterii.

## Testy na zegarku (na prośbę użytkownika)

Skompiluj `.prg`, podłącz Venu 2 kablem USB i skopiuj plik do folderu `GARMIN\APPS` na zegarku.
