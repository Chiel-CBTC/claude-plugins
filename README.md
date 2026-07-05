# claude-plugins

Persoonlijke Claude Code marketplace + plugin met mijn skills. Bedoeld om op elke machine dezelfde skills te installeren en centraal te updaten.

## Installatie (nieuwe machine)

In Claude Code:

```
/plugin marketplace add Chiel-CBTC/claude-plugins
/plugin install chiel-skills@chiel-plugins
```

## Updaten

```
/plugin marketplace update chiel-plugins
/plugin update chiel-skills@chiel-plugins
```

## Nieuwe skill toevoegen

1. Map aanmaken in `skills/<skill-naam>/SKILL.md`
2. Committen en pushen
3. Op andere machines: marketplace + plugin updaten (zie boven)

## Structuur

```
.claude-plugin/
  marketplace.json   # marketplace-definitie (1 plugin: chiel-skills)
  plugin.json         # plugin-definitie
skills/
  <skill-naam>/SKILL.md
```
