' 01/03/21 Test Standalone version - Load remote URL / Load local HTML

Sub Main()

	
	print " @@@@ Version 13 @@@ "

	m.msgPort = CreateObject("roMessagePort")
	userVariables = CreateObject("roAssociativeArray")
	bsp = CreateObject("roAssociativeArray")
	log = CreateObject("roSystemLog")
	
	b = CreateObject("roByteArray")
	'b.FromHexString("ffffffff")
	b.FromHexString("00000000")
	color_spec% = (255*256*256*256) + (b[1]*256*256) + (b[2]*256) + b[3]

	videoMode = CreateObject("roVideoMode")
	videoMode.SetBackgroundColor(color_spec%)
	videomode.Setmode("1920x1080x60p")
	videoMode.SetSyncDomain("sync")
	
	m.sTime = createObject("roSystemTime")
	gpioPort = CreateObject("roControlPort", "BrightSign")
	
	gpioPort.SetPort(m.msgPort)	

	m.PluginInitHTMLWidgetStatic = PluginInitHTMLWidgetStatic
	
	m.TargetURL = "file:///index.html"
	'm.TargetURL = "http://192.168.1.25:5500/index.html"

	
	StartInitHTMLWidgetTimer()

	'StartTestTimer()

	while true
	    
		msg = wait(0, m.msgPort)
		
		print "type of msgPort is ";type(msg)
	
		if type(msg) = "roTimerEvent" then	
	
			timerIdentity = msg.GetSourceIdentity()
			
			print "Timer msgPort Received " + stri(timerIdentity)
			
			'timerIdentity = msgPort.GetSourceIdentity()
				
			if type (m.InitHTMLWidgetTimer) = "roTimer" then 
			
				if m.InitHTMLWidgetTimer.GetIdentity() = msg.GetSourceIdentity() then	
				
					m.PluginInitHTMLWidgetStatic()

				end if
				
			end if		
			
			if type (m.TestTimer) = "roTimer" then 
			
				if m.TestTimer.GetIdentity() = msg.GetSourceIdentity() then	
				
					'TEST Timer
				
					currentUsage = ""
					currentUsage = GetDecoderInfo(videomode)

					print " @@@ Current Video Decoder Usage @@@ " currentUsage
					print ""
					log.sendline(" @@@ Current Video Decoder Usage @@@ " + currentUsage)

					'StartTestTimer()

					'stop

				end if
				
			end if			
			
		else if type(msg) = "roHtmlWidgetEvent" then
	
			eventData = msg.GetData()

			if type(eventData) = "roAssociativeArray" and type(eventData.reason) = "roString" then
			
				Print "roHtmlWidgetEvent = " + eventData.reason

			endif	

		else if type(msg) = "roControlDown" then
		
			button = msg.GetInt()
				
			if button = 12 then 
				print " @@@ GPIO 12 pressed @@@  "
				stop
			end if			
		
		end if				
		
	end while


End Sub


Function StartInitHTMLWidgetTimer()
	
	print " Set Timer..."
	
	newTimeout = m.sTime.GetLocalDateTime()
	newTimeout.AddSeconds(1)
	m.InitHTMLWidgetTimer = CreateObject("roTimer")
	m.InitHTMLWidgetTimer.SetPort(m.msgPort)
	m.InitHTMLWidgetTimer.SetDateTime(newTimeout)
	ok = m.InitHTMLWidgetTimer.Start()

End Function


Function StartTestTimer()
	
	print " Set Test Timer..."
	
	newTimeout = m.sTime.GetLocalDateTime()
	newTimeout.AddSeconds(1)
	m.TestTimer = CreateObject("roTimer")
	m.TestTimer.SetPort(m.msgPort)
	m.TestTimer.SetDateTime(newTimeout)
	ok = m.TestTimer.Start()

End Function



Function PluginInitHTMLWidgetStatic()

	'needed for node objects
    ' rs = createobject("roregistrysection", "html")
    ' mp = rs.read("mp")
    ' if mp <> "1" then
    '     rs.write("mp","1")
    '     rs.flush()
    '     RebootSystem()	'reboots player first time it's changed
    ' end if	

	'done in HTML code with the node style syncManager object
	ptpReg = createobject("roregistrysection", "networking")
    ptp_domain = ptpReg.read("ptp_domain")
    if ptp_domain <> "0" then
        ptpReg.write("ptp_domain","0")
        ptpReg.flush()
        RebootSystem()	'reboots player first time it's changed
    end if	


	m.PluginRect = CreateObject("roRectangle", 0,0,1920,1080)
	
	
	is = {
		port: 2999
	}
	m.config = {
		nodejs_enabled: true
		security_params: {
					websecurity: false
		},
	
		javascript_injection: { 
		   document_creation: [], 
			'document_ready: [{source: filepath$ }],
			document_ready: [], 
			'deferred: [{source: filepath$ }]
			deferred: []
		},
		javascript_enabled: true,
		port: m.msgPort,
		inspector_server: is,
		brightsign_js_objects_enabled: true,
		url: m.TargetURL,
		mouse_enabled: true,
		storage_quota: "2000000000",
		storage_path: "/local/",
		security_params: {websecurity: false} 
	}
	
	
	m.PluginHTMLWidget = CreateObject("roHtmlWidget", m.PluginRect, m.config)
	m.PluginHTMLWidget.Show()


End Function



Function GetDecoderInfo(videomode)As String

	videomodeInfo = invalid
	usageString = ""
	usageCountCounter = 0
	maxUsageCounter = 0
		
	videomodeInfo = videomode.GetDecoderModes()
	
	for each decoder in videomodeInfo

		'print decoder["usage_count"]
		
		if decoder["usage_count"] then
			usageCountCounter = usageCountCounter + decoder["usage_count"]
		end if	

		if decoder["max_usage"] then
			maxUsageCounter = maxUsageCounter + decoder["max_usage"]
		end if	

	next
	
	usageCount$ = usageCountCounter.ToStr()
	maxUsage$ = maxUsageCounter.ToStr()

	usageString = usageCount$ + " out of " + maxUsage$

	print " @@@ videomodeInfo[0] @@@ "
	print videomodeInfo[0]
	print ""
	print " @@@ videomodeInfo[1] @@@ "
	print videomodeInfo[1]
	print ""


	return usageString

End Function












