---
name: skill-sync
description: >
  Gebruik deze skill vlak nadat een skill is aangemaakt of bewerkt (bv. via
  skill-creator, of een handmatige edit van een SKILL.md onder
  ~/.claude/skills/) om te checken of die skill al in Chiel's plugin repo
  (~/git/claude-plugins) staat. Bestaat de skill daar al: toon een diff
  tussen de lokale en repo-versie en vraag bevestiging voor je de
  repo-versie overschrijft. Bestaat de skill nog niet in de repo: vraag
  Chiel of hij lokaal (alleen dit apparaat) of in de plugin repo (alle
  apparaten, via git) moet komen. Triggers: "sync deze skill naar mijn
  repo", "moet deze skill in de repo?", "update de skill repo", of
  vergelijkbare verzoeken om een net gemaakte/gewijzigde skill in sync te
  brengen met de plugin repo. Gebruik deze skill NIET voor het aanmaken of
  verbeteren van een skill zelf (dat is skill-creator) — alleen voor het
  wegschrijven/synchroniseren ervan naar de juiste plek.
---

# Skill Sync

Chiel beheert skills op twee plekken:
- **Lokaal**: `~/.claude/skills/<naam>/` — laadt automatisch als `<naam>@skills-dir`, alleen op dit apparaat.
- **Plugin repo**: `~/git/claude-plugins/skills/<naam>/` — via git, dus beschikbaar op alle apparaten na `claude plugin marketplace update` + `claude plugin update` + restart.

Doel van deze skill: na het maken/wijzigen van een skill, zorgen dat de juiste kopie (lokaal en/of repo) up-to-date is — zonder duplicaten die uit sync raken (zie eerdere incidenten met dubbele kanban-skills).

## Constants

- `REPO_PATH` (default): `~/git/claude-plugins` — kan per machine anders zijn of ontbreken, zie stap 0.
- `REPO_URL`: `https://github.com/Chiel-CBTC/claude-plugins.git`
- `LOCAL_SKILLS_PATH`: `~/.claude/skills`
- `WIKI_OVERZICHT_URL`: `https://app.notion.com/p/3951495d13948187a7b2fbc73b724d3a` — "chiel-skills — Persoonlijke skills in de plugin repo", het overzicht van alle skills in deze repo.

## Steps

0. **Zorg dat de repo lokaal beschikbaar is voor je iets met "repo" doet.** Niet elke machine heeft `~/git/claude-plugins` staan. Check eerst of het default pad bestaat; zo niet, zoek breder (bv. `find ~ -maxdepth 4 -iname claude-plugins -type d`) voor het geval 'ie ergens anders geclonet is. Vind je 'm nergens: vraag Chiel of je de repo mag clonen (`git clone REPO_URL`) en waar (stel het default pad voor), en clone pas na bevestiging — dit is de enige stap die iets buiten `~/.claude` aanraakt, dus niet zomaar zelf een pad verzinnen en clonen. Ga pas door naar stap 1 zodra je een werkend `REPO_PATH` hebt.

1. **Bepaal welke skill het betreft.** Meestal duidelijk uit de conversatie (net aangemaakt/bewerkt via skill-creator, of Chiel noemt de naam). De mapnaam onder `skills/` is de identifier — die moet overeenkomen tussen lokaal en repo.

2. **Check of de skill al in de repo staat**: kijk of `REPO_PATH/skills/<naam>/` bestaat.

   - **Bestaat al in de repo:**
     - Diff de lokale versie (`LOCAL_SKILLS_PATH/<naam>/`) tegen de repo-versie bestand voor bestand (niet alleen SKILL.md — ook eventuele `scripts/`, `references/`, `assets/` submappen).
     - Toon de diff aan Chiel en vraag expliciet bevestiging voor je de repo-versie overschrijft — nooit stilzwijgend overschrijven, ook al lijkt de wijziging klein.
     - Na bevestiging: kopieer de gewijzigde bestanden naar de repo, run `git status`/`git diff --stat` in de repo zodat Chiel ziet wat er klaarstaat. Commit alleen als hij dat expliciet vraagt (zelfde regel als altijd bij git).
     - Herinner Chiel eraan dat de wijziging pas actief wordt na commit+push en op elke machine na `claude plugin marketplace update chiel-plugins && claude plugin update chiel-skills@chiel-plugins` + restart — dit is precies wat er zonet mis kon gaan bij de wrap-up-fix (versie bleef hangen op de oude commit tot expliciet ge-update).

   - **Staat nog niet in de repo (nieuwe skill):**
     - Vraag Chiel kort: alleen lokaal houden, of ook in de plugin repo opnemen? Geef er zelf een lichte voorkeur bij (repo, tenzij de skill duidelijk machine-specifiek is — bv. iets dat verwijst naar een pad of tool die alleen op dit device bestaat).
     - Kiest hij voor de repo: maak `REPO_PATH/skills/<naam>/` aan, kopieer alle bestanden van de lokale skill erin, laat `git status` zien, en vraag of hij wil dat je meteen de losse lokale kopie in `LOCAL_SKILLS_PATH/<naam>/` verwijdert (zelfde patroon als bij de eerdere opschoning: alleen verwijderen na duidelijke bevestiging, nooit automatisch).
     - Kiest hij voor lokaal: geen verdere actie nodig, wel kort bevestigen dat 'ie zo blijft staan (niet meegenomen naar andere machines).

3. **Werk `WIKI_OVERZICHT_URL` bij** — bij elke skill die in de repo landt (nieuw of gewijzigd): update de tabelrij van deze skill in de wiki-pagina (naam, trigger, korte beschrijving), of voeg een nieuwe rij toe in de juiste categorie-tabel. Gebruik `notion-update-page` met `update_content` (gerichte search-and-replace), niet `replace_content`. Sla deze stap alleen over als Chiel alleen voor "lokaal houden" koos.

4. **Rond af** met een korte statusregel: wat is waar terechtgekomen (incl. of de wiki is bijgewerkt), en wat Chiel eventueel nog moet doen (committen/pushen, of op een andere machine updaten).
