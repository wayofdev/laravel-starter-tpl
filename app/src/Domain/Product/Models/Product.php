<?php

declare(strict_types=1);

namespace Domain\Product\Models;

use Database\Factories\ProductFactory;
use Domain\Category\Models\Category;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

final class Product extends Model
{
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
