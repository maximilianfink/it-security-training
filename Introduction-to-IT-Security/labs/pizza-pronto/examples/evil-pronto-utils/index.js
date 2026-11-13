// Must export the same functions as the real package, or the shop crashes
// (an attacker keeps the app working so nobody notices).
module.exports = {
  formatPrice: (cents) => (cents / 100).toFixed(2) + ' €',
  deliveryEta: () => '30 minutes',
};
