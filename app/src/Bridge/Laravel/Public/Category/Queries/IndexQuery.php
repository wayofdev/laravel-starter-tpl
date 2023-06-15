<?php

declare(strict_types=1);

namespace Laravel\Public\Category\Queries;

use Illuminate\Http\Request;
use Spatie\QueryBuilder\QueryBuilder;

final class IndexQuery extends QueryBuilder
{
    public function __construct(Request $request)
    {
        // @phpstan-ignore-next-line
        $query = Category::query();

        parent::__construct($query, $request);
    }
}
