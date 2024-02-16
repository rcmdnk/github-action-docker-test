from docker_test import hello


def test_hello():
    assert hello() == "Hello, World!"
