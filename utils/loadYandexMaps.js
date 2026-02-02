let loadingPromise = null;

export function loadYandexMaps(apiKey) {
  if (window.ymaps) {
    return Promise.resolve(window.ymaps);
  }

  if (loadingPromise) {
    return loadingPromise;
  }

  loadingPromise = new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = `https://api-maps.yandex.ru/2.1/?apikey=${apiKey}&lang=ru_RU`;
    script.async = true;

    script.onload = () => {
      if (!window.ymaps) {
        reject(new Error('Yandex Maps API не загрузился'));
        return;
      }

      window.ymaps.ready(() => resolve(window.ymaps));
    };

    script.onerror = reject;
    document.head.appendChild(script);
  });

  return loadingPromise;
}
