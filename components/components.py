from domain.internal import Scenario, Probe, Decision, KDMAs, DecisionMetrics


class DecisionAnalyzer:
    def analyze(self, scen: Scenario, probe: Probe) -> dict[str, DecisionMetrics]:
        """ Adds the decision metrics directly to the probe decisions, and returns them as a map (see baseline) """
        raise NotImplementedError

    def train(self, team_id: str, scen: Scenario, probe: Probe):
        """ Trains on TA1 data, if necessary """
        pass


class DecisionSelector:
    def select(self, scenario: Scenario, probe: Probe, target: KDMAs) -> (Decision, float):
        raise NotImplementedError


class Elaborator:
    def elaborate(self, scenario: Scenario, probe: Probe) -> list[Decision]:
        raise NotImplementedError


class CaseGenerator:
    def __init__(self, elaborator: Elaborator, selector: DecisionSelector, analyzers: list[DecisionAnalyzer]):
        self.selector: DecisionSelector = selector
        self.elaborator: Elaborator = elaborator
        self.analyzers: list[DecisionAnalyzer] = list(analyzers)

    def train(self, team_id: str, scenario: Scenario, probe: Probe):
        raise NotImplementedError
