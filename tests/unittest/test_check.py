"""
Check pytest configuration
"""

import pytest


@pytest.mark.parametrize("i", [2])
async def test_working_pytest(i: int):
    "Parametrization test"
    assert i == 2, "Parameter i must be 2"
