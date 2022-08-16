import pytest

from base_test_api.app import app


@pytest.fixture
def client():
    test_client = app.test_client()
    yield test_client


def test_ping(client):
    rv = client.get('/api/ping')
    assert b'pong' in rv.data
