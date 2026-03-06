<p>Здравствуйте{{ $guestName ? ', ' . e($guestName) : '' }}!</p>
<p>Ваш QR для входа в бизнес-центр:</p>
<p>
    <img
        src="{{ $message->embedData($qrPng, 'qr.png', 'image/png') }}"
        alt="QR code"
        style="width: 280px; height: 280px;"
    >
</p>
<p>
    Помещение: {{ $placeName ?? '—' }}<br>
    Время: {{ $startTime }} — {{ $endTime }}
</p>
