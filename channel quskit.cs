# -*- coding: utf-8 -*-

# Copyright 2019, IBM.
#
# This source code is licensed under the Apache License, Version 2.0 found in
# the LICENSE.txt file in the root directory of this source tree.

"""
Channels support signal output.
"""
from abc import ABCMeta

from .channels import Channel


class PulseChannel(Channel, metaclass=ABCMeta):
    """Base class of Channel supporting pulse output."""
    pass


[docs]class DriveChannel(PulseChannel):
    """Drive Channel."""

    prefix = 'd'



[docs]class MeasureChannel(PulseChannel):
    """Measure Channel."""

    prefix = 'm'



[docs]class ControlChannel(PulseChannel):
    """Control Channel."""

    prefix = 'u'



