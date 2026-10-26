-- Web search: the module's page and its navbar link.
--
-- Runs once (it is a migration), after core's navbar layout, so the link
-- lands straight in the right pin. `tools/module.php purge websearch` forgets it,
-- so the next `tools/install.php --schema-only` puts everything back.
-- Its link goes in the public navbar switched off: the federated search
-- (module fedsearch) already offers this engine as a tab. Turn it on in
-- Admin > Navbar to list the page on its own.

INSERT IGNORE INTO `page` (url_id, i18n, file_name, template, controller, hidden, comments)
VALUES ('WORDING_WEBSEARCH', 1, 'web_search', 1, 1, 0, 0);

UPDATE `page` SET `module` = 'websearch'
 WHERE `module` = '' AND `file_name` = 'web_search';

INSERT IGNORE INTO `page_closure` (ancestor, descendant)
SELECT id, id FROM `page` WHERE url_id = 'WORDING_WEBSEARCH';

INSERT IGNORE INTO `page_meta` (page_id, title, description)
SELECT id, '', '' FROM `page` WHERE url_id = 'WORDING_WEBSEARCH';

INSERT IGNORE INTO `page_robots` (page_id, `index`, follow)
SELECT id, 1, 1 FROM `page` WHERE url_id = 'WORDING_WEBSEARCH';

-- ── Navbar link ──────────────────────────────────────────────────────────────
SET @websearch_page := (SELECT id FROM `page` WHERE url_id = 'WORDING_WEBSEARCH' LIMIT 1);
SET @websearch_navbar := (SELECT id FROM `navbar` WHERE name = 'public' LIMIT 1);
-- The alphabetical pin, where every module's public link goes.
SET @websearch_pin := (
    SELECT id FROM `navbar_pin` WHERE navbar_id = @websearch_navbar AND sort_mode = 0
     ORDER BY sort_order ASC, id ASC LIMIT 1
);
SET @websearch_existing := (
    SELECT ni.id FROM `navbar_internal` ni
      JOIN `navbar_entry` e  ON e.id = ni.id
      JOIN `navbar_pin`   np ON np.id = e.pin_id
     WHERE ni.page_id = @websearch_page AND np.navbar_id = @websearch_navbar LIMIT 1
);
INSERT INTO `navbar_entry_ids` (id)
SELECT NULL WHERE @websearch_page IS NOT NULL AND @websearch_pin IS NOT NULL AND @websearch_existing IS NULL;
SET @websearch_nav := COALESCE(@websearch_existing, LAST_INSERT_ID());
INSERT IGNORE INTO `navbar_entry` (id, pin_id, internal, name, i18n, active, sort_order)
SELECT @websearch_nav, @websearch_pin, 1, 'WORDING_WEBSEARCH', 1, 0, 0
 WHERE @websearch_page IS NOT NULL AND @websearch_pin IS NOT NULL AND @websearch_nav IS NOT NULL;
INSERT IGNORE INTO `navbar_internal` (id, page_id)
SELECT @websearch_nav, @websearch_page
 WHERE @websearch_page IS NOT NULL AND @websearch_nav IS NOT NULL;
