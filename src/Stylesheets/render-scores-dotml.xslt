<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:dotml="http://www.martin-loetzsch.de/DOTML" >
	
	<xsl:output method="xml" indent="yes" />
	
	<!-- default is not to cluster -->
	<!-- to cluster specify any value that is not empty -->
	<xsl:param name='cluster'></xsl:param>
	
	<!-- default is show messages on labels-->
	<!-- options are node, label, none, '' -->
	<xsl:param name='message-format'>label</xsl:param>
	
	<xsl:param name='title'>Graph</xsl:param>
	<xsl:param name='mode'>include-game</xsl:param>
	
	<xsl:param name='direction'>TB</xsl:param>

	<xsl:include href='include-graphs-colours.xslt'/>
	
	<xsl:variable name='newline'>\n</xsl:variable>

	<xsl:key name='teams-by-id' match='Team' use='@id'/>
	
	<xsl:template match="/" >
		<xsl:apply-templates select="/Competition"/>
	</xsl:template>
	
	<xsl:template match="/Competition">
		<dotml:graph file-name="scores" label="{@name}" rankdir="{$direction}" fontname="{$fontname}" fontsize="{$font-size-h1}" labelloc='t' >	
			<xsl:choose>
				<xsl:when test='Pools/Pool'>
					<xsl:apply-templates select='Pools/Pool' mode='cluster' />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select='Teams/Team' mode='node' />
				</xsl:otherwise>
			</xsl:choose>
				<!-- <xsl:apply-templates select='Teams/Team' mode='node'/> -->
			<xsl:apply-templates select='Games/Game' mode='node'/>
			
			<xsl:apply-templates select='Games/Game' mode='link'/>
			
		</dotml:graph>
	</xsl:template>
	
	<xsl:template match='Pool' mode='cluster'>
		<dotml:cluster id='{@pool-id}' 
					label='{@name}' labeljust='l' labelloc="t" 
					style='dotted' fillcolor='{$pool-color}' color="{$pool-color}" 
					fontname="{$fontname}" fontcolor="{$pool-color}" fontsize="{$font-size-h2}"> 
					
					<xsl:apply-templates select="key('teams-by-id', Team/@team-id-ref)" mode='node' />

					<xsl:apply-templates select="Result[@result-id-ref]" mode='node' />
										
					<xsl:apply-templates select='Game' mode='node'/>
					<xsl:if test='Result'>
						<dotml:record color="{$pool-color}" fontname="{$fontname}" fontcolor="{$pool-color}" fontsize="{$font-size-h2}">
							<xsl:apply-templates select='Result[@result-id]' mode='node'/>
						</dotml:record>
					</xsl:if>
					<xsl:apply-templates select='Game' mode='link'/>
					<xsl:apply-templates select='Result' mode='link'/>
					
				</dotml:cluster>
	</xsl:template>
	
	<xsl:template match="Team" mode="node">
		<xsl:variable name='color'>
			<xsl:choose>
				<xsl:when test='@color'><xsl:value-of select='@color'/></xsl:when>
				<xsl:otherwise><xsl:value-of select='$team-color'/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name='fillcolor'>
			<xsl:choose>
				<xsl:when test='@fillcolor'><xsl:value-of select='@fillcolor'/></xsl:when>
				<xsl:otherwise><xsl:value-of select='$back-color'/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<dotml:node id="{@id}" style="filled" shape="box" label='{@name}' fillcolor='{$fillcolor}' color="{$color}" 
				fontname="{$fontname}" fontsize="{$font-size-h2}" fontcolor="{$color}" />
	</xsl:template>

	<xsl:template match='Game' mode='link'>
		<xsl:variable name='game-id' select="@game-id"/>
		<xsl:variable name='winner' select="Score[@result='winner']"/>
		<xsl:variable name='loser' select="Score[@result='loser']"/>
		<xsl:variable name='draw' select="Score[@result='draw']"/>
		<xsl:variable name='bye' select="Score[@result='bye']"/>
		<xsl:variable name='na' select="Score[@result='na']"/>
		<xsl:for-each select='$winner'>
			<xsl:variable name='winner-id'>
				<xsl:choose>
					<xsl:when test='@result-id-ref'><xsl:value-of select='@result-id-ref'/></xsl:when>
					<xsl:when test='@team-id-ref'><xsl:value-of select='@team-id-ref'/></xsl:when>
					<xsl:otherwise><xsl:value-of select='@id'/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<dotml:edge from="{$winner-id}" to="{$game-id}" color='{$game-color}'/>
		</xsl:for-each>
		<xsl:for-each select='$loser'>
			<xsl:variable name='loser-id'>
				<xsl:choose>
					<xsl:when test='@result-id-ref'><xsl:value-of select='@result-id-ref'/></xsl:when>
					<xsl:when test='@team-id-ref'><xsl:value-of select='@team-id-ref'/></xsl:when>
					<xsl:otherwise><xsl:value-of select='@id'/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<dotml:edge from="{$game-id}" to="{$loser-id}" color='{$game-color}'/>
		</xsl:for-each>
		<xsl:for-each select='$draw | $na'>
			<xsl:variable name='team-id'>
				<xsl:choose>
					<xsl:when test='@result-id-ref'><xsl:value-of select='@result-id-ref'/></xsl:when>
					<xsl:when test='@team-id-ref'><xsl:value-of select='@team-id-ref'/></xsl:when>
					<xsl:otherwise><xsl:value-of select='@id'/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<dotml:edge from="{$team-id}" to="{$game-id}" color='{$game-color}'/>
		</xsl:for-each>
		<xsl:for-each select='$bye'>
			<xsl:variable name='team-id'>
				<xsl:choose>
					<xsl:when test='@result-id-ref'><xsl:value-of select='@result-id-ref'/></xsl:when>
					<xsl:when test='@team-id-ref'><xsl:value-of select='@team-id-ref'/></xsl:when>
					<xsl:otherwise><xsl:value-of select='@id'/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<dotml:edge from="{$team-id}" to="{$game-id}" color='{$game-color}'/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Game" mode="node">
		<xsl:variable name='winner' select="Score[@result='winner']"/>
		<xsl:variable name='loser' select="Score[@result='loser']"/>
		<xsl:variable name='draw' select="Score[@result='draw']"/>
		<xsl:variable name='bye' select="Score[@results='bye']"/>
		<xsl:variable name='text'>
			<xsl:value-of select='@name'/>
			<xsl:value-of select='$newline'/>
			<xsl:choose> 
				<xsl:when test='$winner|$draw|$loser'>
					<xsl:value-of select='($winner|$draw)/@score'/>
					<xsl:text>-</xsl:text>
					<xsl:value-of select='($loser|$draw)/@score'/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select='$bye/@score'/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<dotml:node id="{@game-id}" style="solid" shape="box" label='{$text}' fillcolor='{$back-color}' color="{$game-color}" 
				fontname="{$fontname}" fontsize="{$font-size-h3}" fontcolor="{$game-color}" />
	</xsl:template>
	
	<xsl:template match='Result[@result-id-ref]' mode='node'>
		<xsl:variable name='result' select="key('results-by-id', @result-id-ref)" />
		<xsl:variable name='pool' select='ancestor-or-self::Pool'/>
		<xsl:apply-templates select='$result' mode='node'>
			<xsl:with-param name='pool' select='$pool' />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="Result[@result-id]" mode="node">
		<xsl:param name='pool' select='Pool'/> <!-- default no node -->
		<xsl:variable name='team' select="key('teams-by-id', @team-id-ref)" />
		<xsl:variable name='prefix' select='$pool/@id'/>
		<xsl:variable name='text'>
			<xsl:value-of select='@name'/>
			<xsl:choose>
				<xsl:when test='$team'>
					<xsl:value-of select='$newline'/>
					<xsl:value-of select='$team/@name'/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select='$newline'/>
					<xsl:text>?</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<dotml:node id="{$prefix}{@result-id}" style="dotted" shape="box" label='{$text}' fillcolor='{$back-color}' color="{$game-color}" 
				fontname="{$fontname}" fontsize="{$font-size-h3}" fontcolor="{$game-color}" />
	</xsl:template>

	<xsl:template match='Result' mode='link'>
		<xsl:choose>
			<xsl:when test='string-length(@team-id-ref)=0'/>
			<xsl:otherwise>
				<dotml:edge style="dotted" from="{@team-id-ref}" to="{@result-id}" color='{$game-color}'/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
