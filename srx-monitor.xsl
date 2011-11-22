<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:junos="http://xml.juniper.net/junos/*/junos"
    xmlns:xnm="http://xml.juniper.net/xnm/1.1/xnm" xmlns:ext="http://xmlsoft.org/XSLT/namespace"
    xmlns:jcs="http://xml.juniper.net/junos/commit-scripts/1.0">
    <xsl:import href="../import/junos.xsl"/>
    
    <xsl:variable name="connection" select="jcs:open()"/>
    
    <xsl:template name="session-summary">
        <output>
            <xsl:value-of select="jcs:printf('%24s\n', 'Detailed Session Summary per SPU')"/>
            <xsl:value-of select="jcs:printf('%4s %8s %8s %8s %8s %8s %8s %8s %8s %8s\n', 'SPU',
                'Unicast', 'Multicst', 'Failed', 'Active', 'Valid', 'Pending', 'Invalid', 'Other', 'Max')"/>
            <xsl:value-of select="jcs:printf('%-85j1s\n', '-------------------------------------------------------------------------------------')"/>
        </output>
        
        <xsl:variable name="rpc-session-summary">
            <rpc>
                <command>show security flow session summary no-forwarding</command>
            </rpc>
        </xsl:variable>
        <xsl:variable name="session-summary-results" select="ext:node-set(jcs:execute($connection,$rpc-session-summary))"/>
        <xsl:for-each select="$session-summary-results[local-name() = 'flow-session-summary-information']">
            <xsl:variable name="counter-local" select="position()"/>
            <xsl:variable name="active-unicast-sessions" select="./active-unicast-sessions[1]"/>
            <xsl:variable name="active-multicast-sessions" select="./active-multicast-sessions[1]"/>
            <xsl:variable name="failed-sessions" select="./failed-sessions[1]"/>
            <xsl:variable name="active-sessions" select="./active-sessions[1]"/>
            <xsl:variable name="active-session-valid" select="./active-session-valid[1]"/>
            <xsl:variable name="active-session-pending" select="./active-session-pending[1]"/>
            <xsl:variable name="active-session-invalidated" select="./active-session-invalidated[1]"/>
            <xsl:variable name="active-session-other" select="./active-session-other[1]"/>
            <xsl:variable name="max-sessions" select="./max-sessions[1]"/>
            <output>
                <xsl:value-of select="jcs:printf('%4d %8d %8d %8d %8d %8d %8d %8d %8d %8d\n', $counter-local, $active-unicast-sessions,
                    $active-multicast-sessions,$failed-sessions,$active-sessions,$active-session-valid,$active-session-pending,
                    $active-session-invalidated,$active-session-other,$max-sessions)"/>
            </output>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="monitor-fpc">
        <xsl:param name="fpc-number"/>
        <xsl:variable name="rpc-security-monitor-fpc">
            <rpc>
                <command>show security monitor fpc <xsl:value-of select="$fpc-number"/> no-forwarding</command>
            </rpc>
        </xsl:variable>
        <xsl:variable name="security-monitor-results" select="jcs:execute($connection,$rpc-security-monitor-fpc)"/>
        <xsl:for-each select="$security-monitor-results//spu-utilization-statistics/fpc">
            <xsl:variable name="fpc-number" select="./fpc-number[1]"/>
            <xsl:variable name="pic-number0" select="./pic/pic-number[1]"/>
            <xsl:variable name="spu-cpu-utilization0" select="./pic/spu-cpu-utilization[1]"/>
            <xsl:variable name="spu-memory-utilization0" select="./pic/spu-memory-utilization[1]"/>
            <xsl:variable name="spu-current-flow-session0" select="./pic/spu-current-flow-session[1]"/>
            <xsl:variable name="spu-max-flow-session0" select="./pic/spu-max-flow-session[1]"/>
            <xsl:variable name="spu-current-cp-session0" select="./pic/spu-current-cp-session[1]"/>
            <xsl:variable name="spu-max-cp-session0" select="./pic/spu-max-cp-session[1]"/>
            <output>
                <xsl:value-of select="jcs:printf('%3d %3d %3d %3d %14d %14d %14d %14d&#10;', $fpc-number, $pic-number0, $spu-cpu-utilization0, $spu-memory-utilization0, $spu-current-flow-session0, $spu-max-flow-session0, $spu-current-cp-session0, $spu-max-cp-session0)"/>
            </output>
            <xsl:if test="./pic-number[2]">
                <xsl:variable name="fpc-number" select="./fpc-number[1]"/>
                <xsl:variable name="pic-number1" select="./pic-number[2]"/>
                <xsl:variable name="spu-cpu-utilization1" select="./spu-cpu-utilization[2]"/>
                <xsl:variable name="spu-memory-utilization1" select="./spu-memory-utilization[2]"/>
                <xsl:variable name="spu-current-flow-session1" select="./spu-current-flow-session[2]"/>
                <xsl:variable name="spu-max-flow-session1" select="./spu-max-flow-session[2]"/>
                <xsl:variable name="spu-current-cp-session1" select="./spu-current-cp-session[2]"/>
                <xsl:variable name="spu-max-cp-session1" select="./spu-max-cp-session[2]"/>
                <output>
                    <xsl:value-of select="jcs:printf('%3d %3d %3d %3d %14d %14d %14d %14d&#10;', $fpc-number, $pic-number1, $spu-cpu-utilization1, $spu-memory-utilization1, $spu-current-flow-session1, $spu-max-flow-session1, $spu-current-cp-session1, $spu-max-cp-session1)"/>
                </output>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="get-srx-spcs">
        <xsl:variable name="rpc-show-chassis-hardware">
            <rpc>
                <command>show chassis hardware no-forwarding</command>
            </rpc>
        </xsl:variable>
        <xsl:variable name="show-chassis-hardware-results" select="jcs:execute($connection,$rpc-show-chassis-hardware)"/>
        <output>
            <xsl:value-of select="jcs:printf('%4s&#10;', 'SPUs')"/>
            <xsl:value-of select="jcs:printf('%-3s %-3jcs %-3jcs %-3jcs %14s %14s %14s %14s&#10;', 'FPC', 'PIC', 'CPU', 'Mem', 'Flow Sess Cur', 'Flow Ses Max', 'CP Ses Cur', 'CP Ses Max')"/>
            <xsl:value-of select="jcs:printf('%-80j1s&#10;', '--------------------------------------------------------------------------------')"/>
        </output>
        <xsl:variable name="fpc-regex">(FPC )([0-9]+)</xsl:variable>
        
        <xsl:for-each select="$show-chassis-hardware-results//chassis/chassis-module">
            <xsl:choose>
                <xsl:when test="contains(./description,'SPC')">
                    <xsl:variable name="fpc-number" select="jcs:regex($fpc-regex,./name)"/>
                    <xsl:call-template name="monitor-fpc"><xsl:with-param name="fpc-number" select="$fpc-number[3]"/></xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="get-srx-re">
        <xsl:variable name="rpc-show-chassis-routing-engine">
            <rpc>
                <command>show chassis routing-engine no-forwarding</command>
            </rpc>
        </xsl:variable>
        <xsl:variable name="show-chassis-routing-engine-results" select="jcs:execute($connection,$rpc-show-chassis-routing-engine)"/>
        <output>
            <xsl:value-of select="jcs:printf('%12s&#10;', 'Route Engine')"/>
            <xsl:value-of select="jcs:printf('%-4s %-7jcs %-7jcs %-7jcs %8s %8s %8s %9s %8s&#10;', 'Slot', 'Mem Size', 'Mem Used', 'CPU Avg', 'CPU User', 'CPU Bkgd', 'CPU Krnl', 'CPU Intpt', 'CPU Idle')"/>
            <xsl:value-of select="jcs:printf('%-80j1s&#10;', '--------------------------------------------------------------------------------')"/>
            <xsl:for-each select="$show-chassis-routing-engine-results//route-engine">
                <xsl:value-of select="jcs:printf('%4d %7d %9d %7d %8d %8d %8d %9d %8d&#10;', ./slot,
                    ./memory-dram-size,
                    ./memory-buffer-utilization,
                    (./cpu-user + ./cpu-background + ./cpu-system + ./cpu-interrupt ),
                    ./cpu-user,
                    ./cpu-background,
                    ./cpu-system,
                    ./cpu-interrupt,
                    ./cpu-idle)"/>
            </xsl:for-each>
        </output>
    </xsl:template>
    
    
    <xsl:template match="/">
        <op-script-results>
            <xsl:call-template name="get-srx-re"/>
            <xsl:call-template name="get-srx-spcs"/>
            <xsl:call-template name="session-summary"/>
        </op-script-results>    
    </xsl:template>
    
</xsl:stylesheet>