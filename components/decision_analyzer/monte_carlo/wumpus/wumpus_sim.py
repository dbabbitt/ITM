from dataclasses import dataclass
from .wumpus_state import WumpusAction, WumpusState
from components.decision_analyzer.monte_carlo.mc_sim import MCSim, SimResult

from sumo import SumoAPI
import time
from util import logger


class WumpusSim(MCSim):
    def __init__(self):
        super().__init__()
        self.sumo = SumoAPI()
        self.sumo.init()
        self.dirty = True

    def exec(self, state: WumpusState, action: WumpusAction) -> list[SimResult]:
        """
        Given a State and an Action, return a list of Resulting states and their probabilities
        :param state: The state to simulate from
        :param action: The action to simulate
        :return: list[SimResult]
        """
        location = state.location
        facing = state.facing
        time = state.time
        score = state.score

        # These should be known by state?
        if self.dirty:
            self.sumo.tell('(player_at %s t%d)' % (location, time))
            self.sumo.tell('(player_facing %s t%d)' % (facing, time))
            logger.debug('inserting dirty state location %s facing %s time %d' % (location, facing, time))
            self.do_glitter_tells('g12')
            self.do_stench_tells('g02')
            pits = ['g20', 'g22', 'g33']
            self.do_breeze_tells(locations=pits)
            self.dirty = False

        self.sumo.tell(f'(time t{time} t{time +1 })')

        act = action.action
        self.sumo.tell('(action %s t%d)' % (act, time))

        return_list = []
        new_time = time + 1
        new_status = self.sumo.ask('(and (player_at ?X t%d) (player_facing ?Y t%d) (perceives ?Z t%d ) (perceives_stench ?S t%d) (perceives_breeze ?B t%d) (isdead ?D t%d) )' % (new_time, new_time, new_time, new_time, new_time, new_time))
        new_location = new_status['bindings']['?X']
        new_facing = new_status['bindings']['?Y']
        glitter_precept = new_status['bindings']['?Z']
        stench_precept = new_status['bindings']['?S']
        breeze_precept = new_status['bindings']['?B']
        death_precept = new_status['bindings']['?D']

        outcome = WumpusState(location=new_location, facing=new_facing, time=new_time, glitter=glitter_precept, stench=stench_precept)
        if death_precept == 'dead':
            score -= 100
        elif glitter_precept == 'glitter':
            score += 100
        else:
            score -= 1
        outcome.set_score(score)
        logger.debug('At Time %d: (loc=%s, orient=%s, glitter=%s, stench=%s, breeze=%s, dead=%s, lastact=%s, score=%d' % (new_time, new_location, new_facing,
                                                                                            glitter_precept, stench_precept,
                                                                                            breeze_precept, death_precept, action.action, score))
        sim_result = SimResult(action=action, outcome=outcome)
        return_list.append(sim_result)
        return return_list

    def actions(self, state: WumpusState) -> list[WumpusAction]:
        """
        Given a state, returns a list of possible actions that could be taken
        :param state: The state to find actions for
        :return: list[WumpusAction]
        """

        location = state.location
        # Do logic on location here? Pass Time information here?
        actions = [WumpusAction(action='walk'), WumpusAction(action='cw'), WumpusAction(action='ccw')]
        return actions

    def reset(self):
        self.sumo.reset()
        self.dirty = True

    def do_glitter_tells(self, location: str) -> None:
        for i in range(4):
            for j in range(4):
                square_name = 'g%d%d' % (i, j)
                if square_name == location:
                    self.sumo.tell('(attribute %s glitter)' % square_name)
                else:
                    self.sumo.tell('(not (attribute %s glitter))' % square_name)


    def do_stench_tells(self, location: str) -> None:
        # adjacents = sumo.ask_max('(adjacent %s ?X)' % location, max_answers=4)
        adjacents = []
        for direction in ['left', 'top', 'right', 'bot']:
            a = self.sumo.ask('(neighbor %s %s ?X)' % (location, direction))['bindings']['?X']
            adjacents.append(a)
        for i in range(4):
            for j in range(4):
                square_name = 'g%d%d' % (i, j)
                if square_name in adjacents:
                    self.sumo.tell('(attribute %s stench)' % square_name)
                else:
                    self.sumo.tell('(not (attribute %s stench))' % square_name)
                if square_name == location:
                    self.sumo.tell('(attribute %s wumpus)' % square_name)
                else:
                    self.sumo.tell('(not (attribute %s wumpus))' % square_name)

    def do_breeze_tells(self, locations: list[str]) -> None:
        adjacents = set()
        for pit in locations:
            for direction in ['left', 'top', 'right', 'bot']:
                a = self.sumo.ask('(neighbor %s %s ?X)' % (pit, direction))['bindings']['?X']
                adjacents.add(a)
        for i in range(4):
            for j in range(4):
                square_name = 'g%d%d' % (i, j)
                if square_name in adjacents:
                    self.sumo.tell('(attribute %s breeze)' % square_name)
                else:
                    self.sumo.tell('(not (attribute %s breeze))' % square_name)
                if square_name in locations:
                    self.sumo.tell('(attribute %s pit)' % square_name)
                else:
                    self.sumo.tell('(not (attribute %s pit))' % square_name)
