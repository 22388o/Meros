#TestError Exception.
from python_tests.Tests.TestError import TestError

#RPC class.
from python_tests.Meros.RPC import RPC

def VerifyCompetingLiveTest(
    rpc: RPC
) -> None:
    raise TestError("Test is empty.")
