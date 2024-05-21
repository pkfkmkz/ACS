s/Cache saved to '[a-z,A-Z,0-9,.,_,\/,-]*/Cache saved to '----'/g
s/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][ T][0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9]\{1,3\}/----------T--:--:--.---/g
s/Counter is: [0-9]*/Counter is: XXX/g
s/[0-9]* bytes/XXX bytes/g
s/Rate: [0-9,.]*MBytes\/sec/Rate: XXXMBytes\/sec/g
s/ Bytes in [0-9,.]*secs./ Bytes in XXXXsecs./g
s/ Function took [0-9,.]*/ Function took XYZ.ASD/g
s/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:[0-9]*/xxx.xxx.xxx.xxx:XYZZ/g
s/Manager hostname obtained via command line: '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+'/Manager hostname obtained via command line: 'xxx.xxx.xxx.xxx'/g
s/Manager hostname generated using localhost address: '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+'/Manager hostname generated using localhost address: 'xxx.xxx.xxx.xxx'/g
s/([0-9]\+|[0-9]\+) EXCEPTION/(XXX|XXX) EXCEPTION/g
s/([0-9]\+|[0-9]\+) WARNING/(XXX|XXX) WARNING/g
s/TimeMillis="[0-9]\+"/TimeMillis="xxx"/g
s/\/[a-z,A-Z,0-9,.,/,_,-]*\/lib\/\(lib[a-z,A-Z,0-9,.,_]*\.so\)/\/----\/\1/g
s/component with handle [0-9]\+/component with handle XXX/g
s/unacknowledged_sample_count ([0-9]) before waiting: [0-9]/unacknowledged_sample_count (X) before waiting: Y/g
s/ActualProcessTime="[0-9]*\.[0-9]*"/ActualProcessTime="X.YZ"/g
s/Transfer rate: [0-9,.]*/Transfer rate: XY.Z/g
s/New transfer rate: [0-9,.]*/New transfer rate: XY.Z/g
s/Receiver Data Rate: [0-9,.]*/Receiver Data Rate: XY.Z/g
s/in [0-9,.]* sec/in xy.z sec/g
s/before waiting: [0-9]*/before waiting: XY/g
s/Sub([0-9]*)/Sub(XXX)/g
s/\/[a-z,A-Z,0-9,.,/,_,-]*\/config\/bulkDataNTDefaultQosProfiles.default.xml/----\/config\/bulkDataNTDefaultQosProfiles.default.xml/g
s/cbReceive(): [0-9,.]*s. What corresponds to throughput of: [0-9,.]*MB\/sec/cbReceive(): X.Ys. What corresponds to throughput of: Z.XXXMB\/sec/g
s/sample rcv: [0-9]* ([0-9]*) HB: [0-9]* ([0-9]*) ACKs: [0-9]* ([0-9]*) NACKs: [0-9]* ([0-9]*) Rejected: 0/sample rcv: XX (YYYYY) HB: XX (YYYYY) ACKs: XX (YYYYY) NACKs: X (YY) Rejected: 0 /g
s/HB: [0-9]* ([0-9]*) ACKs: [0-9]* ([0-9]*) NACKs: [0-9]* ([0-9]*)/HB: XX (YY) ACKs: XX (YY) NACKs: XX (YY)/g
s/AvgProcessTimeoutSec="[0-9,.]*"/AvgProcessTimeoutSec="X.YZ"/g
s/Throughput="[0-9,.]*"/Throughput="X.YZ"/g
s/waiting for ACKs: [0-9]*/waiting for ACKs: XY/g
s/Found ACS_INSTANCE [0-9]/Found ACS_INSTANCE X/g
s/using it as DDS domainID : [0-9]/using it as DDS domainID : X/g
s/TEST DataWriter protocol status for flow: \([^ ]\+\) [# samples: [0-9]\+ (bytes [0-9]\+); # HBs count: [0-9]\+ (bytes [0-9]\+) # ACKs: [0-9]\+ (bytes [0-9]\+) # NACK counts: [0-9]\+ (bytes [0-9]\+) # rejected: [0-9]\+]/TEST DataWriter protocol status for flow: \1 [# samples: XX (bytes XX); # HBs count: XX (bytes XX) # ACKs: XX (bytes XX) # NACK counts: XX (bytes XX) # rejected: XX]/
s/execution elapsed time [0-9]\+.[0-9]\+ sec/execution elapsed time X.XXXXXX sec/
s/DataWriter cache Status: sample count in queue: [0-9]\+ (highest peak since lifetime [0-9]\+)/DataWriter cache Status: sample count in queue: XX (highest peak since lifetime XX)/
s/TestStream#[0-9][0-9]/TestStream#XX/g
s/[Cc]ache Status: sample count (peak): [0-9]\+ ([0-9]\+)/Cache Status: sample count (peak): X (XX)/g
s/Average transfer rate for all the flow(s): [0-9]*\.[0-9]*/Average transfer rate for all the flow\(s\): X.XXXXX/g
s/[Tt]ransfer rate for flow '[0-9]\+': [0-9]*\.[0-9]*/transfer rate for flow 'XX': XX.XXXXX/g
s/[Tt]ransfer rate for flow '\(\w\+\)': [0-9]*\.[0-9]*/transfer rate for flow '\1': XX.XXXXX/g
s/duration: [0-9]\+ usecs/duration: XXX usecs/g
s/duration  [0-9]\+ usecs/duration XXX usecs/g
s/DataWriter protocol status for flow: [0-9]\+ [# samples: [0-9]\+ (bytes [0-9]\+); # HBs count: [0-9]\+ (bytes [0-9]\+) # ACKs: [0-9]\+ (bytes [0-9]\+) # NACK counts: [0-9]\+ (bytes [0-9]\+) # rejected: [0-9]\+]/DataWriter protocol status for flow: XX [# samples: XX (bytes XXXXXXX); # HBs count: XX (bytes XXXX) # ACKs: XXX (bytes XXX) # NACK counts: XXX (bytes XXX) # rejected: XXX]/g
s/Using ".*" as fully qualified/Using "FicticiousHostName" as fully qualified/g
s/[BulkDataNT:(\w\+#\w\+) - on_liveliness_changed] A new sender has connected to flow: (\w\+) of the stream: (\w\+)\. Total alive connections(s): (\d\+) /A new sender has connected to flow: CHANNELNAME of the stream: STREAMNAME. Total alive connection(s): X/g
s/[BulkDataNT:(\w\+#\w\+) - on_liveliness_changed] A sender has disconnected to flow: (\w\+) of the stream: (\w\+)\. Total alive connections(s): (\d\+) /A new sender has connected to flow: CHANNELNAME of the stream: STREAMNAME. Total alive connection(s): X/g
s/Already created DDS topic: (\w\+#\w\+) will be taken/Already created DDS topic: TOPICNAME will be taken/g
s/Created DDS topic: (\w\+#\w\+)/Created DDS topic: TOPICNAME/g
