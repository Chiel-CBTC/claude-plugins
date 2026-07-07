---
name: ado-create-pbi
description: >
  Gebruik deze skill altijd wanneer de gebruiker een PBI, user story, backlog item of
  werkitem wil aanmaken in Azure DevOps. Triggers: "maak een PBI", "voeg een PBI toe",
  "nieuw backlog item", "maak een user story", "PBI aanmaken", of wanneer de gebruiker
  iets wil vastleggen als werkitem in Azure DevOps. Stel altijd de vereiste vragen
  voordat je het item aanmaakt — maak nooit een PBI zonder eerst de variabele velden
  op te halen bij de gebruiker.
---

# Azure DevOps PBI aanmaken

## Vaste waarden (altijd automatisch invullen)

| Veld      | Waarde               |
|-----------|----------------------|
| Project   | Zwitch               |
| Iteration | Zwitch               |
| State     | New                  |
| Type      | Product Backlog Item |

Project is standaard `Zwitch` — geef dit altijd expliciet mee als `project`-parameter bij de tool-call, zodat de tool niet zelf om een projectkeuze vraagt. Nooit navragen, tenzij de gebruiker expliciet een ander project noemt.

## Area Path

Vraag altijd welk Area Path van toepassing is. Keuzemogelijkheden:

- `Zwitch\Team Leerkracht`
- `Zwitch\Team Leerling`
- `Zwitch\Team Distributie en Toegang`

## Variabele velden (altijd navragen)

Stel deze vragen **in één bericht**, voordat je iets aanmaakt:

1. **Area Path** — Welk team? (zie keuzes hierboven)
2. **Parent Feature** — Onder welke Feature valt dit PBI? (naam of ID)
3. **Title** — Wat is de titel van de PBI?
4. **Gaat dit over test automation?** — Ja of nee (bepaalt de taglogica, zie hieronder)
5. **User story** — Vul in:
   - *Als* [rol]
   - *Wil ik* [functionaliteit]
   - *Zodat ik* [doel]
6. **Toelichting** — Aanvullende context of technische toelichting? (optioneel)
7. **Acceptatiecriteria** — Wat zijn de acceptatiecriteria? (opsomming)
8. **Gekoppelde PBI's** — Moet dit PBI aan een of meerdere andere werkitems gekoppeld worden als "Related"? Zo ja: welke (ID's of titels)?

## Taglogica

### Geen test automation PBI
Zoek eerst uit welke tags al gangbaar zijn in dit Area Path, i.p.v. blind te vragen:

1. Query recente werkitems in het gekozen Area Path via `wit_query_by_wiql` (bv. laatste ~30, gesorteerd op gewijzigd)
2. Haal de `System.Tags`-waarden op via `wit_get_work_items_batch_by_ids` en verzamel de meest voorkomende tags
3. Toon deze als voorbeeld bij de tags-vraag (bv. "Vaak gebruikte tags in dit team: X, Y, Z — welke zijn relevant, of vrij invullen?")
4. Levert de query niets op of faalt hij: val terug op vrij vragen zonder voorbeelden ("Welke tags zijn relevant? Mag leeg blijven.")

Doel: aansluiten bij bestaande conventies van het team i.p.v. een taxonomie verzinnen voor disciplines waar deze skill geen zicht op heeft.

### Test automation PBI
Stel aanvullend drie gerichte vragen:

1. **Prioriteit** — `high`, `medium` of `low`?
2. **Soort test** — Kies één:
   - `FE Integration Test`
   - `BE Integration Test`
   - `E2E Test`
   - `Smoke Test`
   - `Chain Test`
3. **Evaluatie** — Heeft dit betrekking op de evaluatie-functionaliteit binnen de teacher app? (ja/nee)

Stel deze vragen in hetzelfde bericht als de overige vragen.

De tags worden dan automatisch samengesteld:
- Altijd: `test automation` + gekozen prioriteit + gekozen soort test
- Optioneel: `evaluatie` (alleen als de gebruiker ja zegt)

## Werkwijze

1. Stel alle vragen in één bericht aan de gebruiker
2. Wacht op de antwoorden
3. Toon een samenvatting van het PBI ter bevestiging
4. Maak het PBI aan via de Azure DevOps MCP tool (`create_work_item`) met alle velden. Stuur de Parent Feature **niet** mee als veld — dat zet geen echte hiërarchie-link (zie stap 5)
5. Koppel het nieuwe PBI via `wit_work_items_link`:
   - Altijd: als `"parent"` aan de opgegeven Parent Feature — het `System.Parent`-veld bij `create_work_item` maakt geen echte relatie aan
   - Indien opgegeven: als `"related"` aan de gekoppelde PBI's
6. Haal het aangemaakte item opnieuw op (`wit_get_work_item`, `expand: relations`) en verifieer dat de Parent-link, AreaPath en tags kloppen. ADO kan de AreaPath automatisch overschrijven zodra je aan een parent in een ander team linkt — corrigeer dit zo nodig via `wit_update_work_item`
7. Meld de gebruiker de aangemaakte PBI ID, eventuele koppelingen en een link indien beschikbaar

## Description veldopbouw

```
Als [rol]
Wil ik [functionaliteit]
Zodat ik [doel]

[Toelichting indien opgegeven]

**Acceptatiecriteria:**
- [criterium 1]
- [criterium 2]
```

## Opmerkingen

- Maak nooit een PBI aan zonder eerst de variabele velden te hebben opgehaald
- Title is verplicht; overige velden mogen leeg blijven als de gebruiker dat aangeeft
- Tags worden gescheiden door puntkomma's in Azure DevOps

## Taken (Task) aanmaken onder een PBI

Bij het aanmaken van child Tasks via `wit_add_child_work_items`: de tool erft AreaPath/IterationPath **niet** van de parent — nieuwe taken krijgen de project-root-waarden (bv. `Zwitch` i.p.v. `Zwitch\Team Leerkracht`, en `Zwitch` i.p.v. de actuele sprint). Gevolg: de taak verschijnt niet op het sprintboard.

Na het aanmaken altijd:
1. Parent-PBI opvragen (`wit_get_work_item`) voor de juiste AreaPath + IterationPath
2. Elke nieuwe taak corrigeren via `wit_update_work_items_batch` (`System.AreaPath` + `System.IterationPath` gelijk aan de parent)

## Verwante skills

Voor het **wijzigen** van een bestaand PBI: zie `ado-update-pbi`. Voor een **overzicht/lijst** van PBI's: zie `ado-list-pbis`. Voor het **aanmaken van een bug**: zie `ado-create-bug`.
