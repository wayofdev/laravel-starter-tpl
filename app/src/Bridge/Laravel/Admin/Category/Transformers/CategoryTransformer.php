<?php

declare(strict_types=1);

namespace Laravel\Admin\Category\Transformers;

use Domain\Category\Models\Category;
use League\Fractal\TransformerAbstract;

final class CategoryTransformer extends TransformerAbstract
{
    /**
     * @return array<string, mixed>
     */
    public function transform(Category $category): array
    {
        return [
            'id' => $category->uuid,
            'name' => $category->name,
            'gender' => $category->gender,
            'created_at' => $category->created_at,
            'updated_at' => $category->updated_at,
        ];
    }
}
