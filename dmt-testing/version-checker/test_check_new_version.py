from packaging.version import parse
from check_new_versions import create_image_tag


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


def test_building_image_tag():
    major = "1.5.3"
    minors = ["python3.6.6", "alpine3.8"]

    assert create_image_tag(major=major, minors=minors) == "1.5.3-python3.6.6-alpine3.8"
