rem @echo off
rem set scores=scores.xml
rem set scores=scores-waterpolo.xml
set scores=scores-16B.xml
set output=Output\16B

if EXIST Working goto Working_exists
mkdir Working
:Working_exists

del Working\Graphs\*.* /Q
del %output%\Graphs\*.* /Q

set nxslt=..\lib\nxslt\nxslt.exe
set graphviz=..\lib\GraphViz-2.38\bin
set dotml=..\lib\dotml-1.4

@echo === Apply Templates ===
%nxslt% %scores% Stylesheets\layout-scores.xslt -o Working\scores-layout.xml 
rem %nxslt% Working\scores-layout.xml  Stylesheets\extract-link-data.xslt -o Working\linkdata.xml 

%nxslt% Working\scores-layout.xml StyleSheets\render-scores-dotml.xslt -o Working\scores.dotml
%nxslt% Working\scores.dotml %dotml%\dotml2dot.xsl -o "Working\scores.gv" 
%graphviz%\dot.exe -Tsvg "Working\scores.gv"  -o "%output%\scores.svg"
%graphviz%\dot.exe -Tpng "Working\scores.gv"  -o "%output%\scores.png"
pause
