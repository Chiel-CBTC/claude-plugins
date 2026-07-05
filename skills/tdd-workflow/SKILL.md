---
name: tdd-workflow
description: >
  Gebruik deze skill bij elke code-wijziging die logica of functionaliteit
  raakt — nieuwe features, bugfixes, refactors van gedrag, wijzigingen aan
  functies/components met testbaar gedrag. NIET nodig voor pure content-,
  copy-, styling- of tekstwijzigingen zonder testbaar gedrag (bijv. een
  kleurtje aanpassen, een zin herschrijven, spacing tweaken). Triggers:
  "bouw een feature", "fix deze bug", "implementeer X", "voeg functionaliteit
  toe", "pas de logica aan", of vergelijkbare verzoeken om gedrag van code te
  wijzigen.
---

# Test-Driven Development workflow

Bij elke wijziging die logica of functionaliteit raakt: **altijd** eerst de test(s), dan pas de implementatie. Nooit implementatiecode schrijven vóór de bijbehorende test faalt.

## Wanneer wel / niet

- **Wel**: nieuwe features, bugfixes, gedragswijzigingen, refactors die output/logica veranderen.
- **Niet**: pure content-, copy-, styling- of tekstwijzigingen zonder testbaar gedrag. Twijfel je? Vraag het na in plaats van TDD over te slaan of onnodig toe te passen.

## Testlaag bepalen

- **E2E (bijv. Playwright)** voor UI-gedrag, pagina's, user flows.
- **Unit tests (bijv. vitest/jest)** voor pure logica/functies zonder UI (bijv. `lib/`-helpers).
- Gebruik de bestaande testconventie van het project — check `package.json` scripts (`npm run e2e`, `npm test`, `npm run test`, etc.) en bestaande testmappen (`e2e/`, `__tests__/`) voordat je een nieuw patroon introduceert.

## Stappen — in deze volgorde, nooit overslaan

1. **Schrijf of herschrijf eerst de test(s)** die het gewenste (nieuwe of gewijzigde) gedrag beschrijven.
2. **Run de test(s)** en bevestig dat ze **falen** (rood). Dit is een harde stap — sla 'm niet over, ook niet als je "toch al weet" dat de test klopt. Als de test slaagt vóór de implementatie bestaat, klopt er iets niet aan de test.
3. **Bouw de implementatie** die het gedrag laat kloppen.
4. **Run de test(s) opnieuw** en bevestig dat ze nu **slagen** (groen).
5. **Run de volledige testsuite** (niet alleen de nieuwe/gewijzigde tests) om regressies uit te sluiten.

## Rapportage

Meld kort welke tests zijn toegevoegd/gewijzigd, dat ze eerst faalden (rood) en daarna slaagden (groen), en of de volledige suite nog steeds slaagt. Claim nooit "werkt" zonder deze stappen daadwerkelijk uitgevoerd te hebben.
