<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ServiceType;

class ServiceTypeSeeder extends Seeder
{
    public function run(): void
    {
        $types = [
            [
                'name' => 'Клининг',
                'description' => 'Уборка помещений, поддержание чистоты, вывоз мусора, генеральная и регулярная уборка рабочих пространств.',
                'is_active' => true,
            ],
            [
                'name' => 'Тех. обслуживание',
                'description' => 'Обслуживание инженерных систем, ремонт оборудования, устранение неисправностей и поддержание работоспособности помещений.',
                'is_active' => true,
            ],
        ];

        foreach ($types as $type) {
            ServiceType::create([
                'name' => $type['name'],
                'description' => $type['description'],
                'is_active' => $type['is_active'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
