import typing
from .decision_metric import DecisionMetrics
from .justification import Justification
from .kdmas import KDMAs

T = typing.TypeVar('T')


class Action:
    def __init__(self, name_: str, params: dict[str, typing.Any]):
        self.name: str = name_
        self.params: dict[str, typing.Any] = params

    def __str__(self):
        return f"{self.name}({','.join(self.params.values())})"


class Decision(typing.Generic[T]):
    def __init__(self, id_: str, value: T,
                 justifications: list[Justification] = (),
                 metrics: DecisionMetrics = None,
                 kdmas: KDMAs = None):
        self.id_: str = id_
        self.value: T = value
        self.justifications: list[Justification] = justifications
        self.metrics: DecisionMetrics = metrics if metrics is not None else {}
        self.kdmas: KDMAs | None = kdmas

    def __repr__(self):
        return f"{self.id_}: {self.value} - {self.kdmas} - {[(dm.name, dm.value) for dm in self.metrics.values()]}"
