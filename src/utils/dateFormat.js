/**
 * Утилиты форматирования дат бронирований.
 */

/**
 * Форматирует дату бронирования: "27.03.2026"
 */
export function formatBookingDate(isoString) {
  if (!isoString) return '';
  return new Date(isoString).toLocaleDateString('ru-RU');
}

/**
 * Форматирует время бронирования: "14:00"
 */
export function formatBookingTime(isoString) {
  if (!isoString) return '';
  return new Date(isoString).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' });
}

/**
 * Форматирует дату с названием месяца: "27 марта 2026 г."
 */
export function formatBookingDateLong(isoString) {
  if (!isoString) return '';
  return new Date(isoString).toLocaleDateString('ru-RU', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });
}
