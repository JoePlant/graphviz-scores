<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
	<xsl:output method="xml" indent="yes" />

	<xsl:variable name='quote'>"</xsl:variable>
	<xsl:variable name='newline'>\n</xsl:variable>
	
	<xsl:variable name='include-score'>y</xsl:variable>
	
	<xsl:key name='games-by-team' match='Game' use='Score/@id'/>
	<xsl:key name='teams-by-id' match='Team' use='@id'/>
	
	<xsl:template match='/'>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match='Teams'>
		<Teams>
			<xsl:variable name='teams-not-listed' select="//Score[count(key('teams-by-id', @id)) = 0]"/>
			<xsl:for-each select='$teams-not-listed' >
				<Team id='{@id}' name='Missing {@id}' color='red'/>
			</xsl:for-each>
			<xsl:apply-templates select='Team'/>
		</Teams>
	</xsl:template>
	
	<xsl:template match='Team'>
		<xsl:variable name='games' select="key('games-by-team', @id)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name='games'><xsl:value-of select='count($games)'/></xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match='Games'>
		<Games>
			<xsl:apply-templates select='Group/Game'>
				<xsl:sort select='@name'/>
			</xsl:apply-templates>
		</Games>
	</xsl:template>
	
	<xsl:template match='Game'>
		<Game game-id='G_{generate-id()}' group='{../@name}' name='{@name}'>
			<xsl:apply-templates select='Score'/>
		</Game>
	</xsl:template>
	
	<xsl:template match='Score'>
		<xsl:variable name='id' select='generate-id(.)'/>
		<xsl:variable name='this' select='.'/>
		<xsl:variable name='other' select='../Score[not (generate-id(.) = $id)]'/>
		<xsl:variable name='result'>
			<xsl:call-template name='result'>
				<xsl:with-param name='this-score' select='$this/@score' />
				<xsl:with-param name='other-score' select='$other/@score' />
			</xsl:call-template>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name='result'><xsl:value-of select='$result'/></xsl:attribute>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name='result'>
		<xsl:param name='this-score'/>
		<xsl:param name='other-score'/>
		<xsl:choose>
			<xsl:when test='$this-score &gt; $other-score'>winner</xsl:when>
			<xsl:when test='$this-score &lt; $other-score'>loser</xsl:when>
			<xsl:when test='$this-score = $other-score'>draw</xsl:when>
			<xsl:otherwise>na</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>
