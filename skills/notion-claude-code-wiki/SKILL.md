---
name: notion-claude-code-wiki
description: >
  Gebruik deze skill wanneer de gebruiker een nieuwe pagina wil toevoegen aan
  zijn Notion "Claude Code Wiki" — de wiki specifiek voor Claude Code-kennis
  (skill, tool, feature, workflow, MCP-server). De gebruiker heeft meerdere
  Notion-wiki's voor verschillende onderwerpen; deze skill is alleen voor de
  Claude Code-wiki, niet voor de andere. Triggers: "voeg een wiki-pagina toe
  over X" (in Claude Code-context), "zet dit in mijn Claude Code wiki",
  "documenteer X in de Claude Code wiki", "voeg kennis toe aan de wiki" (als
  het over Claude Code gaat), "maak hier een wiki-pagina van". Ook gebruiken
  als de gebruiker vraagt om een bestaande Claude Code wiki-pagina bij te
  werken met nieuwe informatie.
---

# Claude Code Wiki: kennispagina toevoegen

Notion Wiki-pagina (parent van alle sub-pagina's): `https://app.notion.com/p/3911495d1394801f88acec24e261a762`
Page ID: `3911495d1394801f88acec24e261a762`

## Werkwijze

1. **Check bestaande pagina's** — fetch de wiki-parent-pagina om te zien welke sub-pagina's er al staan. Bestaat er al een pagina over dit onderwerp? Dan die pagina updaten (zie onderaan) i.p.v. een duplicaat aanmaken.
2. **Stijl-referentie** — fetch één bestaande sub-pagina (bijv. de eerste uit de lijst) om de actuele stijl te bevestigen. De conventies staan ook hieronder vastgelegd, maar de wiki kan intussen zijn geëvolueerd.
3. **Concept opstellen** — titel, icoon en secties in het Nederlands, gebaseerd op de stijlgids hieronder, inclusief de beschikbaarheidstabel onderaan. Baseer de inhoud op wat in het gesprek al besproken/onderzocht is over het onderwerp — niet losstaand aanvullen wat niet bekend is.
4. **Aanmaken** — via `notion-create-pages` met `parent: {"type": "page_id", "page_id": "3911495d1394801f88acec24e261a762"}`.
5. **Rapporteer** de resulterende URL aan de gebruiker.

## Stijlgids (afgeleid van bestaande pagina's)

- **Titel**: `Onderwerp — korte Nederlandse ondertitel` (bijv. "Superpowers — Claude Code skill-systeem")
- **Icoon**: één emoji die bij het onderwerp past
- **Openingsalinea**: 2-3 zinnen — wat het is en waarom het relevant is. Geen kopje erboven.
- **Secties**: `##`-koppen in het Nederlands (bijv. "Installatie", "Wanneer aanroepen", "Relatie tot andere skills")
- **Callouts** voor waarschuwingen/tips: `<callout icon="⚠️" color="yellow_bg">...</callout>` — `yellow_bg` voor waarschuwingen, `blue_bg`/`gray_bg` voor info/tips
- **Tabellen** voor command- of skill-overzichten: `<table header-row="true">...</table>`
- **Code blocks** voor commands en paths
- **Cross-links** naar andere wiki-pagina's: gebruik `<mention-page url="URL">Volledige Paginatitel</mention-page>` (levert een echte klikbare Notion-mention op). Gebruik **nooit** `[[Paginatitel]]`-syntax — dat bestaat niet in Notion's markdown-spec en rendert als platte tekst zonder link.
- Beknopt houden — geen volledige docs-vertaling, wel de kern + praktische gebruiksinfo
- **Beschikbaarheidstabel** — elke pagina eindigt (indien van toepassing) met een `## Beschikbaarheid`-sectie die aangeeft op welk platform de functionaliteit werkt: Claude Code, Claude Desktop, Claude Web. Bij twijfel over een platform: navragen bij de gebruiker i.p.v. gokken. Format:
  ```html
  <table header-row="true">
  <tr><td>Platform</td><td>Beschikbaar</td></tr>
  <tr><td>Claude Code</td><td>✅</td></tr>
  <tr><td>Claude Desktop</td><td>❌</td></tr>
  <tr><td>Claude Web</td><td>❌</td></tr>
  </table>
  ```

## Bestaande pagina updaten i.p.v. nieuwe aanmaken

Als het onderwerp al een pagina heeft: fetch die pagina eerst (verplicht — voorkomt overschrijven van handmatige edits), gebruik dan `update_content` met gerichte `content_updates` (search-and-replace). Gebruik `replace_content` alleen als de hele structuur wijzigt, en let dan op sub-pages — die worden anders meeverwijderd.
