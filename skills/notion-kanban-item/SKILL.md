---
name: notion-kanban-item
description: >
  Gebruik deze skill wanneer Chiel snel een item op het gedeelde Notion Kanban
  Board wil zetten. Triggers: "zet dit op het bord", "maak een kanban item",
  "voeg toe aan de backlog", "nieuw issue/task/bug/idee", of vergelijkbare
  verzoeken om iets vast te leggen op het Kanban Board in Notion. Werkt voor
  meerdere projecten — het Project-veld wordt afgeleid uit de context van de
  huidige chat/Project, niet hardcoded. Houd de vragen minimaal — dit is
  bedoeld voor snelle invoer, niet voor een uitgebreide intake.
---

# Notion Kanban item aanmaken

## Database

- Data source: `collection://2e91495d-1394-8096-a79e-000b66755152` (database "Kanban Board")
- Parent voor `notion-create-pages`:
```json
  {"type": "data_source_id", "data_source_id": "2e91495d-1394-8096-a79e-000b66755152"}
```

## Project bepalen

`Project` is een select-veld. Bepaal de waarde als volgt:

1. Zit de chat in een Claude Project (heeft een projectnaam)? → gebruik die naam als `Project`, zonder te vragen. Bestaat deze optie nog niet in het Notion select-veld, maak 'm dan gewoon aan (nieuwe select-optie) bij het aanmaken van de pagina.
2. Zit de chat **niet** in een Claude Project (geen projectnaam beschikbaar)? → vraag Chiel kort welk project het betreft. Nooit gokken of zelf iets verzinnen.

## Vaste/standaardwaarden

- `Priority` = `Medium` — altijd automatisch invullen, tenzij Chiel expliciet `High` of `Low` aangeeft.
- `Status` = `Sprint Backlog` — altijd automatisch invullen, tenzij Chiel expliciet iets anders aangeeft (bv. `Overall Backlog`) of aangeeft dat het al verder opgepakt is (`In progress`, `Test`) — gebruik dan die waarde zonder te vragen.
- `Issue Type` = `Task` — tenzij Chiel iets anders aangeeft, of de aard evident anders is uit de omschrijving (bv. "site geeft een foutmelding" = `Bug`). Neem dit dan aan en meld de aanname kort in plaats van te vragen.
- `icon` = `https://www.notion.so/icons/checkmark_red.svg` — altijd meegeven bij het aanmaken.
- `Cluster` — altijd kort navragen bij Chiel, ook bij een duidelijke match. Doe zelf wel de beste suggestie op basis van bestaande opties in het veld, zodat Chiel alleen hoeft te bevestigen of te corrigeren.

## Titel en omschrijving

- **Issue** (titel): kort en bondig, actiegericht (werkwoord + onderwerp), bv. "Nieuwsbericht skate 4-daagse plaatsen" — niet "Skate 4-daagse".
- **Content/omschrijving**: altijd invullen, ook als de titel al duidelijk lijkt. Geef hier de extra context: wat er precies moet gebeuren, waarom, en eventuele details die niet in de titel passen.

Vraag **alleen expliciet** naar Issue Type als het echt niet uit de context is af te leiden. `Assigned to` en `Due date` blijven leeg tenzij Chiel ze uit zichzelf noemt — nooit proactief vragen.

## Velden en toegestane waarden

| Veld | Type | Waarden |
|---|---|---|
| Issue | title | vrije tekst (verplicht, kort en actiegericht) |
| Issue Type | select | `Bug`, `User Story`, `Task`, `Idea` |
| Project | select | naam van het huidige Claude Project (nieuwe optie aanmaken indien nodig); zonder Claude Project → navragen |
| Status | status | `Overall Backlog`, `Sprint Backlog`, `In progress`, `Test`, `Resolved`, `Won't fix`, `Archived` |
| Priority | select | `High`, `Medium` (default), `Low` |
| Cluster | select | bestaande opties — zelf inschatten, bij geen match vragen |
| Assigned to | person | optioneel |
| Due date | date | optioneel, formaat `date:Due date:start` |

## Aanmaken

Gebruik `notion-create-pages` met:

```json
{
  "parent": {"type": "data_source_id", "data_source_id": "2e91495d-1394-8096-a79e-000b66755152"},
  "pages": [{
    "properties": {
      "Issue": "<korte, actiegerichte titel>",
      "Issue Type": "<type>",
      "Project": "<afgeleid project>",
      "Status": "Sprint Backlog",
      "Priority": "Medium",
      "Cluster": "<beste match>"
    },
    "content": "<omschrijving, altijd invullen>",
    "icon": "https://www.notion.so/icons/checkmark_red.svg"
  }]
}
```

## Na aanmaken

Meld kort welk item is aangemaakt (titel, project, type, status) met een link. Geen verdere toelichting of samenvatting nodig — dit is een snelle actie, geen rapportage.
