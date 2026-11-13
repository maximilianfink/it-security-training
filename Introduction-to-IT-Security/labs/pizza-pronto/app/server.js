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
app.use(express.static(path.join(__dirname, 'public')));

// TODO move to config file before going live
const ADMIN_USER = 'luca';
const ADMIN_PASSWORD = 'Pronto2024!';

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

function page(title, body) {
  return `<!doctype html>
<html><head><meta charset="utf-8"><title>${title} – Pizza Pronto</title>
<link rel="stylesheet" href="/style.css"></head>
<body><header><img src="/logo.svg" alt=""><h1>Pizza Pronto</h1><nav><a href="/">Menu</a> <a href="/cart">Cart</a></nav></header>
<main>${body}</main>
<footer>Pizza Pronto · Hauptstraße 12 · Open daily 11:00–23:00</footer></body></html>`;
}

app.get('/', (req, res) => {
  const cart = readCart(req);
  const rows = MENU.map((p) => `
    <li><span>${p.name}</span><span>${formatPrice(p.price)}</span>
    <form method="post" action="/cart/add"><input type="hidden" name="id" value="${p.id}"><button>Add</button></form></li>`).join('');
  res.send(page('Menu', `<h2>Our pizzas</h2><ul class="menu">${rows}</ul>
    <p class="hint">${cart.items.length} item(s) in your cart</p>`));
});

app.post('/cart/add', (req, res) => {
  const cart = readCart(req);
  const pizza = MENU.find((p) => p.id === req.body.id);
  if (pizza) cart.items.push(pizza);
  writeCart(res, cart);
  res.redirect('/');
});

app.get('/cart', (req, res) => {
  const cart = readCart(req);
  const items = _.sortBy(cart.items, 'name');
  const total = items.reduce((sum, p) => sum + p.price, 0);
  const rows = items.map((p) => `<li><span>${p.name}</span><span>${formatPrice(p.price)}</span></li>`).join('');
  res.send(page('Cart', `<h2>Your cart</h2><ul class="menu">${rows || '<li>Empty</li>'}</ul>
    <p><b>Total: ${formatPrice(total)}</b></p>
    <h3>Delivery address</h3>
    <form method="post" action="/order" class="order">
      <input name="name" placeholder="Name" required>
      <input name="address" placeholder="Street, ZIP, City" required>
      <input name="phone" placeholder="Phone" required>
      <button>Order now</button>
    </form>`));
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Pizza Pronto shop running on http://localhost:${PORT}`));
