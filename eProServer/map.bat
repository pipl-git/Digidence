d:

cd D:\Digidence\eProServer
rmdir libs
mklink /d libs D:\ThirdPartyLibs

cd D:\Tomcat8\lib
rmdir others
mklink /d others D:\ThirdPartyLibs

cd D:\Digidence\eProServer\Tomcat\WEB-INF
rmdir classes

cd D:\Tomcat8\webapps
rmdir eProServer
mklink /d eProServer D:\Digidence\eProServer\Tomcat

@Pause
