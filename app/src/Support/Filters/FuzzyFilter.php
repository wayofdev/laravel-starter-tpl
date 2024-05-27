<?php

declare(strict_types=1);

namespace Support\Filters;

use Illuminate\Database\Eloquent\Builder;
use Spatie\QueryBuilder\Filters\Filter;

class FuzzyFilter implements Filter
{
    /**
     * @var string[]
     */
    protected array $fields;

    public function __construct(string ...$fields)
    {
        $this->fields = $fields;
    }

    public function __invoke(Builder $query, $value, string $property): Builder
    {
        $query->where(function (Builder $query) use ($value): void {
            foreach ($this->fields as $field) {
                $values = (array) $value;

                foreach ($values as $value) {
                    $query->orWhere($field, 'LIKE', "%{$value}%");
                }
            }
        });

        return $query;
    }
}
