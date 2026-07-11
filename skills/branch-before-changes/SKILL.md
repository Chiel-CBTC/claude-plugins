---
name: branch-before-changes
description: >
  Gebruik deze skill vlak voordat je code gaat wijzigen (Edit/Write/Bash-schrijfacties)
  in een git repo. Check eerst de huidige branch: sta je op master of main, maak dan
  eerst een nieuwe branch aan voordat er iets gewijzigd wordt — nooit direct op
  master/main committen of wijzigen. Sta je al op een andere branch, doe niets en ga
  gewoon verder. Triggers: elke opdracht die code-wijzigingen impliceert (bugfix,
  feature, refactor, styling-fix, content-wijziging) in een directory die een
  git-repository is.
---

# Branch before changes

Voorkom dat wijzigingen per ongeluk direct op `master`/`main` belanden. Deze skill regelt alleen het aanmaken/wisselen van branch — niet TDD, commits of PR's (zie [[tdd-workflow]] en de git-instructies in het systeemprompt daarvoor).

## Stappen

1. Check de huidige branch: `git branch --show-current`.
2. Staat de branch **niet** op `master` of `main` → niets doen, ga gewoon verder met de gevraagde wijziging.
3. Staat de branch **wel** op `master` of `main`:
   - Check `git status` — als er al uncommitted wijzigingen liggen die niet van jou zijn (bestaand werk van de gebruiker), volg de normale voorzichtigheidsregels (stash/committeer niks zonder overleg) voordat je een branch switcht.
   - Maak een nieuwe branch aan en check 'm meteen uit: `git checkout -b <naam>`.
   - Kies `<naam>` kort en beschrijvend voor de taak, in de stijl die dit project al gebruikt (zie `git log`/bestaande branches, bijv. `feature/optimizations`). Gebruik een prefix die bij de aard van de wijziging past: `fix/` voor bugfixes, `feature/` voor nieuwe functionaliteit, `chore/` voor opruim-/configwerk. Geen prefix bekend of twijfel? `fix/` of `feature/` is een veilige default.
   - Meld kort welke branch is aangemaakt, ga dan verder met de wijziging.
4. Dit geldt alleen voor repo's die daadwerkelijk git-repositories zijn. Geen git repo → skill is niet van toepassing.

## Waarom

Werk op `master`/`main` is meteen "live" op de hoofdlijn — een branch geeft ruimte om te reviewen/testen voordat het samenkomt met de rest, en voorkomt dat losse taken door elkaar heen op dezelfde branch belanden.
