#!/usr/bin/env python3

import tomcatmanager as tm

tomcat = tm.TomcatManager()

#Connect to Tomcat Manager using the provided credentials
r = tomcat.connect(url="http://localhost:8080/manager", user="tomcat", password="tomcat")

r = tomcat.stop("/hello-world")

r = tomcat.undeploy("/hello-world")


# if r is None:
#     print("Failed to connect to Tomcat Manager.")
# else:
#     # Stop the application with the given context path
#     r = tomcat.stop("/hello-world")

    # if r is None:
    #     print("Failed to stop application.")
    # elif r.ok:
    #     print("Application stopped successfully.")
    # else:
    #     print("Failed to stop application. Reason: " + r.status_message)