# coding: utf-8
from Acspy.Clients.SimpleClient import PySimpleClient
client = PySimpleClient.getInstance()
client.availableComponents()
openddsDB = client.getComponent('BulkDataNTOpenDDSSenderTEST')
openddsDB.startSend()
