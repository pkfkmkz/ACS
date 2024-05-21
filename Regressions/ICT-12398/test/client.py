from Acspy.Clients.SimpleClient import PySimpleClient

c = PySimpleClient()
cl = c.getComponent("CALL")
cl.interact()
time.sleep(5)
c.releaseComponent("CALL")
