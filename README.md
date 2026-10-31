# Bazaar

A small e-commerce app built with Flutter. Customers can browse a product
catalog, search and filter it, add items to a cart, sign in, check out with a
delivery address and pay using one of the available methods, then review their
order history.

## Features

| Feature | Description |
| --- | --- |
| Catalog | Product grid with thumbnail, rating, discount badge and quick add-to-cart |
| Search | Debounced search against the products API |
| Categories | Horizontal chips that filter the catalog |
| Product details | Large image, description, tags, stock state and a quantity stepper |
| Cart | Quantity editing, swipe to remove, live subtotal / tax / total, saved on the device |
| Authentication | Username + password sign in, token stored locally, session restored on launch |
| Checkout | Delivery address form with validation, payment method picker, order summary |
| Orders | Confirmation screen and a full order history list |
| Themes | Light and dark themes that follow the system setting |

## Tech stack

- **Flutter** 3.44 / **Dart** 3.12
- **provider** for state management (`ChangeNotifier`)
- **go_router** for navigation
- **dio** for HTTP, with a bearer-token interceptor and typed exceptions
- **shared_preferences** for the cart, orders and session
- **cached_network_image** for product images

## Architecture

The project is organised feature-first, and every feature follows the same
three layers:

```
presentation  →  provider  →  data (repository)  →  network / storage
                       ↑
                    models
```

- **models** are immutable (`final` fields + `copyWith`) and own their JSON
  serialisation, so parsing never leaks into the UI.
- **repositories** hide where the data comes from and translate transport
  errors into `ApiException` types with readable messages.
- **providers** hold screen state and are the only thing widgets listen to.
- **presentation** contains pages and the widgets they reuse.

```
lib/
├── main.dart
├── app.dart                       # repository wiring + MultiProvider
├── core/
│   ├── constants/                 # API endpoints, palette
│   ├── network/                   # Dio client + typed exceptions
│   ├── router/                    # GoRouter route table
│   ├── storage/                   # SharedPreferences wrapper
│   ├── theme/                     # light & dark ThemeData
│   ├── utils/                     # money / date / label formatting
│   └── widgets/                   # cached image, empty state
└── features/
    ├── product/
    │   ├── models/product.dart
    │   ├── data/product_repository.dart
    │   ├── provider/product_provider.dart
    │   └── presentation/…
    ├── cart/
    ├── auth/
    └── order/
```

## Getting started

```bash
flutter pub get
flutter run
```

The catalog and the sign in request use the public
[DummyJSON](https://dummyjson.com) API, so no API key or local server is
needed.

### Demo credentials

| Username | Password |
| --- | --- |
| `emilys` | `emilyspass` |
| `michaelw` | `michaelwpass` |

The sign in screen offers both accounts as one-tap fill buttons.

## Tests

```bash
flutter test
```

The unit tests cover the product model (parsing, pricing, equality), the cart
(merging, quantity updates, totals) and orders (placement, JSON round trip,
filtering by user).

## Notes

- Card and wallet payments are simulated: the chosen method is recorded on the
  order, but no real payment gateway is contacted.
- Taxes are calculated at a flat 8% for demonstration purposes.
- The cart and the order history are stored on the device, so both survive an
  app restart.
