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

	
	<xsl:template match="/" >
		<xsl:apply-templates select="/Competition"/>
	</xsl:template>
	
	<xsl:template match="/Competition">
		<dotml:graph file-name="scores" label="{@name}" rankdir="{$direction}" fontname="{$fontname}" fontsize="{$font-size-h1}" labelloc='t' >			
			<xsl:apply-templates select='Teams/Team' mode='node'/>
			<xsl:apply-templates select='Games/Game' mode='node'/>
			
			<xsl:apply-templates select='Games/Game' mode='link'/>
			
		</dotml:graph>
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
		<xsl:variable name='na' select="Score[@result='na']"/>
		<xsl:for-each select='$winner'>
			<dotml:edge from="{@id}" to="{$game-id}" color='{$game-color}'/>
		</xsl:for-each>
		<xsl:for-each select='$loser'>
			<dotml:edge from="{$game-id}" to="{@id}" color='{$game-color}'/>
		</xsl:for-each>
		<xsl:for-each select='$draw | $na'>
			<dotml:edge from="{@id}" to="{$game-id}" color='{$game-color}'/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="Game" mode="node">
		<xsl:variable name='winner' select="Score[@result='winner']"/>
		<xsl:variable name='loser' select="Score[@result='loser']"/>
		<xsl:variable name='draw' select="Score[@result='draw']"/>
		<xsl:variable name='text'>
			<xsl:value-of select='@group'/>
			<xsl:value-of select='$newline'/>
			<xsl:value-of select='($winner|$draw)/@score'/>
			<xsl:text>-</xsl:text>
			<xsl:value-of select='($loser|$draw)/@score'/>
		</xsl:variable>
		<dotml:node id="{@game-id}" style="solid" shape="box" label='{$text}' fillcolor='{$back-color}' color="{$game-color}" 
				fontname="{$fontname}" fontsize="{$font-size-h3}" fontcolor="{$game-color}" />
	</xsl:template>
	


</xsl:stylesheet>
