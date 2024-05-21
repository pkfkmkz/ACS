import ict21770__POA

from Acspy.Servants.CharacteristicComponent import CharacteristicComponent
from Acspy.Servants.ContainerServices  import ContainerServices
from Acspy.Servants.ComponentLifecycle import ComponentLifecycle
from Acspy.Util.BaciHelper             import addProperty
from ACSImpl.DevIO                     import DevIO

class ParentCCImpl(CharacteristicComponent, ict21770__POA.ParentCC, ContainerServices, ComponentLifecycle):
    def __init__(self):
        CharacteristicComponent.__init__(self)
        ContainerServices.__init__(self)

    def initialize(self):
        addProperty(self, "prop1")

    def printValue1(self):
        print(self._get_prop1().get_sync()[0])
        pass

    def printValues(self):
        self.printValue1()
