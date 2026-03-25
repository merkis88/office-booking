<?php
namespace App\DTO;

abstract class BaseDTO
{
    public static function fromRequest(array $data): static
    {
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
                if ($param->getType()?->allowsNull()) {
                    $params[$name] = null;
                } elseif ($param->isDefaultValueAvailable()) {
                    $params[$name] = $param->getDefaultValue();
                } else {
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
