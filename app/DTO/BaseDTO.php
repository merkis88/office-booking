<?php
namespace App\DTO;

abstract class BaseDTO
{
    public static function fromRequest(array $data): static
    {
        // Получаем список параметров конструктора
        $reflection = new \ReflectionClass(static::class);
        $constructor = $reflection->getConstructor();

        if (!$constructor) {
            return new static();
        }

        $params = [];
        foreach ($constructor->getParameters() as $param) {
            $name = $param->getName();
            if (array_key_exists($name, $data)) {
                $params[$name] = $data[$name];
            } else {
                // Если параметр опциональный (nullable), можно передать null
                if ($param->getType()?->allowsNull()) {
                    $params[$name] = null;
                } elseif ($param->isDefaultValueAvailable()) {
                    $params[$name] = $param->getDefaultValue();
                } else {
                    // Обязательный параметр отсутствует — ошибка
                    throw new \InvalidArgumentException("Missing required parameter: $name");
                }
            }
        }

        return new static(...$params);
    }

    public function toArray(): array
    {
        return get_object_vars($this);
    }
}
