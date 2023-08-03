from domain import Probe
from domain.internal import Decision, Scenario
from components import Elaborator


class BaselineElaborator(Elaborator):
    def elaborate(self, scenario: Scenario, probe: Probe) -> list[Decision]:
        decisions = [d for d in probe.decisions]
        return decisions