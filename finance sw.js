const V='fin-v1',SHELL=['/finance.html','/finance.webmanifest','/finance-icon-192.png','/finance-icon-512.png','/finance-icon-180.png','/finance-favicon-32.png'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(V).then(c=>c.addAll(SHELL)).then(()=>self.skipWaiting()));});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==V).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));});
self.addEventListener('fetch',e=>{
  const r=e.request,u=new URL(r.url);
  if(r.method!=='GET'||u.hostname.endsWith('supabase.co'))return;
  if(r.mode==='navigate'||u.pathname==='/finance.html'){
    e.respondWith(fetch(r).then(x=>{const c=x.clone();caches.open(V).then(ch=>ch.put('/finance.html',c));return x;}).catch(()=>caches.match('/finance.html')));return;}
  if(u.hostname==='cdn.jsdelivr.net'||SHELL.includes(u.pathname)){
    e.respondWith(caches.match(r).then(h=>h||fetch(r).then(x=>{if(x.ok){const c=x.clone();caches.open(V).then(ch=>ch.put(r,c));}return x;})));}
});
