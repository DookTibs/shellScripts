#!/bin/bash
cd /Users/tfeiler/development/tools/eclipse.jdt.ls

LSP_CONFIG="config_mac"
# LSP_DATA_ROOT="/Users/tfeiler/development/icf_dragon/"
LSP_DATA_ROOT="/Users/tfeiler/development/tools/eclipse-workspace"

cd org.eclipse.jdt.ls.product/target/repository
# find the right jar to use
LAUNCHER_JAR=`find . -name "org.eclipse.equinox.launcher_*.jar" | head -n 1`

# echo "LAUNCH [${LAUNCHER_JAR}], cfg=[${LSP_CONFIG}]"

java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=1044 -Declipse.application=org.eclipse.jdt.ls.core.id1 -Dosgi.bundles.defaultStartLevel=4 -Declipse.product=org.eclipse.jdt.ls.core.product -Dlog.level=ALL -noverify -Xmx1G -jar ${LAUNCHER_JAR} -configuration ./${LSP_CONFIG} -data ${LSP_DATA_ROOT} --add-modules=ALL-SYSTEM --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED
