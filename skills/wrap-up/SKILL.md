---
name: wrap-up
description: >
  Gebruik deze skill aan het eind van een sessie om de samenvatting weg te
  schrijven naar de Notion "Sessions" database, gescoped op de huidige
  directory + machine. Triggers: "/wrap-up", "wrap up", "sla de sessie op",
  "schrijf de samenvatting weg", of vergelijkbare verzoeken om de sessie af
  te sluiten met een Notion-recap.
---

# Wrap Up Session

Write the session summary into today's row for this directory + machine in the Notion "Sessions" database — the same row that mid-session updates (per `CLAUDE.md`) should already be writing to. One row per directory per machine per day, never more.

## Execution

Always do the actual work (steps 1-6 below) in a subagent — call the `Agent` tool with `subagent_type: "fork"` (it inherits the full conversation, needed for step 2). Never run the Notion query/create/update calls on the main thread. This keeps the Notion tool-call noise out of the main conversation's context. After the fork reports back, relay its final confirmation (step 6) to the user yourself.

## Constants

- Data source: `collection://af890d8c-9a71-4500-b2e8-89e3ac7449eb`
- `PROJECT_PATH` — working directory, from session context
- `MACHINE` — hostname, from session context (run `hostname` if not already known)
- `NOW` — the current local timestamp with UTC offset. ALWAYS get this by running `date -Iseconds` — never guess or infer it from context/training. A guessed timestamp tends to land hours off (e.g. UTC instead of local), which is exactly the kind of bug that's easy to miss because the row still looks plausible.

## Steps

1. Check for today's row for this directory + machine using `mcp__claude_ai_Notion__notion-query-data-sources` (SQL mode):
   ```sql
   SELECT "url", "Title", "Summary", "date:Timestamp:start" FROM "collection://af890d8c-9a71-4500-b2e8-89e3ac7449eb"
   WHERE "Directory" = ? AND "Machine" = ? ORDER BY "date:Timestamp:start" DESC LIMIT 1
   ```
   params: `[PROJECT_PATH, MACHINE]`. `date:Timestamp:start` is stored in UTC — do NOT filter by date in the query itself (a `substr(...,1,10) = today` match breaks near local midnight, since the local date and the UTC date can differ). Instead, convert the returned timestamp to local time (run `date -d "<value>" +%Y-%m-%d` or equivalent) and compare that to today's local date (`date +%Y-%m-%d`). If it matches, that row's `url` is the one to update. If it doesn't match (or no row exists), a new row is needed.

2. Review the conversation: what was built or changed, decisions made, anything useful for next time.

3. Determine what is NOT yet captured (compare against the existing `Summary` from step 1, if any). Only write what is new — skip anything already noted.

4. If there is new information to add, determine tags:
   - Fetch the current Tags options via `mcp__claude_ai_Notion__notion-fetch` on `collection://af890d8c-9a71-4500-b2e8-89e3ac7449eb` (schema lists existing multi-select options).
   - Pick 1-3 tags that fit the session content, reusing existing options where possible (merge with any tags already on the row, don't drop them).
   - If nothing fits, propose one new tag name and ask the user for a quick confirmation before writing.

5. Write the row:
   - **Row already exists (from step 1)** — update it via `mcp__claude_ai_Notion__notion-update-page` (`update_properties`, `page_id` = the `url`/id from step 1): merge the new material into `Summary` (append or rewrite, keep it coherent), bump `Title` and `date:Timestamp:start` to `NOW`, merge `Tags`.
   - **No row yet** — create one via `mcp__claude_ai_Notion__notion-create-pages`, `parent`: `{"type": "data_source_id", "data_source_id": "af890d8c-9a71-4500-b2e8-89e3ac7449eb"}`, properties:
     - `Title`: `"{basename of PROJECT_PATH} · {YYYY-MM-DD HH:mm}"`
     - `Directory`: `PROJECT_PATH` (exact string, matches existing select option or creates a new one)
     - `Machine`: `MACHINE` (exact string, matches existing select option or creates a new one)
     - `date:Timestamp:start`: `NOW`, `date:Timestamp:is_datetime`: `1`
     - `Tags`: JSON array string of the chosen tags, e.g. `["blog","rtk"]`
     - `Summary`:
       ```
       Gebouwd/gewijzigd:
       - [bullet list]
       Beslissingen: [key decisions]
       Volgende keer: [items for next session]
       ```
   - Either way, put the note under `properties.Summary`, NOT the page's top-level `content` field — `content` creates page body blocks that the dedupe query and `fetch-notion-memory.py` never read, so the note silently becomes invisible to both. Leave `content` empty.

6. Confirm to the user: "Samenvatting weggeschreven naar Notion (`PROJECT_PATH`). Je kunt nu afsluiten met /exit." If nothing new: "Alles was al weggeschreven. Je kunt afsluiten met /exit."
