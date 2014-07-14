
java="java -mx1024m -classpath"
classpath=`find ../lib -name "*.jar" -print | tr "\n" ":"`
arg="NewSeis.jar cn.org.gddsn.seis.analysis.SeisApp"
echo "${java} ${classpath}${arg}" >msdp.sh
chmod +x msdp.sh
 
java="java -mx1024m -classpath"
classpath=`find ../lib -name "*.jar" -print | tr "\n" ";"`
echo "@echo off" >msdp.bat
echo "${java} ${classpath}${arg}" >>msdp.bat

