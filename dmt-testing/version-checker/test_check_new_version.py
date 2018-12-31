from packaging.version import parse


def compare_versions(old, new):
    assert parse(old) < parse(new)


def test_parse_compare_versions():
    compare_versions(old="3.6.6-alpine3.8",
                     new="3.6.6-alpine3.9")

    compare_versions(old="3.6.6-alpine3.8",
                     new="3.6.7-alpine3.8")

    compare_versions(old="1.5.3-python3.6.6-alpine3.8",
                     new="1.6.3-python3.6.6-alpine3.8")

    compare_versions(old="1.5.3-python3.6.6-alpine3.8",
                     new="1.5.3-python3.7.6-alpine3.8")
