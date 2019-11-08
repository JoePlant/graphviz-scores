<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                >
	<xsl:output method="xml" indent="yes" />

	<xsl:variable name='quote'>"</xsl:variable>
	<xsl:variable name='newline'>\n</xsl:variable>
	<xsl:variable name='BYE'>BYE</xsl:variable>
	
	<xsl:variable name='include-score'>y</xsl:variable>
	
	<xsl:key name='games-by-team' match='Game' use='Score/@id'/>
	<xsl:key name='teams-by-id' match='Team' use='@id'/>
	<xsl:key name='scores-by-id' match='Score' use='@id'/>
	<xsl:key name='results-by-id' match='Result' use='@id'/>
	
	<xsl:key name='pools-by-team' match='Pool' use='Game/Score/@id' />

	<xsl:variable name='unique-score-ids' select="//Score[count(. | key('scores-by-id', @id)[1]) = 1]"/>
	<xsl:variable name='unique-result-ids' select="//Result[count(. | key('results-by-id', @id)[1]) = 1]"/>
	
	<xsl:template match='/'>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match='Teams'>
		<Teams>
			<!-- 
			<xsl:comment> <xsl:value-of select='count($unique-score-ids)'/> </xsl:comment>
			-->
			<xsl:variable name='teams-not-listed' select="$unique-score-ids[(count(key('teams-by-id', @id)) + count(key('results-by-id', @id))) = 0]"/>
			<xsl:for-each select='$teams-not-listed' >
				<Team id='{@id}' name='Missing {@id}' missing='1' color='red'>
					<xsl:call-template name='team-references' />
				</Team>
			</xsl:for-each>
			<xsl:apply-templates select='Team'/>
		</Teams>
	</xsl:template>
	
	<xsl:template match='Team'>
<!-- 
		<xsl:comment>
Team: <xsl:value-of select='@name'/> 
</xsl:comment>
-->
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:call-template name='team-references' />
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name='team-references'>
		<xsl:variable name='games' select="key('games-by-team', @id)"/>
		<xsl:variable name='pools' select="key('pools-by-team', @id)"/>
		<xsl:attribute name='games'><xsl:value-of select='count($games)'/></xsl:attribute>
		<xsl:attribute name='pools'><xsl:value-of select='count($pools)'/></xsl:attribute>
		<!--
		<xsl:for-each select='$pools'>
			<Pool pool-id-ref='P_{generate-id(.)}'/>
		</xsl:for-each>
		<xsl:for-each select='$games'>
			<Game game-id-ref='G_{generate-id(.)}'/>
		</xsl:for-each>
		-->
	</xsl:template>
	
	<xsl:template match='Pools'>
		<Pools>
			<xsl:apply-templates select='Pool'>
				<xsl:sort select='@name'/>
			</xsl:apply-templates>
		</Pools>
	</xsl:template>
	
	<xsl:template match='Pool'>
		<xsl:variable name='pool-name'>
			<xsl:call-template name='pool-name'>
				<xsl:with-param name='pool' select='.'/>
			</xsl:call-template>
		</xsl:variable>
		<Pool pool-id='P_{generate-id(.)}' id='{@id}' name='{$pool-name}'>
			<xsl:for-each select="key('teams-by-id', Game/Score/@id)">
				<xsl:sort select='@id'/>
				<Team team-id-ref='{@id}'/>
			</xsl:for-each>
			<xsl:for-each select="key('results-by-id', Game/Score/@id)">
				<xsl:sort select='@id'/>
				<Result result-id-ref='R_{generate-id(.)}'/>
			</xsl:for-each>
			<xsl:apply-templates />
		</Pool>
	</xsl:template>
	
	<xsl:template match='Result'>
		<xsl:variable name='team-id' select='@team-id'/>
		
		<Result result-id='R_{generate-id(.)}' id='{@id}' team-id-ref='{$team-id}' name='{@id}'/>
	</xsl:template>
	
	<xsl:template match='Games'>
		<Games>
			<xsl:apply-templates select='Group/Game'>
				<xsl:sort select='@name'/>
			</xsl:apply-templates>
		</Games>
	</xsl:template>
	
	<xsl:template match='Game'>
		<xsl:variable name='group-name'>
			<xsl:call-template name='pool-name'>
				<xsl:with-param name='pool' select='..'/>
			</xsl:call-template>
		</xsl:variable>
		<Game game-id='G_{generate-id(.)}' group='{$group-name}' name='{@name}'>
			<xsl:apply-templates select='Score'/>
		</Game>
	</xsl:template>
	
	<xsl:template match='Score'>
		<xsl:variable name='id' select='generate-id(.)'/>
		<xsl:variable name='this' select='.'/>
		<xsl:variable name='other' select='../Score[not (generate-id(.) = $id)]'/>
		<xsl:variable name='outcome'>
			<xsl:call-template name='result'>
				<xsl:with-param name='this-score' select='$this/@score' />
				<xsl:with-param name='other-score' select='$other/@score' />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name='team' select="key('teams-by-id', @id)"/>
		<xsl:variable name='result' select="key('results-by-id', @id)"/>
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name='result'><xsl:value-of select='$outcome'/></xsl:attribute>
			<xsl:choose>
				<xsl:when test='$team'>
					<xsl:attribute name='team-id-ref'><xsl:value-of select='$team/@id'/></xsl:attribute>
				</xsl:when>
				<xsl:when test='$result'>
					<xsl:attribute name='result-id-ref'>R_<xsl:value-of select='generate-id($result)'/></xsl:attribute>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:copy>
		<!-- 
		<Score id="{@id}" score='{@score}' result='{$result}' />
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy> -->
	</xsl:template>
	
	<xsl:template name='result'>
		<xsl:param name='this-score'/>
		<xsl:param name='other-score'/>
		<xsl:choose>
			<xsl:when test='$this-score &gt; $other-score'>winner</xsl:when>
			<xsl:when test='$this-score &lt; $other-score'>loser</xsl:when>
			<xsl:when test='$this-score = $other-score'>draw</xsl:when>
			<xsl:when test='$this-score = $BYE'>bye</xsl:when>
			<xsl:when test='$other-score = $BYE'>bye</xsl:when>
			<xsl:otherwise>na</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name='pool-name'>
		<xsl:param name='pool' select='.'/>
		<xsl:choose>
			<xsl:when test='string-length($pool/@name) > 0'><xsl:value-of select='$pool/@name'/></xsl:when>
			<xsl:when test='name($pool)="Pool"'><xsl:value-of select='concat("Pool ", $pool/@id)'/></xsl:when>
			<xsl:when test='$pool/../@name'><xsl:value-of select='$pool/../@name'/></xsl:when>
			<xsl:otherwise>
				<xsl:value-of select='$pool/@name'/>
			</xsl:otherwise>
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
