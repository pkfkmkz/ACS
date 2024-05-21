import ict21770__POA
from ict21770i.MiddleCCImpl import MiddleCCImpl
from Acspy.Util.BaciHelper import addProperty

class FinalCCImpl(ict21770__POA.FinalCC, MiddleCCImpl):
    def __init__(self):
        MiddleCCImpl.__init__(self)

    def initialize(self):
        MiddleCCImpl.initialize(self)
        addProperty(self, "prop3")

    def printValue3(self):
        print(self._get_prop3().get_sync()[0])

    def printValues(self):
        self.printValue1()
        self.printValue2()
        self.printValue3()
