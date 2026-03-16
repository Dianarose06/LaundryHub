// Service Worker for LaundryHub - handles font caching and network resilience
const CACHE_NAME = 'laundryhub-v1';
const FONT_CACHE = 'laundryhub-fonts-v1';
const STATIC_ASSETS = [
  '/',
  '/index.html',
];

// Install event
self.addEventListener('install', (event) => {
  console.log('[SW] Installing service worker');
  self.skipWaiting();
});

// Activate event
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating service worker');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && cacheName !== FONT_CACHE) {
            console.log('[SW] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch event - cache fonts and provide fallbacks
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Cache fonts from Google Fonts
  // Use credentials: 'omit' to prevent CORS issues with wildcard allow-origin
  if (url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com') {
    event.respondWith(
      caches.open(FONT_CACHE).then((cache) => {
        return cache.match(request).then((response) => {
          if (response) {
            console.log('[SW] Font from cache:', url.pathname);
            return response;
          }

          return fetch(request, { mode: 'cors', credentials: 'omit' })
            .then((response) => {
              if (response && response.status === 200) {
                console.log('[SW] Font fetched and cached:', url.pathname);
                cache.put(request, response.clone());
                return response;
              }
              return response;
            })
            .catch((error) => {
              console.warn('[SW] Font fetch failed:', url.pathname, error);
              // Return a minimal response to prevent error
              return new Response('Font loading deferred', {
                status: 200,
                statusText: 'Deferred',
                headers: new Headers({
                  'Content-Type': 'text/plain',
                }),
              });
            });
        });
      })
    );
    return;
  }

  // Default fetch strategy for other requests
  event.respondWith(
    fetch(request)
      .then((response) => {
        if (!response || response.status !== 200 || response.type !== 'basic') {
          return response;
        }
        return response;
      })
      .catch((error) => {
        console.warn('[SW] Fetch failed:', request.url, error);
        throw error;
      })
  );
});
