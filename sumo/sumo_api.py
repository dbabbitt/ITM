import requests
from requests import Response


class SumoAPI:
    def __init__(self, url: str = "http://localhost:8080/sigmarest/resources"):
        self.url: str = url

    def init(self) -> bool:
        try:
            self._get('init')
        except:
            return False
        return True

    def tell(self, statement: str) -> bool:
        try:
            self._get('tell', {'statement': statement})
        except:
            return False
        return True

    def tell_all(self, statements: list[str]) -> bool:
        success = True
        for statement in statements:
            success &= self.tell(statement)
        return success

    def ask(self, query: str) -> dict[str, str]:
        resp = self._get('ask', {'query': query, 'timeout': 300})
        return resp.json()

    def _get(self, endpoint: str, params: dict | None = None) -> Response:
        if params != ():
            return requests.get(f"{self.url}/{endpoint}", params=params)
        return requests.get(f"{self.url}/{endpoint}")

    def _post(self, endpoint: str, payload: dict | list) -> Response:
        headers = {"Content-Type": "application/json"}
        return requests.post(f"{self.url}/{endpoint}", json=payload, headers=headers)