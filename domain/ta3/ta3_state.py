from dataclasses import dataclass
from domain.internal import State


@dataclass
class Supply:
    type: str
    quantity: int


@dataclass
class Demographics:
    age: int
    sex: str
    rank: str


@dataclass
class Vitals:
    conscious: bool
    mental_status: str
    breathing: str
    hrpmin: int


@dataclass
class Injury:
    location: str
    name: str
    severity: float


Locations = {"right forearm", "left forearm", "right calf", "left calf", "right thigh", "left thigh", "right stomach",
             "left stomach", "right bicep", "left bicep", "right shoulder", "left shoulder", "right side", "left side",
             "right chest", "left chest", "right wrist", "left wrist", "left face", "right face", "left neck",
             "right neck", "unspecified"}
Injuries = {"Forehead Scrape", "Ear Bleed", "Asthmatic", "Laceration", "Puncture", "Shrapnel", "Chest Collapse", "Amputation", "Burn"}
TagCategory = {"MINIMAL", "DELAYED", "IMMEDIATE", "EXPECTANT"}


# Casualty
@dataclass
class Casualty:
    id: str
    name: str
    injuries: list[Injury]
    demographics: Demographics
    vitals: Vitals
    tag: str
    assessed: bool = False
    unstructured: str = ''
    relationship: str = ''

    @staticmethod
    def from_ta3(data: dict):
        return Casualty(
            id=data['id'],
            name=data['name'],
            injuries=[Injury(**i) for i in data['injuries']],
            demographics=Demographics(**data['demographics']),
            vitals=Vitals(**data['vitals']),
            tag=data['tag'],
            assessed=data.get('assessed', None),
            unstructured=data['unstructured'],
            relationship=data['relationship']
        )


@dataclass
class Supply:
    type: str
    quantity: int


class TA3State(State):
    def __init__(self, unstructured: str, time_: int, casualties: list[Casualty], supplies: list[Supply]):
        super().__init__(id_='TA3State', time_=time_)
        self.unstructured: str = unstructured
        self.casualties: list[Casualty] = casualties
        self.supplies: list[Supply] = supplies

    @staticmethod
    def from_dict(data: dict) -> 'TA3State':
        unstr = data['unstructured'] if 'unstructured' in data else ''
        stime = data['time'] if 'time' in data else 0
        cdatas = data['casualties'] if 'casualties' in data else []
        sdatas = data['supplies'] if 'supplies' in data else []

        casualties = [Casualty.from_ta3(c) for c in cdatas]
        supplies = [Supply(**s) for s in sdatas]
        return TA3State(unstr, stime, casualties, supplies)
