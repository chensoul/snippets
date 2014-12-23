#!/usr/bin/python

import smtplib

sender = 'lashou_bi1@lashou-inc.com'
receivers = ['chenzhijun@lashou-inc.com']

mail_host="211.151.144.200"
mail_user="lashou_bi1"
mail_pass="lsbi!@#$"

message = """From: From Person <lashou_bi1@lashou-inc.com>
To: To Person <chenzhijun@lashou-inc.com>
Subject: SMTP e-mail test

This is a test e-mail message.
"""

try:
		s=smtplib.SMTP()
		s.connect(mail_host)
		s.login(mail_user, mail_pass)
		s.sendmail(sender, receivers, message)
		s.close()
		print "Successfully sent email"
except Exception, e:
		print str(e)
		print "Error: unable to send email"
