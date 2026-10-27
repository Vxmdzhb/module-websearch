<?php
declare(strict_types=1);

namespace AstrX\WebSearch;

use AstrX\I18n\Translator;
use AstrX\Routing\UrlGenerator;
use AstrX\Search\Tab\SearchHit;
use AstrX\Search\Tab\SearchTab;
use AstrX\Search\Tab\SearchTabPage;

/**
 * The Search page's "Web" tab: The web, through the websearch engine. The client has already cleaned every
 * field and reduced each link to http(s).
 */
final class WebSearchTab implements SearchTab
{
    public function __construct(
        private readonly WebSearchClient $client,
        private readonly Translator $t,
        private readonly UrlGenerator $urlGen,
    ) {}

    public function key(): string
    {
        return 'web';
    }

    public function label(): string
    {
        $this->t->load('WebSearch');
        return $this->t->t('websearch.tab');
    }

    public function order(): int
    {
        return 10;
    }

    public function search(string $query, int $page): SearchTabPage
    {
        $this->t->load('WebSearch');
        $more = $this->urlGen->toPage($this->t->t('WORDING_WEBSEARCH'), ['q' => $query]);
        $resp = $this->client->search($query, $page);
        if (!$resp['ok']) {
            return SearchTabPage::unavailable($more);
        }
        $hits = [];
        foreach ($resp['results'] as $r) {
            $hits[] = new SearchHit(
                title:      $r['title'] !== '' ? $r['title'] : $r['url'],
                url:        $r['href'],
                displayUrl: $r['url'],
                snippet:    $r['snippet'],
            );
        }
        $pages = max(1, intdiv($resp['total'] + max(1, $resp['page_size']) - 1, max(1, $resp['page_size'])));
        return new SearchTabPage(true, $hits, $resp['total'], $resp['page'] < $pages, $more);
    }
}
