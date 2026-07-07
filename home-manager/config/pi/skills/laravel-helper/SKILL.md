---
name: laravel-helper
description: Assist with Laravel >=10.x development targeting PHP >=8.1. Covers coding conventions, project structure, Eloquent, Artisan commands, testing, and modern PHP features. Use when writing, reviewing, or refactoring Laravel code.
---

# Laravel Helper Skill

This skill provides guidance for developing Laravel 10.x+ applications with PHP 8.1+.
Follow these conventions for all Laravel code-new features, refactors, reviews, and bug fixes.

## PHP 8.1+ Modern Features

Prefer these language features over older equivalents:

- **Enums** - Never use string constants or database-backed status tables for fixed sets.
  ```php
  enum OrderStatus: string
  {
      case Pending = 'pending';
      case Shipped = 'shipped';
      case Delivered = 'delivered';

      public function label(): string
      {
          return match ($this) {
              self::Pending => 'Pending',
              self::Shipped => 'Shipped',
              self::Delivered => 'Delivered',
          };
      }
  }
  ```
- **Readonly properties** - For DTOs, value objects, and data classes.
  ```php
  class CreateOrderDTO
  {
      public function __construct(
          public readonly int $userId,
          public readonly array $items,
          public readonly ?string $couponCode = null,
      ) {}
  }
  ```
- **Match expressions** - Replace long `switch` chains. `match` is exhaustive.
- **Named arguments** - Use when calling methods with many optional/default params.
- **First-class callable syntax** - `$this->method(...)` instead of `[$this, 'method']`.
- **Array unpacking with string keys** - `[...$array1, ...$array2]`.
- **`str_contains`, `str_starts_with`, `str_ends_with`** - Replace manual `strpos` checks.

## Coding Style & Formatting

- Use **Laravel Pint** for code formatting with the `laravel` preset.
  ```bash
  ./vendor/bin/pint
  ```
- Run Pint before committing. Configure IDE format-on-save.
- For inspections and static analysis, use **Larastan** (level 5+):
  ```bash
  ./vendor/bin/phpstan analyse
  ```
- Follow **PSR-12** and **Laravel's own conventions**:
  - Class names: `PascalCase`
  - Methods/functions: `camelCase`
  - Properties: `camelCase`
  - Constants and enums: `PascalCase`
  - Table columns: `snake_case`
  - View files: `kebab-case.blade.php`
  - Translation keys: `snake_case`
  - Config keys: `snake_case`
  - Named routes: `kebab-case` with dots for grouping: `admin.users.edit`
  - One class per file. No closing `?>` tag.

## Project Structure

```
app/
├── Actions/              # Single-action classes for business logic
├── Console/Commands/     # Artisan commands
├── Data/                 # DTOs, value objects
├── Enums/                # PHP enums (>= 8.1)
├── Exceptions/           # Custom exceptions
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   ├── Requests/         # Form requests (authorize + rules + messages)
│   ├── Resources/        # API resources
├── Jobs/
├── Listeners/
├── Models/
│   ├── Builders/         # Custom Eloquent query builders
│   ├── Casts/            # Attribute casting classes
│   ├── Collections/      # Custom Eloquent collections
│   ├── Scopes/           # Reusable query scopes
├── Notifications/
├── Observers/
├── Policies/
├── Providers/
└── Rules/                # Custom validation rules
```

### Namespacing Rules
- **Controllers** - Keep thin. Delegate to Actions, Jobs, or Services. Never place business logic here.
- **Models** - Should contain relationships, accessors/mutators, casts, and scopes only. No HTTP-level logic.
- **Actions** - One public `execute()` method. Stateless. Named as a verb: `CancelOrder`, `RegisterUser`.
- **Form Requests** - Always use them for validation. Never validate in controllers.
- **Services** - Stateful classes coordinating multiple steps (e.g., `CheckoutService`). Prefer Actions for simpler tasks.

## Eloquent Conventions

- Table names auto-resolve: `User` → `users`, `OrderItem` → `order_items`. Follow this implicitly.
- Explicitly declare `$fillable` OR `$guarded` - never leave both empty.
- Prefer `$fillable` over `$guarded` for clarity.
- Cast attributes explicitly in `$casts`:
  ```php
  protected function casts(): array
  {
      return [
          'shipped_at' => 'datetime',
          'metadata' => AsArrayObject::class,
          'status' => OrderStatus::class, // backed enum
      ];
  }
  ```
- Use **relationship return types** (PHP 8.1+):
  ```php
  public function posts(): HasMany
  {
      return $this->hasMany(Post::class);
  }
  ```
- Prefer **custom Eloquent Builders** for complex query logic:
  ```php
  public function newEloquentBuilder($query): PostBuilder
  {
      return new PostBuilder($query);
  }
  ```
- Use **custom Collections** for model collection utilities.
- Leverage **global scopes** and/or named query scopes properly.
- Eager load relationships with `->with()` or `->load()`. Avoid N+1 queries. Use the `PreventLazyLoading` middleware in development.
- Use `Model::shouldBeStrict()` in development (`AppServiceProvider::boot()`).

## Controllers

- Keep controllers thin and focused on HTTP concerns:
  - Receiving the request
  - Delegating to an Action/Job/Service
  - Returning a response
- Prefer **invokable (single-action) controllers** for simple endpoints:
  ```php
  class ShowOrderController extends Controller
  {
      public function __invoke(Order $order): OrderResource
      {
          $this->authorize('view', $order);
          return OrderResource::make($order->load('items'));
      }
  }
  ```
- For resource controllers with 4+ standard methods, group related ones.
- Use **route model binding** with explicit binding in `RouteServiceProvider` for non-id keys.
- Return API Resources from API routes. Return views from web routes.
- Handle authorization via Policies + FormRequests (first line of controller/request).

## Routing

- Use `Route::apiResource()` for RESTful APIs.
- Name all routes with `.name()` or prefixes: `Route::name('admin.')->group(...)`.
- Group middleware, prefixes, and namespaces explicitly.
- Use `Route::controller()` sparingly. Prefer explicit method referencing.
- In `routes/api.php`, keep the default `api` prefix and `auth:sanctum` middleware.

## Validation

- Use **Form Requests** (`php artisan make:request StorePostRequest`):
  ```php
  class StoreOrderRequest extends FormRequest
  {
      public function authorize(): bool
      {
          return $this->user()->can('create', Order::class);
      }

      public function rules(): array
      {
          return [
              'items' => ['required', 'array', 'min:1'],
              'items.*.product_id' => ['required', Rule::exists('products', 'id')],
              'coupon_code' => ['nullable', 'string', 'max:30'],
          ];
      }
  }
  ```
- Use `Rule` enum-flavored helpers: `Rule::exists()`, `Rule::unique()`, `Rule::enum()`.
- Use `Prohibited` / `ProhibitedIf` rules for mutually exclusive fields.
- For complex conditional rules, extract to custom Rule objects.

## Testing

- Prefer **Pest** over PHPUnit for new projects. For existing PHPUnit codebases, stay consistent.
- Test the endpoint, not the implementation. Use HTTP feature tests predominantly:
  ```php
  it('can create an order', function () {
      $user = User::factory()->create();
      $product = Product::factory()->create(['price' => 1000]);

      $this->actingAs($user)
          ->postJson('/api/orders', [
              'items' => [['product_id' => $product->id, 'quantity' => 2]],
          ])
          ->assertCreated()
          ->assertJsonPath('data.total', 2000);
  });
  ```
- Use **Model Factories** with realistic states and sequences.
- When dealing with external APIs, use `Http::fake()`.
- Use `Event::fake()`, `Queue::fake()`, `Notification::fake()`, `Bus::fake()` as needed.
- Test validation failure cases exhaustively.
- Name tests with `it('can ...')` or `test('it can ...')` convention.

## Artisan Commands Cheat Sheet

| Task | Command |
|---|---|
| Create model + migration + factory + seeder + policy + form request + controller | `php artisan make:model Post -a` |
| Create form request | `php artisan make:request StorePostRequest` |
| Create action | `php artisan make:class Actions/CancelOrder` |
| Create enum | `php artisan make:enum Enums/OrderStatus` |
| Create rule | `php artisan make:rule ValidCoupon` |
| Create scope | `php artisan make:class Models/Scopes/ActiveScope` |
| Create observer | `php artisan make:observer PostObserver --model=Post` |
| Create policy | `php artisan make:policy PostPolicy --model=Post` |
| Create notification | `php artisan make:notification OrderShipped` |
| Create job | `php artisan make:job ProcessPayment` |
| Create resource | `php artisan make:resource OrderResource` |
| Create custom cast | `php artisan make:cast Json` |
| Create test | `php artisan make:test OrderTest` or `php artisan make:test OrderTest --pest` |
| Run all tests | `php artisan test` |
| Run a single test | `php artisan test --filter="can create an order"` |
| Run Pint | `./vendor/bin/pint` |
| Run Larastan | `./vendor/bin/phpstan analyse` |
| List all routes | `php artisan route:list` |
| Tinker REPL | `php artisan tinker` |
| Clear caches | `php artisan optimize:clear` |
| Rebuild caches | `php artisan optimize` |

## Migration Conventions

- Use `$table->foreignIdFor(User::class)->constrained()` over verbose `$table->foreignId('user_id')`.
- Add `->cascadeOnDelete()` or `->restrictOnDelete()` explicitly. Don't rely on DB defaults.
- For large tables, use batches in `down()` methods for reversibility.
- Never import `DB` facade in migrations. Use the `$table` builder.

## Service Provider Conventions

- Keep `AppServiceProvider` lean. Register custom bindings in dedicated providers.
- Use the `boot()` method for registering views, gates, and event listeners.
- Use the `register()` method only for container bindings.
- For deferred providers, implement `DeferrableProvider`.

## Queue & Jobs

- Jobs should implement `ShouldQueue` and `ShouldBeUnique` where applicable.
- Use `dispatch()` helper or `Bus::dispatch()`. Avoid `dispatchNow()`.
- Set `$timeout`, `$tries`, `backoff()` explicitly.
- Handle failures gracefully with `failed()` method or `JobFailed` event listener.
- Prefer dedicated `Job` classes over inline closures in `dispatch(fn () => ...)`.

## Error Handling

- For API routes, render exceptions via `app/Exceptions/Handler.php` responding with consistent JSON:
  ```php
  return response()->json([
      'message' => $e->getMessage(),
  ], $statusCode);
  ```
- Throw domain-specific exceptions (`OrderAlreadyCancelledException`) and map them in the handler.
- Use `report()` in the handler to only report to logs when needed (skip 404s, validation errors).

## Configuration & Environment

- Put all env calls in `config/*.php` files. Never call `env()` outside config files.
- Validate required env values in config with fallback + exception:
  ```php
  'api_key' => env('SERVICE_API_KEY') ?: throw new RuntimeException('SERVICE_API_KEY not set'),
  ```
- Publish config with `php artisan vendor:publish --tag=config` for third-party packages.

## Package Conventions

- Prefer well-known packages from the Laravel ecosystem:
  - Spatie (laravel-permission, laravel-data, laravel-query-builder, laravel-medialibrary)
  - Laravel (Horizon, Telescope, Sanctum, Passport, Cashier, Scout, Socialite)
  - Pest / PHPUnit for testing
  - barryvdh/laravel-debugbar (dev only)
  - barryvdh/laravel-ide-helper (dev only)
  - nunomaduro/larastan (dev only)
- Register dev packages only in `require-dev`.

## Security & Sanitization

- Use `strip_tags()` on user-generated content BEFORE storing (in FormRequest `passedValidation()`).
- Use Blade `{{ }}` (auto-escaped) for output. Never use `{!! !!}` with user input.
- Mass-assign via `$fillable` only. Never use `request()->all()` to create/update models.
- For rate limiting, use `RateLimiter` facade in RouteServiceProvider or middleware.
- Sign sensitive URLs with `URL::signedRoute()` and `URL::temporarySignedRoute()`.
