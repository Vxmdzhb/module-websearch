<?php
declare(strict_types=1);

/**
 * Clear-web search backend config. The section 'WebSearchConfig' is named
 * after the class; there is no WebSearchConfig.config.php, so ModuleLoader
 * falls back to this file, named after the parent namespace segment (like
 * BotTrapConfig → BotTrap.config.php).
 *
 * base_url must be the local websearch engine. Only its scheme and host are
 * used; the user's query and page are appended safely. Anything that isn't
 * http(s) is replaced by the localhost default.
 */
return [
    'WebSearchConfig' => [
        'base_url'        => 'http://127.0.0.1:8803', // astrx-websearch `serve` endpoint (localhost only)
        'timeout_seconds' => 3,                       // per-request network timeout (clamped 1–5)
        'per_page'        => 10,                       // results-per-page hint (engine paginates; clamped 1–50)
    ],
];
