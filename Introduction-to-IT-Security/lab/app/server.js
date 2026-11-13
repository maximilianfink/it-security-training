// Pizza Pronto – online ordering website
// Written by Luca (IT guy & nephew of the owner) on a few weekends.
// WARNING: This application is intentionally vulnerable. Only run it in the training lab!

const express = require('express');
const cookieParser = require('cookie-parser');
const serialize = require('node-serialize');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');
const _ = require('loadsh');
const { formatPrice, deliveryEta } = require('pronto-utils');
const { renderReceipt } = require('tiny-receipt');

const app = express();
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
// Quick file sharing for the family: everything in public/backup and public/dev can be browsed
function listing(dir) {
  return (req, res) => {
    const files = fs.readdirSync(path.join(__dirname, 'public', dir));
    res.send(`<html><body><h1>Index of /${dir}/</h1><ul>${files.map((f) => `<li><a href="/${dir}/${f}">${f}</a></li>`).join('')}</ul></body></html>`);
  };
}
app.get('/backup/', listing('backup'));
app.get('/dev/', listing('dev'));
app.use(express.static(path.join(__dirname, 'public')));

// TODO move to config file before going live
const ADMIN_USER = 'luca';
const ADMIN_PASSWORD = 'Pronto2024!';

// The cooks log in on the kitchen tablet with a short PIN (nobody wants to type a password there)
const KITCHEN_PIN = '1234';

const ORDERS_FILE = path.join(__dirname, 'data', 'orders.json');

const MENU = [
  { id: 'margherita', name: 'Margherita', price: 850 },
  { id: 'salami', name: 'Salami', price: 990 },
  { id: 'funghi', name: 'Funghi', price: 950 },
  { id: 'diavola', name: 'Diavola (spicy!)', price: 1090 },
  { id: 'quattro', name: 'Quattro Formaggi', price: 1150 },
];

function loadOrders() {
  if (!fs.existsSync(ORDERS_FILE)) return [];
  return JSON.parse(fs.readFileSync(ORDERS_FILE, 'utf8'));
}

function saveOrders(orders) {
  fs.writeFileSync(ORDERS_FILE, JSON.stringify(orders, null, 2));
}

// The shopping cart is stored in a cookie so we don't need a database for it
function readCart(req) {
  if (!req.cookies.cart) return { items: [] };
  const json = Buffer.from(req.cookies.cart, 'base64').toString();
  const cart = serialize.unserialize(json);
  cart.items = Object.values(cart.items || {});
  return cart;
}

function writeCart(res, cart) {
  res.cookie('cart', Buffer.from(serialize.serialize(cart)).toString('base64'));
}

function page(title, body, cartCount = 0) {
  const badge = cartCount > 0 ? ` <span class="badge">${cartCount}</span>` : '';
  return `<!doctype html>
<html><head><meta charset="utf-8"><title>${title} – Pizza Pronto</title>
<link rel="stylesheet" href="/style.css"></head>
<body><header><img src="/logo.svg" alt=""><h1>Pizza Pronto</h1>
<nav><a href="/">Menu</a> <a href="/team">Team</a> <a href="/cart" class="cart-link">🛒 Cart${badge}</a> <a href="/kitchen">Kitchen</a></nav></header>
<main>${body}</main>
<footer>Pizza Pronto · Hauptstraße 12 · Open daily 11:00–23:00 · <a href="/imprint">Imprint</a></footer></body></html>`;
}

app.get('/', (req, res) => {
  const cart = readCart(req);
  const added = MENU.find((p) => p.id === req.query.added);
  const flash = added ? `<p class="flash">✓ ${added.name} added to your cart</p>` : '';
  const rows = MENU.map((p) => `
    <li><span class="name">${p.name}</span><span class="price">${formatPrice(p.price)}</span>
    <form method="post" action="/cart/add"><input type="hidden" name="id" value="${p.id}"><button>Add to cart</button></form></li>`).join('');
  const cta = cart.items.length
    ? `<p class="hint"><a class="cartcta" href="/cart">🛒 Go to cart (${cart.items.length} item(s)) →</a></p>`
    : `<p class="hint">Your cart is empty.</p>`;
  res.send(page('Menu', `<!-- TODO Luca: alte Admin-Seite /old-admin/ vor Go-Live löschen!! Login ist noch admin/admin -->
${flash}<h2>Our pizzas</h2><ul class="menu">${rows}</ul>${cta}
<p class="hint"><a href="/speisekarte-2026.pdf">Menu as PDF</a></p>`, cart.items.length));
});

app.post('/cart/add', (req, res) => {
  const cart = readCart(req);
  const pizza = MENU.find((p) => p.id === req.body.id);
  if (pizza) cart.items.push(pizza);
  writeCart(res, cart);
  res.redirect('/?added=' + (pizza ? pizza.id : ''));
});

app.post('/cart/remove', (req, res) => {
  const cart = readCart(req);
  const idx = cart.items.findIndex((p) => p.id === req.body.id);
  if (idx !== -1) cart.items.splice(idx, 1);
  writeCart(res, cart);
  res.redirect('/cart');
});

app.get('/cart', (req, res) => {
  const cart = readCart(req);
  const items = _.sortBy(cart.items, 'name');
  const total = items.reduce((sum, p) => sum + p.price, 0);
  // group identical pizzas so the cart shows "2x Salami"
  const groups = {};
  for (const p of items) {
    if (!groups[p.id]) groups[p.id] = { pizza: p, qty: 0 };
    groups[p.id].qty += 1;
  }
  const rows = Object.values(groups).map(({ pizza, qty }) => `
    <li><span class="name">${qty}× ${pizza.name}</span>
    <span class="price">${formatPrice(pizza.price * qty)}</span>
    <form method="post" action="/cart/remove"><input type="hidden" name="id" value="${pizza.id}"><button class="remove" title="Remove one">✕</button></form></li>`).join('');

  if (items.length === 0) {
    return res.send(page('Cart', `<h2>Your cart</h2>
      <p class="hint">Your cart is empty.</p>
      <p><a class="cartcta" href="/">← Back to the menu</a></p>`, 0));
  }
  res.send(page('Cart', `<h2>Your cart</h2>
    <ul class="menu cart">${rows}</ul>
    <p class="total"><b>Total: ${formatPrice(total)}</b></p>
    <p><a href="/">← Add more pizzas</a></p>
    <h3>Delivery address</h3>
    <form method="post" action="/order" class="order">
      <input name="name" placeholder="Name" required>
      <input name="address" placeholder="Street, ZIP, City" required>
      <input name="phone" placeholder="Phone" required>
      <input name="notes" placeholder="Special requests (e.g. no onions)">
      <button>Order now (${formatPrice(total)})</button>
    </form>`, items.length));
});

app.post('/order', (req, res) => {
  const cart = readCart(req);
  if (cart.items.length === 0) return res.redirect('/');
  const orders = loadOrders();
  const order = {
    id: orders.length + 1,
    name: req.body.name,
    address: req.body.address,
    phone: req.body.phone,
    notes: req.body.notes || '',
    status: 'new',
    items: cart.items.map((p) => p.name),
    total: cart.items.reduce((sum, p) => sum + p.price, 0),
    createdAt: new Date().toISOString(),
  };
  orders.push(order);
  saveOrders(orders);
  res.clearCookie('cart');
  res.send(page('Thank you', `<h2>Grazie, ${order.name}!</h2>
    <p>Estimated delivery: ${deliveryEta(order.address)}</p>
    <pre>${renderReceipt(order)}</pre>`));
});

// ---------------- Kitchen dashboard (used by the cooks) ----------------

const STATUSES = { new: 'New', cooking: 'Cooking', done: 'Done' };

function requireKitchen(req, res, next) {
  if (req.cookies.kitchen === 'ok') return next();
  res.send(page('Kitchen login', `<h2>Kitchen login</h2>
    <form method="post" action="/kitchen/login" class="order login">
      <p>Enter the kitchen PIN:</p>
      <input name="pin" type="password" placeholder="PIN" autofocus>
      <button>Log in</button>
    </form>`));
}

app.post('/kitchen/login', (req, res) => {
  if (req.body.pin === KITCHEN_PIN) {
    // cookie has no HttpOnly flag, so JavaScript on the page can read it
    res.cookie('kitchen', 'ok');
    return res.redirect('/kitchen');
  }
  res.send(page('Kitchen login', `<h2>Kitchen login</h2>
    <p class="flash" style="background:#f8d7da;border-color:#c0392b;color:#a11">Wrong PIN.</p>
    <p><a href="/kitchen">Try again</a></p>`));
});

app.get('/kitchen', requireKitchen, (req, res) => {
  const orders = loadOrders();
  const columns = Object.keys(STATUSES).map((st) => {
    const cards = orders
      .filter((o) => (o.status || 'new') === st)
      .map((o) => {
        const next = st === 'new' ? 'cooking' : st === 'cooking' ? 'done' : null;
        const button = next
          ? `<form method="post" action="/kitchen/order/${o.id}/status"><input type="hidden" name="to" value="${next}"><button>${next === 'done' ? 'Done' : 'Start cooking'}</button></form>`
          : '';
        // NOTE: name and notes are rendered without escaping (intentional stored-XSS bug)
        return `<div class="ticket"><b>#${o.id} ${o.name}</b>
          <div>${o.items.join(', ')}</div>
          ${o.notes ? `<div class="notes">📝 ${o.notes}</div>` : ''}
          <div class="addr">${o.address} · ${o.phone}</div>${button}</div>`;
      })
      .join('');
    return `<div class="kcol kcol-${st}"><h3>${STATUSES[st]}</h3>${cards || '<p class="hint">–</p>'}</div>`;
  }).join('');
  res.send(page('Kitchen', `<h2>Incoming orders</h2><div class="kboard">${columns}</div>`));
});

app.post('/kitchen/order/:id/status', requireKitchen, (req, res) => {
  const orders = loadOrders();
  const order = orders.find((o) => String(o.id) === req.params.id);
  if (order && STATUSES[req.body.to]) {
    order.status = req.body.to;
    saveOrders(orders);
  }
  res.redirect('/kitchen');
});

// ---------------- Admin area ----------------

function requireAdmin(req, res, next) {
  const header = req.headers.authorization || '';
  const [user, password] = Buffer.from(header.replace('Basic ', ''), 'base64').toString().split(':');
  if (user === ADMIN_USER && password === ADMIN_PASSWORD) return next();
  res.set('WWW-Authenticate', 'Basic realm="Pizza Pronto Admin"').status(401).send('Login required');
}

app.get('/admin', requireAdmin, (req, res) => {
  const rows = loadOrders().map((o) => `<tr><td>${o.id}</td><td>${o.name}</td><td>${o.address}</td><td>${o.phone}</td><td>${o.items.join(', ')}</td></tr>`).join('');
  res.send(page('Admin', `<h2>Orders</h2>
    <table><tr><th>#</th><th>Name</th><th>Address</th><th>Phone</th><th>Items</th></tr>${rows}</table>
    <h3>Kitchen printer check</h3>
    <form action="/admin/printer"><input name="host" value="192.168.0.50"><button>Ping printer</button></form>`));
});

app.get('/admin/printer', requireAdmin, (req, res) => {
  exec(`ping -c 1 ${req.query.host}`, (err, stdout, stderr) => {
    res.send(page('Printer check', `<h2>Printer check</h2><pre>${stdout}${stderr}</pre><a href="/admin">Back</a>`));
  });
});

// ---------------- Legacy admin (Luca forgot to delete this) ----------------
// The very first prototype panel, from before the "real" /admin existed. Still online,
// still protected only by admin/admin. Exactly the kind of forgotten page attackers love.

app.get('/old-admin/', (req, res) => {
  res.send(page('Old admin', `<h2>Pizza Pronto – Admin (old)</h2>
    <p class="hint">Internal tool. Please log in.</p>
    <form method="post" action="/old-admin/login" class="order login">
      <input name="user" placeholder="User" autofocus>
      <input name="password" type="password" placeholder="Password">
      <button>Log in</button>
    </form>`));
});

app.post('/old-admin/login', (req, res) => {
  const { user, password } = req.body;
  if (user !== 'admin' || password !== 'admin') {
    return res.status(401).send(page('Old admin', `<h2>Login failed</h2>
      <p class="flash" style="background:#f8d7da;border-color:#c0392b;color:#a11">Wrong user or password.</p>
      <p><a href="/old-admin/">Try again</a></p>`));
  }
  const customers = loadOrders()
    .map((o) => `<tr><td>${o.name}</td><td>${o.address}</td><td>${o.phone}</td></tr>`)
    .join('');
  res.send(page('Old admin', `<h2>⚠️ Legacy admin panel</h2>
    <p class="flash" style="background:#fff3cd;border-color:#e0a800;color:#8a6d00">
      This is the old prototype panel Luca built first. It should have been deleted before go-live –
      but the <code>admin/admin</code> login still works, so whoever finds it becomes "admin".</p>
    <p><b>Flag captured:</b> <code>FLAG{old_admin_never_deleted}</code></p>
    <h3>Saved logins (so the family doesn't forget)</h3>
    <pre>shop admin        : luca / Pronto2024!
kitchen tablet PIN : 1234
office PC          : Pizza2026!
instagram          : pizzapronto_lb / Bruno2026!</pre>
    <h3>All customers</h3>
    <table><tr><th>Name</th><th>Address</th><th>Phone</th></tr>${customers}</table>`));
});

app.get('/team', (req, res) => {
  res.send(page('Team', `<h2>Our team</h2>
    <p><b>Giulia Romano</b> – owner. Running Pizza Pronto with passion since 2009, born 1975 in Naples.</p>
    <p><b>Lena Schuster</b> – apprentice (office management) since 01.09.2026. Takes care of e-mails, suppliers
       and our Instagram <i>@pizzapronto_lb</i>.</p>
    <p><b>Luca Romano</b> – our "IT guy", studies computer science and built this shop. Loves his dog <i>Bruno</i> and VfB Stuttgart.</p>
    <p><b>Marco &amp; Elif</b> – kitchen. <b>Jonas, Mia, Kevin</b> – delivery.</p>
    <p><img src="/img/friday-rush.jpg" width="300" alt="Friday rush"><br><small>Friday rush – from our Instagram</small></p>`));
});

app.get('/imprint', (req, res) => {
  res.send(page('Imprint', `<h2>Imprint</h2>
    <p>Pizza Pronto · Owner: Giulia Romano<br>Hauptstraße 12, 71634 Ludwigsburg (fictional)<br>Phone 07141 555 0101</p>
    <p>E-mail: <a href="mailto:giulia.romano@pizza-pronto.example">giulia.romano@pizza-pronto.example</a><br>
       Technical contact: <a href="mailto:luca.romano@pizza-pronto.example">luca.romano@pizza-pronto.example</a></p>`));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Pizza Pronto shop running on http://localhost:${PORT}`));
