<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zayavka №{{ $service->id }}</title>
    <link rel="stylesheet" href="../../../public/style.css">
</head>
<body>
<div class="header">
    <div class="company-name">Business center "Rabochaya tochka."</div>
    <div class="document-title">Zayavka na obslujivanie nomer:{{ $service->id }}</div>
    <div class="document-date">
        Data sozdaniya: {{ $service->created_at->format('d.m.Y H:i') }}
    </div>
</div>

<div class="service-info">
    <div class="info-row">
        <span class="info-label">Status zayavki:</span>
        <span class="info-value">
                <span class="status-badge status-{{ $service->status }}">
                         {{ $service->status }}
                </span>
            </span>
    </div>

    <div class="info-row">
        <span class="info-label">Tip uslugi:</span>
        <span class="info-value">{{ $service_type->name }}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Pomeshenie:</span>
        <span class="info-value">
                <br>(Nazvanie: {{ $place->name }}<br>
                Nomer: {{ $place->number_place }},<br>
                Tip: {{ $place->type }})<br>
            </span>
    </div>

    <div class="info-row">
        <span class="info-label">Data obslujivaniya:</span>
        <span class="info-value">{{ $service->service_date->format('d.m.Y') }}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Vremya obslujivaniya:</span>
        <span class="info-value">{{ $service->service_time->format('H:i') }}</span>
    </div>

    <div class="info-row">
        <span class="info-label">Zayavitel:</span>
        <span class="info-value">
                {{ $user->last_name }} {{ $user->first_name }} {{ $user->patronymic ?? '' }}
                <br>
                <small class="user-email">{{ $user->email }}</small>
                @if($user->post || $user->company)
                <br>
                <small class="user-details">
                        {{ $user->post ?? '' }} @if($user->post && $user->company) / @endif {{ $user->company ?? '' }}
                    </small>
            @endif
            </span>
    </div>

    @if($booking)
        <div class="info-row">
            <span class="info-label">Bronirovanie:</span>
            <span class="info-value">
                ID: {{ $booking->id }}<br>
                Period: {{ $booking->start_time->format('d.m.Y H:i') }} - {{ $booking->end_time->format('d.m.Y H:i') }}
            </span>
        </div>
    @endif

    @if($service->comment)
        <div class="comment-box">
            <strong class="comment-title">Comment:</strong>
            <p class="comment-text">{{ $service->comment }}</p>
        </div>
    @endif
</div>

@if($service->status === 'completed' && $service->completed_at)
    <div class="completed-block">
        <strong>Zayavka vipolnena:</strong> {{ $service->completed_at->format('d.m.Y H:i') }}
    </div>
@endif

<div class="signature">
    <div class="signature-item">
        <div>Zayavitel</div>
        <div class="signature-line"></div>
        <div class="signature-name">_________________ /{{ $user->last_name }}/</div>
    </div>
    <div class="signature-item">
        <div>Otvetstvenni`</div>
        <div class="signature-line"></div>
        <div class="signature-name">_________________ /Administrator/</div>
    </div>
</div>

<div class="footer">
    <p>Document sgenerirovan avtomaticheski {{ $generated_at }}</p>
    <p>Business center "Rabochaya tochka."  +7 (999) 123-45-67  business-center.ru</p>
    <p class="footer-disclaimer">danni` document yavlyaetsya official`nim podtverjdeniem zayavki</p>
</div>
</body>
</html>
