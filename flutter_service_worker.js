'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "46dcfe4b31cff8769ba4dd41ec6d4ded",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"favicon.png": "55246db4798d6a3ec38f768180f45aa5",
"icons/Icon-maskable-512.png": "6d3a0822e1781674e9307f11d40589e9",
"icons/Icon-maskable-192.png": "39a7c94faf4475813c229a474923e816",
"icons/Icon-512.png": "6d3a0822e1781674e9307f11d40589e9",
"icons/Icon-192.png": "39a7c94faf4475813c229a474923e816",
"manifest.json": "663445316a7d7a4718985289a65a0917",
"version.json": "9915fecfc06e02f153e814daf0464628",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"main.dart.js": "55b60ef3c0dce324fbaa61ab991562cf",
"index.html": "2d0531460728f6a66dc05e410d188ec8",
"/": "2d0531460728f6a66dc05e410d188ec8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/FontManifest.json": "ad6d987e84255d7cf335621500a005a1",
"assets/NOTICES": "b9825f1138d49171d26710229e1d2eba",
"assets/AssetManifest.json": "bdeb1451b5f854d33013f6648d9bd66a",
"assets/AssetManifest.bin": "995dd105ca84548fa4120e253e9d3c61",
"assets/AssetManifest.bin.json": "a70052c9aefe28168c51d4b9f7b000e4",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "ea439c5ff092807ba3345f61b466bd44",
"assets/assets/images/fourd.png": "30c8eb0f39c70a707c50eccd8bbecbfc",
"assets/assets/images/queenc.png": "ab0c775e4dd5d03fd6fdbc1360fcab0b",
"assets/assets/images/threeh.png": "cc9e9a6b9329a14a84a1ac9282728913",
"assets/assets/images/threed.png": "d2de6750aa1232988d35f574fd46a9fc",
"assets/assets/images/kings.png": "30f68add7b91480f3d2bea2e7b351941",
"assets/assets/images/card_back_green.png": "cdbd1423875b291033a584e5358023d2",
"assets/assets/images/threec.png": "d4e73d950a79691fe12b38130c070515",
"assets/assets/images/twoh.png": "dad17fbc04191c5b7c885e497d732a3d",
"assets/assets/images/jacks.png": "0128819cd1f987b8f4ab0db783ae7746",
"assets/assets/images/jackh.png": "5cfc09b311c5753760a383d54264f23c",
"assets/assets/images/threes.png": "f5f3b1346bf07e2a5421b91f10dbe2e0",
"assets/assets/images/aces.png": "0dea84d5d386f402699df45dd115dc47",
"assets/assets/images/aceh.png": "ff4fb7c869faf0ae1b4592fd2ea6ac45",
"assets/assets/images/sixd.png": "34cc2203152634fa70f94d341a9f439c",
"assets/assets/images/fourh.png": "7708b74e0aa393d6b305b3da4cc4f1d9",
"assets/assets/images/nineh.png": "e02a98bafd0ea57fc9c3723ec7e9c6ca",
"assets/assets/images/kingc.png": "25ed216df486f1cf4c11d2b89a97dba4",
"assets/assets/images/kingd.png": "0fe2733d1d8af09fcb0322089b76fce1",
"assets/assets/images/nines.png": "630fce3d4e0bea5ba37c7027e7e00686",
"assets/assets/images/eights.png": "9be4da0b9e832b3ec7dbb55c0051186e",
"assets/assets/images/queenh.png": "ce1fdc06018d18042bdf11b6bfeeb2bf",
"assets/assets/images/twod.png": "11f661e9d7fe5842fbdd259a5bfe6897",
"assets/assets/images/ninec.png": "cc96db1f61be3e5f5535f9b9730dad1c",
"assets/assets/images/fives.png": "40783596a315170d6d2ec7dac7d27f54",
"assets/assets/images/sevens.png": "7fa3ef45540dd269d0cb14aabd03250e",
"assets/assets/images/kingh.png": "d6318a2ae974eb85cf6d02523ab68ec3",
"assets/assets/images/sixh.png": "b1bed2133e1c266784901cee2bfbb5ce",
"assets/assets/images/sevenh.png": "1c8dfa9bcf2ff269ff4a703cd2e134ce",
"assets/assets/images/sixs.png": "cb4d4ade24adce64eca1d471d3db069b",
"assets/assets/images/tenh.png": "e1ebf9fe2b73202c937eff2c23ba2a74",
"assets/assets/images/card_back_blue.png": "06a84f93a7dd0da761eb8c37969ed2b4",
"assets/assets/images/fivec.png": "c4c2e2c089580bc4ecd76edc3a0fcdc6",
"assets/assets/images/aced.png": "5be76faf8e3e305c1e5a038e79d905aa",
"assets/assets/images/fiveh.png": "a787f2c9ff11a6e2d697e8c6eeb271e4",
"assets/assets/images/card_back_red.png": "486d75c3b512fccc51864258506f0871",
"assets/assets/images/tenc.png": "12b07400ac107606cf1567390e255080",
"assets/assets/images/eightd.png": "dce685a2c60aaa3713f2cfc4bfb356b7",
"assets/assets/images/tend.png": "9a1dc8c9d7a5add371aafc6afa000d1e",
"assets/assets/images/acec.png": "9820178ed9367c8a21f83ccf4be90252",
"assets/assets/images/jackc.png": "6fc4edc10a8954fb03d4fcfe9219f617",
"assets/assets/images/eighth.png": "74c0bc8808b41a05fd1b4748c76d097a",
"assets/assets/images/sixc.png": "8b16f01398cfc427ceaf52a99d88b957",
"assets/assets/images/fourc.png": "a044cd0632a8155d2e1eeec098e6b02b",
"assets/assets/images/fours.png": "31347b4228fbb55e2eeea0b3ab1b42bc",
"assets/assets/images/card_back_purple.png": "7461ffb3271d1944934f2c087ef6077c",
"assets/assets/images/sevend.png": "6c42ea145350297e8ee500d61802b422",
"assets/assets/images/jackd.png": "7985c068aba39e6f34ab1e9caa9d4c43",
"assets/assets/images/nined.png": "296673abe1bfbd34c05aa2b20b9a3925",
"assets/assets/images/tens.png": "1252b3425c79b7dc98d4c9a62bdbe5b1",
"assets/assets/images/card_back_black.png": "8f77f719dd9a34557ab18ae4f7114bfa",
"assets/assets/images/twos.png": "f1f2df16158fb393f64c6ed7ada6d92c",
"assets/assets/images/twoc.png": "1a9fa05a142f23a374b34ea751e26091",
"assets/assets/images/fived.png": "9385f0e31073ac5dd8bf723b9be0e166",
"assets/assets/images/queens.png": "4ef97d4c458e6850c208b50d02d094c9",
"assets/assets/images/eightc.png": "9b44788493f78d9a4bd810e6c18c0c12",
"assets/assets/images/queend.png": "4aabdca6a0850e2ec82a03e2dfdd54b2",
"assets/assets/images/table.png": "833a2cad974f07d44e56e553bc6c02b4",
"assets/assets/images/sevenc.png": "a9d9f1ac71f6fe570291b0c329a2b226",
"assets/assets/drawables/hearts.png": "ae50861b62c38c5c49f0ec88db3bfe40",
"assets/assets/drawables/clubs.png": "1d04f424767281bc8cac8a9985cc938a",
"assets/assets/drawables/background3.jpg": "81d093f4ba5024a59460a97deb73ac98",
"assets/assets/drawables/hearts1.png": "76d010b2e577b22afe949e9fdd8f7c67",
"assets/assets/drawables/cardBack4.png": "edf1f5124c1c1bedbeb7068b7551ee24",
"assets/assets/drawables/diamonds.png": "7528f6a5dfe982456b0377c6a934416b",
"assets/assets/drawables/background4.jpg": "316ff3ee3704a413c576d2ebe57024a3",
"assets/assets/drawables/spades.png": "78a01023ae82968c515116355429a7b5",
"assets/assets/drawables/brand.png": "bb23d42c175539495d575814ea82091b",
"assets/assets/drawables/logo.png": "49a50519316f958c78bddf9470fc8689",
"assets/assets/drawables/card_score.png": "e5c3d8fac1d01c5b063c160f2d4a2314",
"assets/assets/drawables/cardBack2.png": "1745720070d2466fcef6ab117e11c8e4",
"assets/assets/drawables/cardBack1.png": "83356430299ee84f7c9dbe307e30cd12",
"assets/assets/drawables/background2.jpg": "a5a7ef04fe26a0afbd45b18be8218977",
"assets/assets/drawables/background.jpg": "02104e256507b43e1a65b3c2e566af6a",
"assets/assets/drawables/taj.png": "0af03cc44332d4cb537f9ce4d0d9eb40",
"assets/assets/drawables/cardBack3.png": "35e782e4088b6cb709199702a334d80d",
"assets/assets/drawables/clubs1.png": "7e2de03479aa60dc54a85b18846eb69b",
"assets/assets/drawables/spades1.png": "05a33849acfe34de667fb3c1326ad178",
"assets/assets/drawables/diamonds1.png": "69a6910f235ff133a5e4c715261b4c49",
"assets/assets/songs/boresh.mp3": "2826183a30b39da53fadcecc368b0959",
"assets/assets/songs/pakhsh.mp3": "10bf446a4bbab5f7cc1ce034a909c0b3",
"assets/assets/songs/success.mp3": "de7c0cf36488e8bae779a91a49d5d0cd",
"assets/assets/songs/lose.mp3": "4d051f67909f6e8f845ad5297e82795d",
"assets/assets/fonts/Vazirmatn-Bold.ttf": "21e9b423e0a84275e89eb2990cb2a547",
"assets/assets/fonts/Vazirmatn-Regular.ttf": "8f2848bf65df549bbfae40abbb005e56"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
