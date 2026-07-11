---
name: ticktick-add-task
description: Gebruik deze skill wanneer Chiel een taak, todo of herinnering wil laten aanmaken in TickTick (mcp__claude_ai_TickTick__create_task). Triggers — "zet dit in TickTick", "maak een TickTick-taak/reminder aan", "herinner me eraan dat...", "voeg toe aan TickTick", of vergelijkbare verzoeken om iets in TickTick vast te leggen. Vraagt altijd kort naar prioriteit, dag en of er een melding gewenst is, voordat de taak wordt aangemaakt. Niet gebruiken voor het Notion Kanban Board (zie notion-kanban-item) — dit is specifiek voor TickTick.
---

# TickTick-taak aanmaken

## Waarom deze vragen

TickTick-taken zonder prioriteit/datum/melding raken makkelijk onzichtbaar tussen de rest. Drie korte vragen voorkomen dat een taak in de inbox verdwijnt zonder dat Chiel 'm ooit weer tegenkomt — dat weegt zwaarder dan de paar seconden die het kost om te vragen.

## Plaatsing

Altijd in de **Inbox** — geef nooit `projectId` mee aan `create_task`. Chiel sorteert zelf later in TickTick.

## Vragen (kort houden, net als notion-kanban-item)

Gebruik `AskUserQuestion` (of stel ze inline als het er maar één of twee zijn en de context al duidelijk is) voor:

1. **Prioriteit** — default **Medium**, tenzij Chiel 'm al genoemd heeft in zijn verzoek.
   - Waarden voor de tool: None=0, Low=1, **Medium=3 (default)**, High=5.
2. **Dag** — default **vandaag**, tenzij Chiel al een dag/datum noemde (bv. "komende maandag", "morgen", "3 augustus").
   - Bepaal "vandaag" altijd met `date -Iseconds` (nooit gokken/afleiden) — zelfde reden als bij Notion-sessienotities: een geraden datum zit er zo een dag naast.
   - Relatieve dagen (bv. "komende maandag") omrekenen naar absolute datum met `date -d`.
3. **Melding gewenst?** — ja/nee.
   - **Ja** → vraag ook naar het **tijdstip**. Zet dan:
     - `dueDate` = dag + tijdstip (ISO 8601 met tijdzone, Europe/Amsterdam)
     - `isAllDay`: false
     - `timeZone`: "Europe/Amsterdam"
     - `reminders`: `["TRIGGER:PT0S"]` (melding op het moment van de due date zelf — TickTick's eigen meldingsvoorkeuren gelden voor eventuele extra triggers, dus dit is de simpele default)
   - **Nee** → alleen een datum, geen tijdstip:
     - `dueDate` = dag (om middernacht/zonder tijdcomponent)
     - `isAllDay`: true
     - geen `reminders`

Vraag **niet** naar project/lijst — die staat vast op Inbox. Vraag ook niet naar tags of checklist-items tenzij Chiel dat zelf aangeeft.

## Aanmaken

Gebruik `mcp__claude_ai_TickTick__create_task` met een `task`-object, bijvoorbeeld met melding:

```json
{
  "task": {
    "title": "<korte, actiegerichte titel>",
    "dueDate": "2026-07-13T09:00:00+02:00",
    "isAllDay": false,
    "timeZone": "Europe/Amsterdam",
    "priority": 3,
    "reminders": ["TRIGGER:PT0S"]
  }
}
```

Of zonder melding (all-day):

```json
{
  "task": {
    "title": "<korte, actiegerichte titel>",
    "dueDate": "2026-07-13T00:00:00+02:00",
    "isAllDay": true,
    "timeZone": "Europe/Amsterdam",
    "priority": 3
  }
}
```

Geef nooit `projectId` mee — dat plaatst de taak automatisch in de Inbox.

## Na aanmaken

Meld kort welke taak is aangemaakt: titel, dag, prioriteit, en of er een melding gezet is (met tijdstip). Geen verdere toelichting nodig — dit is een snelle actie, geen rapportage.
