# Testing Patterns

Concrete patterns for writing tests in this repo. Skip to the section you need; don't try to read this end-to-end.

## File layout

```
src/di2vibe/api/health.py       →  tests/api/test_health.py
src/di2vibe/models/order.py     →  tests/models/test_order.py
src/di2vibe/services/billing.py →  tests/services/test_billing.py
```

Sub-packages get their own `tests/<sub>/` directory. An `__init__.py` in each test dir.

## Naming

```python
def test_<unit>_<condition>_<expected>():
    ...

# Examples:
def test_get_order_returns_404_when_id_missing():
def test_validate_email_rejects_empty_string():
def test_calculate_total_sums_line_items_excluding_tax():
```

Avoid generic names (`test_order`, `test_happy_path`). A failing test name should tell you what broke without opening the file.

## Structure: Arrange / Act / Assert

```python
def test_create_order_persists_to_db(session, client):
    # Arrange
    payload = {"customer_id": "c1", "items": [{"sku": "A", "qty": 2}]}

    # Act
    response = client.post("/orders", json=payload)

    # Assert
    assert response.status_code == 201
    assert session.query(Order).count() == 1
```

Blank lines separate the three phases. Don't collapse them "to save space."

## FastAPI route testing

```python
import pytest
from httpx import AsyncClient
from di2vibe.main import create_app

@pytest.fixture
async def client():
    app = create_app()
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

async def test_health_returns_ok(client):
    response = await client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
```

- Use `create_app()` factory, not the module-level `app`. Isolates tests.
- `httpx.AsyncClient` over starlette `TestClient` — consistent with production async behavior.

## Overriding dependencies

```python
from di2vibe.deps import get_db

@pytest.fixture
def client_with_fake_db(fake_db):
    app = create_app()
    app.dependency_overrides[get_db] = lambda: fake_db
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()
```

Always clear overrides in teardown. Otherwise fixtures leak across tests.

## Pydantic model testing

```python
import pytest
from pydantic import ValidationError
from di2vibe.models.order import Order

def test_order_rejects_empty_items_list():
    with pytest.raises(ValidationError) as exc:
        Order(customer_id="c1", items=[])
    assert "items" in str(exc.value)
```

Test each validator's failure case, not every happy-path combinatoric.

## Parametrize for boundary conditions

```python
@pytest.mark.parametrize(
    "qty,expected_valid",
    [
        (1, True),
        (0, False),
        (-1, False),
        (10_000, True),
        (10_001, False),
    ],
)
def test_quantity_validation(qty, expected_valid):
    ...
```

Parametrize when you're testing the same behavior across many inputs. Don't parametrize unrelated tests "to reduce repetition" — that hurts readability.

## Fixtures

- Scope `function` by default. Only widen (`session`, `module`) when measured start-up cost justifies it.
- Prefer fixtures over `setUp` methods. Pytest class-based tests are discouraged here.
- Name fixtures as nouns describing what they provide: `db_session`, `fake_stripe_client`, `authed_user`.

## Anti-patterns (reject in review)

| Anti-pattern | Why |
|---|---|
| `assert result is not None` as the only assertion | Doesn't verify behavior |
| Mocking the function under test | Test validates nothing |
| One test covering many unrelated cases | Failure message is useless |
| `time.sleep()` in a test | Flaky. Use clocks/fakes instead. |
| Testing private functions (`_helper`) directly | Couples test to implementation |
| `@pytest.mark.skip("todo")` without linked issue | Dead test |
| `try/except` inside a test swallowing the exception | Hides real failures |

## Coverage

Target: ≥ 85% line coverage on `src/`. But coverage is a floor, not a ceiling:
- 100% coverage with no assertions = broken
- 80% with every behavior tested = fine

Never add a test **just** to lift coverage on a line you don't understand.
