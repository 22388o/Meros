# pyright: strict

#Types.
from typing import Dict, List, Any

#Socket lib.
import socket

#JSON lib.
import json

#RPC class.
class RPC:
    #Constructor.
    def __init__(
        self,
        port: int = 5133
    ) -> None:
        self.socket: socket.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.connect(("127.0.0.1", port))

    #Call an RPC method.
    def call(
        self,
        module: str,
        method: str,
        args: List[Any] = []
    ) -> Dict[str, Any]:
        #Send the call.
        self.socket.send(
            bytes(
                json.dumps(
                    {
                        "module": module,
                        "method": method,
                        "args": args
                    }
                ) + "\r\n",
                "utf-8"
            )
        )

        #Get the result.
        response: bytes = self.socket.recv(2)
        while response[-2:] != bytes("\r\n","utf-8"):
            response += self.socket.recv(1)

        #Raise an exception on error.
        result: Dict[str, Any] = json.loads(response)
        if "error" in result:
            raise Exception(result["error"])
        return result