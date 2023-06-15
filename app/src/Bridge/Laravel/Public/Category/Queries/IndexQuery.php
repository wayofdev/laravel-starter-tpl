<?php

declare(strict_types=1);

namespace Laravel\Public\Category\Queries;

use Domain\Category\Models\Category;
use Illuminate\Http\Request;
use Spatie\QueryBuilder\AllowedFilter;
use Spatie\QueryBuilder\QueryBuilder;
use Support\Filters\FuzzyFilter;

final class IndexQuery extends QueryBuilder
{
    public function __construct(Request $request)
    {
        $query = Category::query();

        parent::__construct($query, $request);

        $this->allowedFilters([
            AllowedFilter::custom('search', new FuzzyFilter(
                'name',
            )),
        ]);
    }
}
