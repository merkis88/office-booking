<?php
namespace App\DTO\Places;

use App\DTO\BaseDTO;

class ArchivePlaceDTO extends BaseDTO
{
    public function __construct(
        public int $place_id,
        public bool $archive = true,
    )
    {

    }
}
