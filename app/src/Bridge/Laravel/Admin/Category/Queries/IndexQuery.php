<?php

declare(strict_types=1);

namespace Bridge\Laravel\Admin\Category\Queries;

use Domain\Category\Models\Category;
use Illuminate\Http\Request;
use Spatie\QueryBuilder\QueryBuilder;

final class IndexQuery extends QueryBuilder
{
    public function __construct(Request $request)
    {
        $query = Category::query();

        parent::__construct($query, $request);

        $this->allowedFilters(['name']);
    }
}
