import ict21770__POA

from ict21770i.ParentCCImpl import ParentCCImpl
from Acspy.Util.BaciHelper import addProperty

class MiddleCCImpl(ict21770__POA.MiddleCC, ParentCCImpl):
    def __init__(self):
        ParentCCImpl.__init__(self)

    def initialize(self):
        ParentCCImpl.initialize(self)
        addProperty(self, "prop2")

    def printValue2(self):
        print(self._get_prop2().get_sync()[0])

    def printValues(self):
        self.printValue1()
        self.printValue2()
