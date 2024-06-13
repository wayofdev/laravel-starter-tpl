<?php

declare(strict_types=1);

namespace Bridge\Laravel\Public\Category\Queries;

use Domain\Category\Models\Category;
use Illuminate\Http\Request;
use Infrastructure\Filters\FuzzyFilter;
use Spatie\QueryBuilder\AllowedFilter;
use Spatie\QueryBuilder\QueryBuilder;

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
