<?php
namespace App\DTO\Services;

use App\DTO\BaseDTO;

class CreateServiceDTO extends BaseDTO
{
    public function __construct(
        public int $booking_id,
        public int $service_type_id,
        public string $service_date,
        public string $service_time,
        public ?string $comment=null,
    )
    {

    }
}
